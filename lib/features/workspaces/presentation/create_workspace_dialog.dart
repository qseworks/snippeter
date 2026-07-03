import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../application/workspace_providers.dart';

/// Prompts for a team name and creates a workspace via [workspaceServiceProvider].
///
/// On success, switches the active library to the new team and returns its id.
/// Returns null if cancelled, the name was empty, the service is unavailable
/// (signed out / offline), or creation failed (the error is surfaced inline).
Future<String?> showCreateWorkspaceDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    useRootNavigator: true,
    // Holds typed input — don't let a stray outside-tap discard it (Esc and
    // Cancel still close it).
    barrierDismissible: false,
    builder: (context) => const _CreateWorkspaceDialog(),
  );
}

class _CreateWorkspaceDialog extends ConsumerStatefulWidget {
  const _CreateWorkspaceDialog();

  @override
  ConsumerState<_CreateWorkspaceDialog> createState() =>
      _CreateWorkspaceDialogState();
}

class _CreateWorkspaceDialogState
    extends ConsumerState<_CreateWorkspaceDialog> {
  final _name = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty || _busy) return;
    final service = ref.read(workspaceServiceProvider);
    if (service == null) {
      setState(() => _error = l10n.createWorkspaceSignInError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await service.createWorkspace(name);
      if (!mounted) return;
      // Switch into the new team immediately.
      ref.read(activeWorkspaceProvider.notifier).setWorkspace(id);
      Navigator.of(context).pop(id);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l10n.createWorkspaceFailedError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // barrierDismissible is off (protects typed input from stray outside
    // taps), which also disables the route's built-in Escape handling — so
    // bind Esc explicitly: closing via the keyboard is always intentional.
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: AlertDialog(
        title: Text(l10n.createWorkspaceTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              enabled: !_busy,
              onSubmitted: (_) => _create(),
              decoration: InputDecoration(
                hintText: l10n.createWorkspaceNameHint,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: _busy ? null : _create,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.createWorkspaceCreateButton),
          ),
        ],
      ),
    );
  }
}
