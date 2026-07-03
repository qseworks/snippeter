import 'dart:developer' as developer;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/all.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../../../core/highlight/code_themes.dart';
import '../../../core/highlight/language_detect.dart';
import '../../../core/highlight/language_visuals.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/code_view.dart';
import '../../settings/application/settings_providers.dart';
import '../../workspaces/application/workspace_providers.dart';
import '../application/snippet_providers.dart';
import '../domain/snippet.dart';
import '../domain/snippet_type.dart';
import '../domain/value_objects.dart';
import 'type_visuals.dart';
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

  /// Focus node for the filename field, so a freshly-added file can grab the
  /// caret (see [_SnippetEditorScreenState._addFile]).
  final FocusNode filenameFocusNode = FocusNode();
  String? languageId;
  bool overridden;

  void dispose() {
    filenameController.dispose();
    contentController.dispose();
    filenameFocusNode.dispose();
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

  /// Drives the scrolling file list so adding a file can reveal it (see
  /// [_addFile]). Shared across layouts; only one files scroll view is mounted
  /// at a time, so it is never attached to two positions simultaneously.
  final ScrollController _filesScrollController = ScrollController();

  /// Focus node for the title. A fresh snippet requests focus here in a
  /// post-frame callback (declarative `autofocus` loses to the code editor,
  /// which claims focus on web inside a freshly-pushed dialog route).
  final FocusNode _titleFocusNode = FocusNode();

  /// Signature of the editable state when the editor opened — captured after
  /// load (editing) or in initState (new). Used to detect unsaved changes
  /// before discarding.
  String _initialSnapshot = '';

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
  bool _attaching = false;
  SnippetVisibility _visibility = SnippetVisibility.private;

  /// The library this snippet belongs to. For an existing snippet this is
  /// captured on load so editing never moves it between libraries; for a new
  /// snippet it is stamped from the active workspace at save time (null =
  /// personal, preserving the signed-out offline behavior exactly).
  String? _workspaceId;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loading = true;
      _load();
    } else {
      // New snippet: pre-select the user's default language, if set.
      _files.first.languageId = ref.read(settingsProvider).defaultLanguageId;
      _initialSnapshot = _snapshot();
      // Drop the caret in the title once laid out — a post-frame request wins
      // over the code editor, which otherwise grabs focus on open.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _titleFocusNode.requestFocus();
      });
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
      _workspaceId = snippet.workspaceId;

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
    _initialSnapshot = _snapshot();
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
    _filesScrollController.dispose();
    _titleFocusNode.dispose();
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
    // After the new editor is laid out, scroll it into view (when the list is
    // scrollable) and drop the caret in its filename field for quick typing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_filesScrollController.hasClients) {
        _filesScrollController.animateTo(
          _filesScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
      _files.last.filenameFocusNode.requestFocus();
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
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.editorTitleRequiredSnack)),
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
    // Existing snippets keep the library captured on load; new snippets land in
    // the active library (null = personal, matching the offline/signed-out path).
    final workspaceId =
        widget.isEditing ? _workspaceId : ref.read(activeWorkspaceProvider);
    final draft = SnippetDraft(
      title: title,
      workspaceId: workspaceId,
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
    // Captured before the write: the modal/route is gone when the toast fires.
    final messenger = ScaffoldMessenger.of(context);
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
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.editorSavedSnack),
        duration: const Duration(seconds: 2),
      ));
    } catch (error, stackTrace) {
      developer.log('save failed',
          name: 'editor', error: error, stackTrace: stackTrace);
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.editorCouldNotSaveSnack)));
      }
    }
  }

  /// A signature of every editable field, compared against [_initialSnapshot]
  /// to tell whether the user has unsaved changes.
  String _snapshot() {
    final b = StringBuffer()
      ..writeln(_titleController.text)
      ..writeln(_descriptionController.text)
      ..writeln(_type.name)
      ..writeln(_purpose ?? '')
      ..writeln(_collectionId ?? '')
      ..writeln(_visibility.name)
      ..writeln(_workspaceId ?? '')
      ..writeln(_labels.join(''))
      ..writeln(_modelController.text)
      ..writeln(_providerController.text)
      ..writeln(_systemPromptController.text)
      ..writeln(_temperatureController.text)
      ..writeln(_maxTokensController.text);
    for (final f in _files) {
      b
        ..writeln(f.filenameController.text)
        ..writeln(f.languageId ?? '')
        ..writeln(f.contentController.text);
    }
    return b.toString();
  }

  bool get _isDirty => _snapshot() != _initialSnapshot;

  /// Confirm before throwing away unsaved edits — matching the intent of the
  /// non-dismissible barrier set by [showSnippetEditor].
  Future<bool> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editorDiscardTitle),
        content: Text(l10n.editorDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDiscard),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _discard() async {
    if (_isDirty && !await _confirmDiscard()) return;
    if (!mounted) return;
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
    final l10n = AppLocalizations.of(context);
    final snippetId = widget.snippetId;
    if (snippetId == null || _attaching) return;
    _attaching = true;
    try {
      await _attachFilesInner(l10n, snippetId);
    } finally {
      _attaching = false;
    }
  }

  Future<void> _attachFilesInner(AppLocalizations l10n, String snippetId) async {
    final FilePickerResult? result;
    try {
      // file_picker 12.x: pickFiles is multi-select by default; load each
      // file's bytes on demand via readAsBytes() (the withData parameter is
      // deprecated).
      result = await FilePicker.pickFiles();
    } catch (error, stackTrace) {
      developer.log('file picker failed',
          name: 'editor', error: error, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.editorCouldNotPickFilesSnack)));
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
      } catch (error, stackTrace) {
        developer.log('attach failed',
            name: 'editor', error: error, stackTrace: stackTrace);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.editorCouldNotAttachSnack(file.name))),
          );
        }
      }
    }
    if (mounted && added > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.editorAttachedFilesSnack(added)),
        ),
      );
    }
  }

  Future<void> _createCollection() async {
    final controller = TextEditingController();
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l10n.editorNewCollectionDialogTitle),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.commonName),
              onSubmitted: (v) => Navigator.pop(context, v),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(l10n.commonCreate),
              ),
            ],
          );
        },
      );
      if (name != null && name.trim().isNotEmpty) {
        final id = await ref
            .read(snippetRepositoryProvider)
            .createCollection(name.trim());
        if (mounted) setState(() => _collectionId = id);
      }
    } finally {
      controller.dispose();
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
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      const indicator = AppLoader();
      return widget.isModal ? indicator : const Scaffold(body: indicator);
    }

    final languages = ref.watch(languagesProvider).value ?? const [];
    final purposes = ref.watch(purposesProvider).value ?? const [];
    final collections = ref.watch(collectionsProvider).value ?? const [];
    final labelSuggestions = [
      for (final l in ref.watch(labelsProvider).value ?? const <Label>[]) l.name,
    ];

    // ---------- Metadata (everything except the file/code editors) ----------
    final metaChildren = <Widget>[
      // Big Snippet-style title field.
      TextField(
        controller: _titleController,
        // Fresh snippet: focus is requested in initState (post-frame) so the
        // caret lands here reliably; when editing, focus is left alone.
        focusNode: _titleFocusNode,
        textInputAction: TextInputAction.next,
        style: theme.textTheme.headlineSmall,
        decoration: InputDecoration(
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: l10n.editorTitleHint,
          hintStyle: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      const Divider(height: 18),
      _SectionHeader(title: l10n.editorSectionType),
      const SizedBox(height: 8),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: SegmentedButton<SnippetType>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: SnippetType.code,
              label: Text(l10n.editorTypeCode),
              icon: const Icon(Icons.code),
            ),
            ButtonSegment(
              value: SnippetType.aiPrompt,
              label: Text(l10n.editorTypeAiPrompt),
              icon: const Icon(Icons.smart_toy_outlined),
            ),
            ButtonSegment(
              value: SnippetType.text,
              label: Text(l10n.editorTypeText),
              icon: const Icon(Icons.notes),
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
      ),
      const SizedBox(height: 16),
      _SectionHeader(
        title: l10n.editorSectionDescription,
        trailing: Text(
          l10n.editorMarkdownSupportedLabel,
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
        minLines: 2,
        maxLines: 6,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: l10n.editorDescriptionHint,
        ),
      ),
      const SizedBox(height: 16),
      // Purpose + Collection share one row to keep the metadata compact.
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _PurposeDropdown(
              purposes: purposes,
              typeWire: _type.wire,
              value: purposes.any((p) => p.id == _purpose) ? _purpose : null,
              onChanged: (v) => setState(() => _purpose = v),
            ),
          ),
          const SizedBox(width: 12),
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
            tooltip: l10n.editorNewCollectionTooltip,
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
    ];

    // AI-only tip + prompt settings; rendered alongside the metadata. Wrapped in
    // an AnimatedSize so the block eases in/out as the type switches instead of
    // popping.
    final aiChildren = <Widget>[
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        child: _type == SnippetType.aiPrompt
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n.editorAiVariableTip('{{variable}}'),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  _PromptSettings(
                    providerController: _providerController,
                    modelController: _modelController,
                    systemPromptController: _systemPromptController,
                    temperatureController: _temperatureController,
                    maxTokensController: _maxTokensController,
                  ),
                ],
              )
            : const SizedBox(width: double.infinity),
      ),
    ];

    // ---------- FILES ----------
    final filesHeader = _SectionHeader(
      title: l10n.editorSectionFiles,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ATTACH: pick binary files and attach them. Only meaningful once the
          // snippet exists (needs an id); disabled with a tooltip otherwise.
          Tooltip(
            message: widget.isEditing
                ? l10n.editorAttachFilesTooltip
                : l10n.editorAttachFilesDisabledTooltip,
            child: TextButton.icon(
              onPressed: widget.isEditing ? _attachFiles : null,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.attach_file, size: 18),
              label: Text(l10n.editorAttachButton),
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
            label: Text(l10n.editorAddFileButton),
          ),
        ],
      ),
    );

    _FileEditor fileEditorAt(int i, {double? editorHeight, bool expand = false}) {
      return _FileEditor(
        key: ObjectKey(_files[i]),
        file: _files[i],
        languages: languages,
        canRemove: _files.length > 1,
        editorHeight: editorHeight,
        expandEditor: expand,
        onFilenameChanged: (name) => _onFilenameChanged(_files[i], name),
        onLanguageChanged: (id) => _onLanguagePicked(_files[i], id),
        onRemove: () => _removeFile(i),
      );
    }

    // Stacked, fixed-height file editors (single-column layouts). The editors
    // live inside an AnimatedSize so adding/removing a file eases the column's
    // height instead of popping.
    List<Widget> filesColumn() => [
          filesHeader,
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _files.length; i++) ...[
                  fileEditorAt(i, editorHeight: 360),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ];

    // Right pane for the wide modal. The editors share the available height when
    // they each still get a comfortable amount of room (so the first editor no
    // longer abruptly shrinks the moment a second file is added); once they
    // would be squeezed below that, fall back to fixed-height scrolling.
    Widget filesPane() {
      const minSharedHeight = 280.0;
      const gap = 16.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          filesHeader,
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = _files.length;
                final perEditor =
                    (constraints.maxHeight - gap * (count - 1)) / count;
                if (perEditor >= minSharedHeight) {
                  // Editors fill the pane and share the height — no scroll, no
                  // lurch when going from one file to a few.
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < count; i++) ...[
                        Expanded(child: fileEditorAt(i, expand: true)),
                        if (i < count - 1) const SizedBox(height: gap),
                      ],
                    ],
                  );
                }
                // Too many files to share comfortably: fixed-height editors that
                // scroll, easing height changes as files come and go.
                return SingleChildScrollView(
                  controller: _filesScrollController,
                  padding: EdgeInsets.zero,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < count; i++) ...[
                          fileEditorAt(i, editorHeight: 320),
                          const SizedBox(height: gap),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // One scrolling column — used by the non-modal route and the narrow modal.
    Widget singleColumn() => ListView(
          controller: _filesScrollController,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            ...metaChildren,
            const SizedBox(height: 20),
            ...filesColumn(),
            ...aiChildren,
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
          // Flexible so a long visibility label ellipsizes instead of pushing
          // Discard/Save off the edge on a narrow footer.
          Flexible(
            child: _VisibilityToggle(
              value: _visibility,
              onChanged: (v) => setState(() => _visibility = v),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _saving ? null : _discard,
            child: Text(l10n.commonDiscard),
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
            label: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    // In modal mode the host Dialog constrains width/height. On a wide modal we
    // split metadata (left) from the file/code editor (right) so the editor is
    // visible without scrolling; a narrow modal falls back to one column.
    if (widget.isModal) {
      return _withSaveShortcut(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ModalHeader(
              type: _type,
              isEditing: widget.isEditing,
              onClose: _saving ? null : _discard,
            ),
            const Divider(height: 1),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 880) return singleColumn();
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 440,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 18, 18, 20),
                          children: [...metaChildren, ...aiChildren],
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 20, 16),
                          child: filesPane(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            footer,
          ],
        ),
      );
    }

    return _withSaveShortcut(
      Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing
              ? l10n.editorAppBarEditTitle
              : l10n.editorAppBarNewTitle),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: singleColumn(),
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

