import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/all.dart';

import '../../../core/highlight/code_themes.dart';
import '../../../core/highlight/language_detect.dart';
import '../../../core/highlight/language_visuals.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/code_view.dart';
import '../../settings/application/settings_providers.dart';
import '../application/snippet_providers.dart';
import '../domain/snippet.dart';
import '../domain/snippet_type.dart';
import '../domain/value_objects.dart';
import 'widgets/code_find_panel.dart';
import 'widgets/label_field.dart';

/// Per-file editing state inside the editor. Each file owns a re_editor content
/// controller, a filename text controller, and a selected language. [overridden]
/// records whether the user manually picked the language (so a later filename
/// edit won't clobber their choice via auto-detection).
class _FileEditState {
  _FileEditState({
    String filename = '',
    this.languageId,
    String content = '',
    this.overridden = false,
  })  : filenameController = TextEditingController(text: filename),
        contentController = CodeLineEditingController.fromText(content);

  final TextEditingController filenameController;
  final CodeLineEditingController contentController;
  String? languageId;
  bool overridden;

  void dispose() {
    filenameController.dispose();
    contentController.dispose();
  }
}

/// Create (snippetId == null) or edit a snippet.
class SnippetEditorScreen extends ConsumerStatefulWidget {
  const SnippetEditorScreen({
    super.key,
    this.snippetId,
    this.isModal = false,
  });

  final String? snippetId;

  /// When true the editor is hosted inside a [Dialog] (see
  /// [showSnippetEditor]); save/discard pop the root navigator instead of
  /// using go_router. When false the legacy /new and /edit routes drive
  /// navigation.
  final bool isModal;

  bool get isEditing => snippetId != null;

  @override
  ConsumerState<SnippetEditorScreen> createState() =>
      _SnippetEditorScreenState();
}

