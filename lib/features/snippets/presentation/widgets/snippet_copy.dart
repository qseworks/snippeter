import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/snippet.dart';
import '../../domain/value_objects.dart';

/// Pure text builders + a reusable copy affordance backing the "quick-copy
/// everywhere" surface (row button, detail menu). They turn the 3-click
/// detail→scroll→copy drill-down into a single tap.

/// The primary text to copy for a snippet: the first file's content, falling
/// back to the denormalized body for legacy single-body snippets.
String snippetPrimaryText(Snippet snippet) =>
    snippet.files.isNotEmpty ? snippet.files.first.content : snippet.body;

/// Every file's content concatenated. Multi-file snippets get a `// filename`
/// header above each block; single-file/legacy snippets return the raw content.
String snippetAllFilesText(Snippet snippet) {
  final files = snippet.files;
  if (files.isEmpty) return snippet.body;
  if (files.length == 1) return files.first.content;
  return files.map((f) {
    final name = f.filename.trim();
    return name.isEmpty ? f.content : '// $name\n${f.content}';
  }).join('\n\n');
}

/// A Markdown rendering of the snippet: an H1 title, optional description, then
/// one fenced code block per file tagged with its highlight grammar so it
/// renders with syntax highlighting on GitHub / in editors.
String snippetMarkdown(Snippet snippet, Map<String, Language> languageMap) {
  final buffer = StringBuffer();
  final title = snippet.title.trim();
  if (title.isNotEmpty) buffer.writeln('# $title\n');
  final description = snippet.description?.trim();
  if (description != null && description.isNotEmpty) {
    buffer.writeln('$description\n');
  }

  final files = snippet.files.isNotEmpty
      ? snippet.files
      : [
          SnippetFile(
            id: '',
            content: snippet.body,
            languageId: snippet.languageId,
          ),
        ];
  for (var i = 0; i < files.length; i++) {
    final f = files[i];
    final name = f.filename.trim();
    if (name.isNotEmpty) buffer.writeln('**$name**\n');
    buffer.writeln('```${_fenceToken(f.languageId, languageMap)}');
    buffer.writeln(f.content);
    buffer.writeln('```');
    if (i < files.length - 1) buffer.writeln();
  }
  return buffer.toString().trimRight();
}

String _fenceToken(String? languageId, Map<String, Language> languageMap) {
  if (languageId == null) return '';
  return languageMap[languageId]?.grammarId ?? languageId;
}

/// Copies [text] to the clipboard and surfaces [message] via the nearest
/// [ScaffoldMessenger]. Shared by every quick-copy entry point so the feedback
/// is identical everywhere.
Future<void> copyWithFeedback(
  BuildContext context,
  String text,
  String message,
) async {
  final messenger = ScaffoldMessenger.of(context);
  await Clipboard.setData(ClipboardData(text: text));
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
}

/// A compact icon button that copies [text] on tap, briefly flips to a check
/// mark, and shows a "copied" snackbar. Used on the snippet row so the most
/// frequent action is one keystroke away.
class CopyIconButton extends StatefulWidget {
  const CopyIconButton({
    super.key,
    required this.text,
    required this.tooltip,
    required this.copiedMessage,
    this.iconSize = 18,
  });

  final String text;
  final String tooltip;
  final String copiedMessage;
  final double iconSize;

  @override
  State<CopyIconButton> createState() => _CopyIconButtonState();
}

class _CopyIconButtonState extends State<CopyIconButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await copyWithFeedback(context, widget.text, widget.copiedMessage);
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: widget.iconSize,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      tooltip: widget.tooltip,
      onPressed: _copy,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          _copied ? Icons.check_rounded : Icons.copy_rounded,
          key: ValueKey<bool>(_copied),
          color: _copied ? AppTheme.accent : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