/// The modal's top bar: a brand-gradient mark carrying the current snippet
/// type's glyph (it morphs as you switch Code / AI Prompt / Text), the title,
/// a one-line subtitle, and a close button.
class _ModalHeader extends StatelessWidget {
  const _ModalHeader({
    required this.type,
    required this.isEditing,
    required this.onClose,
  });

  final SnippetType type;
  final bool isEditing;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient(theme.brightness),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                iconForType(type),
                key: ValueKey(type),
                size: 19,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing
                      ? l10n.editorModalHeaderEditTitle
                      : l10n.editorModalHeaderNewTitle,
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  isEditing
                      ? l10n.editorModalHeaderEditSubtitle
                      : l10n.editorModalHeaderNewSubtitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n.commonClose,
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
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
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
    final l10n = AppLocalizations.of(context);

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
            button(Icons.title, l10n.editorMarkdownHeadingTooltip, onHeading),
            button(Icons.format_bold, l10n.editorMarkdownBoldTooltip, onBold),
            button(
                Icons.format_italic, l10n.editorMarkdownItalicTooltip, onItalic),
            sep(),
            button(Icons.format_quote, l10n.editorMarkdownQuoteTooltip, onQuote),
            button(Icons.code, l10n.editorMarkdownInlineCodeTooltip, onCode),
            button(Icons.link, l10n.editorMarkdownLinkTooltip, onLink),
            sep(),
            button(Icons.format_list_bulleted,
                l10n.editorMarkdownBulletListTooltip, onBullet),
            button(Icons.format_list_numbered,
                l10n.editorMarkdownNumberedListTooltip, onNumbered),
            button(Icons.checklist, l10n.editorMarkdownChecklistTooltip,
                onChecklist),
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
    final l10n = AppLocalizations.of(context);
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
        isPrivate ? l10n.editorVisibilityPrivate : l10n.editorVisibilityPublic,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
    this.editorHeight,
    this.expandEditor = false,
  });

  final _FileEditState file;
  final List<Language> languages;
  final bool canRemove;
  final ValueChanged<String> onFilenameChanged;
  final ValueChanged<String?> onLanguageChanged;
  final VoidCallback onRemove;

  /// Fixed editor height (single-column / stacked layouts). Ignored when
  /// [expandEditor] is true.
  final double? editorHeight;

  /// When true the code editor fills the remaining vertical space (used in the
  /// wide modal's right pane so the editor is visible without scrolling). The
  /// parent must give this widget a bounded height (e.g. wrap it in Expanded).
  final bool expandEditor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                focusNode: file.filenameFocusNode,
                onChanged: onFilenameChanged,
                decoration: InputDecoration(
                  labelText: l10n.editorFilenameLabel,
                  hintText: l10n.editorFilenameHint,
                  prefixIcon: const Icon(Icons.insert_drive_file_outlined),
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
                tooltip: l10n.editorRemoveFileTooltip,
                onPressed: onRemove,
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (expandEditor)
          Expanded(
            child: _BodyEditor(
              controller: file.contentController,
              languageId: file.languageId,
            ),
          )
        else
          _BodyEditor(
            controller: file.contentController,
            languageId: file.languageId,
            height: editorHeight ?? 360,
          ),
      ],
    );
  }
}