class _SnippetEditorScreenState extends ConsumerState<SnippetEditorScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// One entry per file; always at least one.
  final List<_FileEditState> _files = [_FileEditState()];

  // Prompt-only controllers.
  final _modelController = TextEditingController();
  final _providerController = TextEditingController();
  final _systemPromptController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _maxTokensController = TextEditingController();

  SnippetType _type = SnippetType.code;
  String? _purpose;
  String? _collectionId;
  List<String> _labels = [];
  List<PromptVariable> _existingVariables = const [];

  bool _loading = false;
  bool _saving = false;
  SnippetVisibility _visibility = SnippetVisibility.private;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loading = true;
      _load();
    } else {
      // New snippet: pre-select the user's default language, if set.
      _files.first.languageId = ref.read(settingsProvider).defaultLanguageId;
    }
  }

  Future<void> _load() async {
    final snippet =
        await ref.read(snippetRepositoryProvider).getSnippet(widget.snippetId!);
    if (!mounted) return;
    if (snippet != null) {
      _titleController.text = snippet.title;
      _descriptionController.text = snippet.description ?? '';
      _type = snippet.type;
      _purpose = snippet.purpose;
      _collectionId = snippet.collectionId;
      _labels = [for (final l in snippet.labels) l.name];
      _visibility = snippet.visibility;

      // Load files into per-file editors. Fall back to a single file built from
      // the denormalized body when the snippet has no file rows.
      for (final f in _files) {
        f.dispose();
      }
      _files
        ..clear()
        ..addAll(snippet.files.isNotEmpty
            ? [
                for (final f in snippet.files)
                  _FileEditState(
                    filename: f.filename,
                    languageId: f.languageId,
                    content: f.content,
                    // A loaded file's language is treated as user-chosen so a
                    // later filename edit won't silently overwrite it.
                    overridden: true,
                  ),
              ]
            : [
                _FileEditState(
                  languageId: snippet.languageId,
                  content: snippet.body,
                  overridden: true,
                ),
              ]);

      final meta = snippet.promptMeta;
      if (meta != null) {
        _modelController.text = meta.targetModel ?? '';
        _providerController.text = meta.modelProvider ?? '';
        _systemPromptController.text = meta.systemPrompt ?? '';
        _temperatureController.text = meta.temperature?.toString() ?? '';
        _maxTokensController.text = meta.maxTokens?.toString() ?? '';
        _existingVariables = meta.variables;
      }
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final f in _files) {
      f.dispose();
    }
    _modelController.dispose();
    _providerController.dispose();
    _systemPromptController.dispose();
    _temperatureController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String value) {
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  AiPromptMeta _buildMeta() => AiPromptMeta(
        targetModel: _nullIfEmpty(_modelController.text),
        modelProvider: _nullIfEmpty(_providerController.text),
        systemPrompt: _nullIfEmpty(_systemPromptController.text),
        temperature: double.tryParse(_temperatureController.text.trim()),
        maxTokens: int.tryParse(_maxTokensController.text.trim()),
        variables: _existingVariables,
      );

  void _addFile() {
    setState(() {
      _files.add(_FileEditState(
        languageId: ref.read(settingsProvider).defaultLanguageId,
      ));
    });
  }

  void _removeFile(int index) {
    if (_files.length <= 1) return; // keep at least one file
    setState(() {
      _files.removeAt(index).dispose();
    });
  }

  /// React to a filename change: auto-detect the language for that file unless
  /// the user has manually overridden it.
  void _onFilenameChanged(_FileEditState file, String filename) {
    if (file.overridden) return;
    final languages = ref.read(languagesProvider).value ?? const [];
    final detected = detectLanguageFromFilename(filename, languages);
    if (detected != null && detected.id != file.languageId) {
      setState(() => file.languageId = detected.id);
    }
  }

  void _onLanguagePicked(_FileEditState file, String? languageId) {
    setState(() {
      file.languageId = languageId;
      file.overridden = true; // respect the user's explicit choice from now on
    });
  }

  /// Pop the hosting dialog (modal mode) or fall back to go_router.
  void _closeModal() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    setState(() => _saving = true);
    final files = [
      for (final f in _files)
        SnippetFileDraft(
          filename: f.filenameController.text.trim(),
          languageId: f.languageId,
          content: f.contentController.text,
        ),
    ];
    final first = _files.first;
    final draft = SnippetDraft(
      title: title,
      // Keep body/languageId mirroring the first file for legacy consumers; the
      // repository prefers `files` when present.
      body: first.contentController.text,
      languageId: first.languageId,
      type: _type,
      purpose: _purpose,
      description: _nullIfEmpty(_descriptionController.text),
      collectionId: _collectionId,
      labelNames: _labels,
      promptMeta: _type == SnippetType.aiPrompt ? _buildMeta() : null,
      files: files,
      visibility: _visibility,
    );
    final repo = ref.read(snippetRepositoryProvider);
    try {
      if (widget.isEditing) {
        await repo.update(widget.snippetId!, draft);
        if (!mounted) return;
        if (widget.isModal) {
          _closeModal();
        } else if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.snippetDetail(widget.snippetId!));
        }
      } else {
        final id = await repo.create(draft);
        if (!mounted) return;
        if (widget.isModal) {
          _closeModal();
        } else {
          context.pushReplacement(RoutePaths.snippetDetail(id));
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $error')));
      }
    }
  }

  void _discard() {
    if (widget.isModal) {
      _closeModal();
    } else {
      context.pop();
    }
  }

  /// Pick one or more files and attach them to this (already-saved) snippet.
  /// Only callable when editing an existing snippet — attachments need a
  /// snippet id to hang off of.
  Future<void> _attachFiles() async {
    final snippetId = widget.snippetId;
    if (snippetId == null) return;

    final FilePickerResult? result;
    try {
      // file_picker 12.x: pickFiles is multi-select by default; load each
      // file's bytes on demand via readAsBytes() (the withData parameter is
      // deprecated).
      result = await FilePicker.pickFiles();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not pick files: $error')));
      }
      return;
    }
    if (result == null || result.files.isEmpty) return; // user cancelled

    final repo = ref.read(snippetRepositoryProvider);
    var added = 0;
    for (final file in result.files) {
      try {
        final bytes = await file.readAsBytes();
        await repo.addAttachment(
          snippetId,
          filename: file.name,
          mimeType: _mimeTypeFor(file.name),
          bytes: bytes,
        );
        added++;
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not attach ${file.name}: $error')),
          );
        }
      }
    }
    if (mounted && added > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added == 1 ? 'Attached 1 file' : 'Attached $added files'),
        ),
      );
    }
  }

  Future<void> _createCollection() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      final id =
          await ref.read(snippetRepositoryProvider).createCollection(name.trim());
      if (mounted) setState(() => _collectionId = id);
    }
  }

  /// Wrap the current description selection with [prefix]/[suffix] (inline marks
  /// like bold/italic/code/link). With no selection, inserts the marks and
  /// places the caret between them so the user can type.
  void _wrapSelection(String prefix, [String suffix = '']) {
    final c = _descriptionController;
    final value = c.value;
    final sel = value.selection;
    final text = value.text;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final selected = text.substring(start, end);
    final replacement = '$prefix$selected$suffix';
    final newText = text.replaceRange(start, end, replacement);
    // Caret: if there was a selection, keep it selected inside the marks;
    // otherwise drop the caret right after the prefix.
    final caret = selected.isEmpty
        ? TextSelection.collapsed(offset: start + prefix.length)
        : TextSelection(
            baseOffset: start + prefix.length,
            extentOffset: start + prefix.length + selected.length,
          );
    c.value = value.copyWith(text: newText, selection: caret);
  }

  /// Prefix the line(s) covering the current selection with [linePrefix]
  /// (block marks like heading/quote/lists/checklist).
  void _prefixLines(String linePrefix) {
    final c = _descriptionController;
    final value = c.value;
    final sel = value.selection;
    final text = value.text;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : start;
    // Expand to whole lines.
    var lineStart = text.lastIndexOf('\n', start > 0 ? start - 1 : 0);
    lineStart = lineStart == -1 ? 0 : lineStart + 1;
    var lineEnd = text.indexOf('\n', end);
    lineEnd = lineEnd == -1 ? text.length : lineEnd;
    final block = text.substring(lineStart, lineEnd);
    final prefixed =
        block.split('\n').map((line) => '$linePrefix$line').join('\n');
    final newText = text.replaceRange(lineStart, lineEnd, prefixed);
    c.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: lineStart + prefixed.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      const indicator = Center(child: CircularProgressIndicator());
      return widget.isModal ? indicator : const Scaffold(body: indicator);
    }

    final languages = ref.watch(languagesProvider).value ?? const [];
    final purposes = ref.watch(purposesProvider).value ?? const [];
    final collections = ref.watch(collectionsProvider).value ?? const [];
    final labelSuggestions = [
      for (final l in ref.watch(labelsProvider).value ?? const <Label>[]) l.name,
    ];

    final form = ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        // Big Snippet-style title field.
        TextField(
          controller: _titleController,
          textInputAction: TextInputAction.next,
          style: theme.textTheme.headlineSmall,
          decoration: InputDecoration(
            filled: false,
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: 'Title',
            hintStyle: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        const Divider(height: 24),

        // Type selector (kept).
        SegmentedButton<SnippetType>(
          segments: const [
            ButtonSegment(
              value: SnippetType.code,
              label: Text('Code'),
              icon: Icon(Icons.code),
            ),
            ButtonSegment(
              value: SnippetType.aiPrompt,
              label: Text('AI Prompt'),
              icon: Icon(Icons.smart_toy_outlined),
            ),
            ButtonSegment(
              value: SnippetType.text,
              label: Text('Text'),
              icon: Icon(Icons.notes),
            ),
          ],
          selected: {_type},
          onSelectionChanged: (s) => setState(() {
            _type = s.first;
            // Drop a purpose that doesn't apply to the new type, so the
            // purpose dropdown's value always stays within its items.
            if (_purpose != null &&
                !purposes
                    .any((p) => p.id == _purpose && p.appliesTo(_type.wire))) {
              _purpose = null;
            }
          }),
        ),
        const SizedBox(height: 24),

        // DESCRIPTION — Markdown supported, with a formatting toolbar.
        _SectionHeader(
          title: 'DESCRIPTION',
          trailing: Text(
            'Markdown supported',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 8),
        _MarkdownToolbar(
          onHeading: () => _prefixLines('# '),
          onBold: () => _wrapSelection('**', '**'),
          onItalic: () => _wrapSelection('*', '*'),
          onQuote: () => _prefixLines('> '),
          onCode: () => _wrapSelection('`', '`'),
          onLink: () => _wrapSelection('[', '](url)'),
          onBullet: () => _prefixLines('- '),
          onNumbered: () => _prefixLines('1. '),
          onChecklist: () => _prefixLines('- [ ] '),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          minLines: 3,
          maxLines: 8,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(
            hintText: 'Describe this snippet… (Markdown supported)',
          ),
        ),
        const SizedBox(height: 24),

        // Organization: purpose / collection / labels.
        _PurposeDropdown(
          purposes: purposes,
          typeWire: _type.wire,
          value: purposes.any((p) => p.id == _purpose) ? _purpose : null,
          onChanged: (v) => setState(() => _purpose = v),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CollectionDropdown(
                collections: collections,
                value: collections.any((c) => c.id == _collectionId)
                    ? _collectionId
                    : null,
                onChanged: (v) => setState(() => _collectionId = v),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'New collection',
              onPressed: _createCollection,
              icon: const Icon(Icons.create_new_folder_outlined),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LabelField(
          labels: _labels,
          suggestions: labelSuggestions,
          onChanged: (t) => setState(() => _labels = t),
        ),
        const SizedBox(height: 24),

        // FILES section: N files, each filename + language + code editor.
        _SectionHeader(
          title: 'FILES',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ATTACH: pick binary files and attach them to this snippet. Only
              // meaningful once the snippet exists (needs an id); for a brand
              // new unsaved snippet we disable it with an explanatory tooltip.
              Tooltip(
                message: widget.isEditing
                    ? 'Attach files'
                    : 'Save the snippet first, then you can attach files',
                child: TextButton.icon(
                  onPressed: widget.isEditing ? _attachFiles : null,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text('Attach'),
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: _addFile,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add file'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _files.length; i++) ...[
          _FileEditor(
            key: ObjectKey(_files[i]),
            file: _files[i],
            languages: languages,
            canRemove: _files.length > 1,
            onFilenameChanged: (name) => _onFilenameChanged(_files[i], name),
            onLanguageChanged: (id) => _onLanguagePicked(_files[i], id),
            onRemove: () => _removeFile(i),
          ),
          const SizedBox(height: 16),
        ],

        if (_type == SnippetType.aiPrompt) ...[
          Text(
            'Tip: use {{variable}} placeholders — they are detected '
            'automatically.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _PromptSettings(
            providerController: _providerController,
            modelController: _modelController,
            systemPromptController: _systemPromptController,
            temperatureController: _temperatureController,
            maxTokensController: _maxTokensController,
          ),
        ],
        const SizedBox(height: 8),
      ],
    );

    // Pinned footer — always visible, so you never scroll to reach Save.
    final footer = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border:
            Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
      child: Row(
        children: [
          _VisibilityToggle(
            value: _visibility,
            onChanged: (v) => setState(() => _visibility = v),
          ),
          const Spacer(),
          TextButton(
            onPressed: _saving ? null : _discard,
            child: const Text('Discard'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
    );

    // In modal mode the host Dialog already constrains width/height; render the
    // bare content with a small header bar. Otherwise wrap in a Scaffold.
    if (widget.isModal) {
      return _withSaveShortcut(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Text(
                    widget.isEditing ? 'Edit snippet' : 'New snippet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: _saving ? null : _discard,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: form),
            footer,
          ],
        ),
      );
    }

    return _withSaveShortcut(
      Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit snippet' : 'New snippet'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: form,
                ),
              ),
            ),
            footer,
          ],
        ),
      ),
    );
  }

  /// Wraps [child] so Cmd/Ctrl+S triggers a save (ignored while already
  /// saving). Both `meta` (macOS) and `control` (elsewhere) are bound.
  Widget _withSaveShortcut(Widget child) {
    void save() {
      if (!_saving) _save();
    }

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): save,
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): save,
      },
      child: child,
    );
  }
}

