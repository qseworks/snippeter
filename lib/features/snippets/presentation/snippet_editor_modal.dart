import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'snippet_editor_screen.dart';

/// Opens the snippet editor as a large centered modal dialog.
///
/// Pass [snippetId] to edit an existing snippet, or omit it to create a new one.
/// The editor renders with `isModal: true` so a successful save and the
/// Discard/close actions pop this dialog (via the root navigator); the
/// underlying list/detail update reactively from their streams.
///
/// The barrier is non-dismissible so an accidental outside tap can't drop
/// in-progress edits — the user must use Discard/Save/close.
Future<void> showSnippetEditor(
  BuildContext context, {
  String? snippetId,
}) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      // Fill most of the window so the two-pane editor (metadata on the left,
      // the code editor on the right) has room without scrolling, while keeping
      // a slim margin and a sensible cap on very large/ultrawide displays.
      final width = size.width < 720 ? size.width : (size.width * 0.96).clamp(0, 1500).toDouble();
      final height = (size.height * 0.96).clamp(0, 1400).toDouble();
      return Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: SnippetEditorScreen(
            snippetId: snippetId,
            isModal: true,
          ),
        ),
      );
    },
  );
}