class _BodyEditor extends StatefulWidget {
  const _BodyEditor({
    required this.controller,
    required this.languageId,
    this.height,
  });

  final CodeLineEditingController controller;
  final String? languageId;

  /// Fixed editor height; when null the editor fills the available space
  /// (parent must provide a bounded height).
  final double? height;

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
    final l10n = AppLocalizations.of(context);
    final colorScheme = theme.colorScheme;
    final themeMap = CodeThemes.forBrightness(theme.brightness);
    final language =
        widget.languageId == null ? null : _languageFor(widget.languageId!);
    final grammar = language?.grammarId;
    final mode = grammar == null ? null : builtinAllLanguages[grammar];
    final codeBackground = themeMap['root']?.backgroundColor;
    final codeForeground = themeMap['root']?.color ?? colorScheme.onSurface;

    // Keep the code editor (body, line-number gutter, and chunk indicator)
    // left-to-right even in an RTL locale so code reads correctly.
    final codeEditor = Directionality(
      textDirection: TextDirection.ltr,
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
      findBuilder: (context, findController, readOnly) => CodeFindPanelView(
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
    );

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
            padding: const EdgeInsetsDirectional.fromSTEB(12, 2, 4, 2),
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
                Flexible(
                  child: Text(
                    language?.name ?? l10n.editorPlainTextLanguage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: _wordWrap
                      ? l10n.editorDisableLineWrapTooltip
                      : l10n.editorWrapLinesTooltip,
                  isSelected: _wordWrap,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: () => setState(() => _wordWrap = !_wordWrap),
                  icon: const Icon(Icons.wrap_text),
                ),
                IconButton(
                  tooltip: l10n.editorFindReplaceTooltip,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: _findController.findMode,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          if (widget.height != null)
            SizedBox(height: widget.height, child: codeEditor)
          else
            Expanded(child: codeEditor),
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
    final l10n = AppLocalizations.of(context);
    // Searchable combobox: type to filter the (potentially long) language list.
    return DropdownMenu<String?>(
      initialSelection: value,
      requestFocusOnTap: true,
      enableFilter: true,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 320,
      label: Text(l10n.editorLanguageDropdownLabel),
      hintText: l10n.editorLanguageSearchHint,
      inputDecorationTheme: Theme.of(context).inputDecorationTheme,
      // Both states use the same 18px-in-8px-padding leading box so the field
      // text doesn't shift when a language is picked.
      leadingIcon: value == null
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.translate, size: 18),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: LanguageBadge(languageId: value, size: 18),
            ),
      onSelected: onChanged,
      dropdownMenuEntries: [
        DropdownMenuEntry<String?>(
            value: null, label: l10n.editorNoLanguageOption),
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
    final l10n = AppLocalizations.of(context);
    final applicable = purposes.where((p) => p.appliesTo(typeWire)).toList();
    return DropdownButtonFormField<String?>(
      // Guard against the FILTERED list: the value must be one of the items,
      // or the inner DropdownButton asserts.
      initialValue: applicable.any((p) => p.id == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.editorPurposeLabel),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.editorNoPurposeOption)),
        for (final p in applicable)
          DropdownMenuItem(
              value: p.id,
              child: Text(labelForPurpose(l10n, p.id, fallback: p.label))),
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
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.editorCollectionLabel),
      items: [
        DropdownMenuItem(
            value: null, child: Text(l10n.editorNoCollectionOption)),
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.editorPromptSettingsHeader,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: providerController,
                decoration: InputDecoration(
                  labelText: l10n.editorPromptProviderLabel,
                  hintText: l10n.editorPromptProviderHint,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: modelController,
                decoration: InputDecoration(
                  labelText: l10n.editorPromptModelLabel,
                  hintText: l10n.editorPromptModelHint,
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
                decoration:
                    InputDecoration(labelText: l10n.editorPromptTemperatureLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: maxTokensController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: l10n.editorPromptMaxTokensLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: systemPromptController,
          minLines: 2,
          maxLines: 5,
          decoration:
              InputDecoration(labelText: l10n.editorPromptSystemPromptLabel),
        ),
      ],
    );
  }
}
