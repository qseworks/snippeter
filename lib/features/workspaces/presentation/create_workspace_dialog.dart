import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final name = _name.text.trim();
    if (name.isEmpty || _busy) return;
    final service = ref.read(workspaceServiceProvider);
    if (service == null) {
      setState(() => _error = 'Sign in to create a team.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await service.createWorkspace(name);
      // Switch into the new team immediately.
      ref.read(activeWorkspaceProvider.notifier).setWorkspace(id);
      if (mounted) Navigator.of(context).pop(id);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = "Couldn't create the team — you may be offline.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('New team'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            enabled: !_busy,
            onSubmitted: (_) => _create(),
            decoration: const InputDecoration(hintText: 'Team name'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