/// Best-effort MIME type from a filename extension, used when attaching files.
/// Falls back to `application/octet-stream` for unknown types. (file_picker
/// doesn't reliably surface a MIME type cross-platform, so we infer one.)
String _mimeTypeFor(String filename) {
  final dot = filename.lastIndexOf('.');
  final ext = dot == -1 ? '' : filename.substring(dot + 1).toLowerCase();
  const map = <String, String>{
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'bmp': 'image/bmp',
    'svg': 'image/svg+xml',
    'heic': 'image/heic',
    'pdf': 'application/pdf',
    'txt': 'text/plain',
    'md': 'text/markdown',
    'json': 'application/json',
    'csv': 'text/csv',
    'zip': 'application/zip',
  };
  return map[ext] ?? 'application/octet-stream';
}

/// A small uppercase, letter-spaced Snippet-style section header with an
/// optional trailing affordance (e.g. "Markdown supported" or an action).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

/// Snippet-style formatting toolbar that inserts Markdown around the description
/// selection. Each button calls back into the editor's insertion helpers.
class _MarkdownToolbar extends StatelessWidget {
  const _MarkdownToolbar({
    required this.onHeading,
    required this.onBold,
    required this.onItalic,
    required this.onQuote,
    required this.onCode,
    required this.onLink,
    required this.onBullet,
    required this.onNumbered,
    required this.onChecklist,
  });

