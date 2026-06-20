import 'package:flutter/material.dart';

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
      // Fill most of the window so the whole editor (description + all files +
      // prompt settings) is visible, while keeping a small margin and a sensible
      // cap on very large/ultrawide displays.
      final width = size.width < 720 ? size.width : (size.width * 0.94).clamp(0, 1280).toDouble();
      final height = (size.height * 0.94).clamp(0, 1100).toDouble();
      return Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(16),
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