  final VoidCallback onHeading;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onQuote;
  final VoidCallback onCode;
  final VoidCallback onLink;
  final VoidCallback onBullet;
  final VoidCallback onNumbered;
  final VoidCallback onChecklist;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget button(IconData icon, String tooltip, VoidCallback onPressed) {
      return IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        icon: Icon(icon),
      );
    }

    Widget sep() => Container(
          width: 1,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: colorScheme.outlineVariant,
        );

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            button(Icons.title, 'Heading', onHeading),
            button(Icons.format_bold, 'Bold', onBold),
            button(Icons.format_italic, 'Italic', onItalic),
            sep(),
            button(Icons.format_quote, 'Quote', onQuote),
            button(Icons.code, 'Inline code', onCode),
            button(Icons.link, 'Link', onLink),
            sep(),
            button(Icons.format_list_bulleted, 'Bullet list', onBullet),
            button(Icons.format_list_numbered, 'Numbered list', onNumbered),
            button(Icons.checklist, 'Checklist', onChecklist),
          ],
        ),
      ),
    );
  }
}

/// Bottom-left Private/Public lock toggle bound to [SnippetVisibility].
class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.value, required this.onChanged});

  final SnippetVisibility value;
  final ValueChanged<SnippetVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrivate = value == SnippetVisibility.private;
    return TextButton.icon(
      onPressed: () => onChanged(
        isPrivate ? SnippetVisibility.public : SnippetVisibility.private,
      ),
      icon: Icon(
        isPrivate ? Icons.lock_outline : Icons.public,
        size: 18,
        color: isPrivate
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(
        isPrivate ? 'Private' : 'Public',
        style: theme.textTheme.labelLarge?.copyWith(
          color: isPrivate
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// One file row: [filename field] + [language dropdown] + remove button, with
/// the code editor underneath.
class _FileEditor extends StatelessWidget {
  const _FileEditor({
    super.key,
    required this.file,
    required this.languages,
    required this.canRemove,
    required this.onFilenameChanged,
    required this.onLanguageChanged,
    required this.onRemove,
  });

  final _FileEditState file;
  final List<Language> languages;
  final bool canRemove;
  final ValueChanged<String> onFilenameChanged;
  final ValueChanged<String?> onLanguageChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final value =
        languages.any((l) => l.id == file.languageId) ? file.languageId : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: file.filenameController,
                onChanged: onFilenameChanged,
                decoration: const InputDecoration(
                  labelText: 'Filename',
                  hintText: 'e.g. main.dart',
                  prefixIcon: Icon(Icons.insert_drive_file_outlined),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _LanguageDropdown(
                key: ValueKey(file.languageId),
                languages: languages,
                value: value,
                onChanged: onLanguageChanged,
              ),
            ),
            if (canRemove) ...[
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Remove file',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _BodyEditor(
          controller: file.contentController,
          languageId: file.languageId,
        ),
      ],
    );
  }
}

class _BodyEditor extends StatefulWidget {
  const _BodyEditor({required this.controller, required this.languageId});

  final CodeLineEditingController controller;
  final String? languageId;

  @override
  State<_BodyEditor> createState() => _BodyEditorState();
}

class _BodyEditorState extends State<_BodyEditor> {
  late final CodeFindController _findController;
  bool _wordWrap = false;

  @override
  void initState() {
    super.initState();
    _findController = CodeFindController(widget.controller);
  }

  @override
  void dispose() {
    _findController.dispose();
    super.dispose();
  }

  Language? _languageFor(String languageId) {
    final container = ProviderScope.containerOf(context, listen: false);
    return container.read(languageMapProvider)[languageId];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMap = CodeThemes.forBrightness(theme.brightness);
    final language =
        widget.languageId == null ? null : _languageFor(widget.languageId!);
    final grammar = language?.grammarId;
    final mode = grammar == null ? null : builtinAllLanguages[grammar];
    final codeBackground = themeMap['root']?.backgroundColor;
    final codeForeground = themeMap['root']?.color ?? colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Editor toolbar: language badge + name, with wrap + find controls.
          Container(
            padding: const EdgeInsets.fromLTRB(12, 2, 4, 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                LanguageBadge(languageId: widget.languageId, size: 18),
                const SizedBox(width: 8),
                Text(
                  language?.name ?? 'Plain text',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: _wordWrap ? 'Disable line wrap' : 'Wrap lines',
                  isSelected: _wordWrap,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: () => setState(() => _wordWrap = !_wordWrap),
                  icon: const Icon(Icons.wrap_text),
                ),
                IconButton(
                  tooltip: 'Find / replace',
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: _findController.findMode,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 360,
            child: CodeEditor(
              controller: widget.controller,
              findController: _findController,
              wordWrap: _wordWrap,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              indicatorBuilder:
                  (context, editingController, chunkController, notifier) {
                return Row(
                  children: [
                    DefaultCodeLineNumber(
                      controller: editingController,
                      notifier: notifier,
                    ),
                    DefaultCodeChunkIndicator(
                      width: 20,
                      controller: chunkController,
                      notifier: notifier,
                    ),
                  ],
                );
              },
              sperator: Container(width: 1, color: colorScheme.outlineVariant),
              findBuilder: (context, findController, readOnly) =>
                  CodeFindPanelView(
                controller: findController,
                readOnly: readOnly,
                inputTextColor: colorScheme.onSurface,
                resultFontColor: colorScheme.onSurfaceVariant,
                iconColor: colorScheme.onSurfaceVariant,
                iconSelectedColor: colorScheme.primary,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              style: CodeEditorStyle(
                fontSize: 13.5,
                fontFamily: kMonoFallback.first,
                fontFamilyFallback: kMonoFallback.sublist(1),
                backgroundColor: codeBackground,
                cursorColor: colorScheme.primary,
                selectionColor: colorScheme.primary.withValues(alpha: 0.30),
                cursorLineColor: codeForeground.withValues(alpha: 0.06),
                chunkIndicatorColor: codeForeground.withValues(alpha: 0.5),
                codeTheme: CodeHighlightTheme(
                  languages: {
                    if (grammar != null && mode != null)
                      grammar: CodeHighlightThemeMode(mode: mode),
                  },
                  theme: themeMap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    super.key,
    required this.languages,
    required this.value,
    required this.onChanged,
  });

  final List<Language> languages;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Searchable combobox: type to filter the (potentially long) language list.
    return DropdownMenu<String?>(
      initialSelection: value,
      requestFocusOnTap: true,
      enableFilter: true,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 320,
      label: const Text('Language'),
      hintText: 'Search languages…',
      inputDecorationTheme: Theme.of(context).inputDecorationTheme,
      leadingIcon: value == null
          ? const Icon(Icons.translate)
          : Padding(
              padding: const EdgeInsets.all(8),
              child: LanguageBadge(languageId: value, size: 18),
            ),
      onSelected: onChanged,
      dropdownMenuEntries: [
        const DropdownMenuEntry<String?>(value: null, label: 'No language'),
        for (final l in languages)
          DropdownMenuEntry<String?>(
            value: l.id,
            label: l.name,
            leadingIcon: LanguageBadge(languageId: l.id, size: 18),
          ),
      ],
    );
  }
}

class _PurposeDropdown extends StatelessWidget {
  const _PurposeDropdown({
    required this.purposes,
    required this.typeWire,
    required this.value,
    required this.onChanged,
  });

  final List<Purpose> purposes;
  final String typeWire;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final applicable = purposes.where((p) => p.appliesTo(typeWire)).toList();
    return DropdownButtonFormField<String?>(
      // Guard against the FILTERED list: the value must be one of the items,
      // or the inner DropdownButton asserts.
      initialValue: applicable.any((p) => p.id == value) ? value : null,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Purpose'),
      items: [
        const DropdownMenuItem(value: null, child: Text('No purpose')),
        for (final p in applicable)
          DropdownMenuItem(value: p.id, child: Text(p.label)),
      ],
      onChanged: onChanged,
    );
  }
}

class _CollectionDropdown extends StatelessWidget {
  const _CollectionDropdown({
    required this.collections,
    required this.value,
    required this.onChanged,
  });

  final List<Collection> collections;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Collection'),
      items: [
        const DropdownMenuItem(value: null, child: Text('No collection')),
        for (final c in collections)
          DropdownMenuItem(value: c.id, child: Text(c.name)),
      ],
      onChanged: onChanged,
    );
  }
}

class _PromptSettings extends StatelessWidget {
  const _PromptSettings({
    required this.providerController,
    required this.modelController,
    required this.systemPromptController,
    required this.temperatureController,
    required this.maxTokensController,
  });

  final TextEditingController providerController;
  final TextEditingController modelController;
  final TextEditingController systemPromptController;
  final TextEditingController temperatureController;
  final TextEditingController maxTokensController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prompt settings (optional)',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: providerController,
                decoration: const InputDecoration(
                  labelText: 'Provider',
                  hintText: 'e.g. Anthropic',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'e.g. claude-opus-4-8',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: temperatureController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Temperature'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: maxTokensController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max tokens'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: systemPromptController,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'System prompt'),
        ),
      ],
    );
  }
}
