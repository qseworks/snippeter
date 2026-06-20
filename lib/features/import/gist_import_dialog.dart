import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../snippets/application/snippet_providers.dart';
import '../snippets/domain/snippet.dart';
import 'gist_import.dart';

/// Opens the "Import from GitHub Gist" dialog.
///
/// The dialog takes a GitHub username or a gist URL/ID plus an optional personal
/// access token, fetches the matching gists via [GistImporter], shows them as a
/// checkable preview list (title + file count), and creates the selected ones as
/// snippets through [snippetRepositoryProvider]. Network / 404 / rate-limit
/// failures are surfaced inline and via a SnackBar rather than crashing.
Future<void> showGistImportDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => const _GistImportDialog(),
  );
}

/// Steps the dialog moves through: collecting input, fetching, previewing the
/// fetched drafts, or importing the selected ones.
enum _Phase { input, fetching, preview, importing }

class _GistImportDialog extends ConsumerStatefulWidget {
  const _GistImportDialog();

  @override
  ConsumerState<_GistImportDialog> createState() => _GistImportDialogState();
}

class _GistImportDialogState extends ConsumerState<_GistImportDialog> {
  final _sourceController = TextEditingController();
  final _tokenController = TextEditingController();

  _Phase _phase = _Phase.input;
  String? _error;

  /// Fetched drafts and which of them are currently selected for import.
  List<SnippetDraft> _drafts = const [];
  final Set<int> _selected = <int>{};

  @override
  void dispose() {
    _sourceController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  bool get _busy => _phase == _Phase.fetching || _phase == _Phase.importing;

  Future<void> _fetch() async {
    final source = _sourceController.text.trim();
    if (source.isEmpty) {
      setState(() => _error = 'Enter a GitHub username or a gist URL/ID.');
      return;
    }
    final token = _tokenController.text.trim();

    setState(() {
      _phase = _Phase.fetching;
      _error = null;
    });

    // A gist URL/ID looks like a path or a long hex id; a bare handle is treated
    // as a username. Heuristic: anything containing '/' or 'gist.github.com', or
    // a long hex-ish token, is a gist reference; otherwise it's a username.
    final looksLikeGist = source.contains('/') ||
        source.contains('gist.github.com') ||
        _looksLikeGistId(source);

    final importer = GistImporter();
    try {
      final drafts = await importer.fetchGists(
        username: looksLikeGist ? null : source,
        gistIdOrUrl: looksLikeGist ? source : null,
        token: token.isEmpty ? null : token,
      );
      if (!mounted) return;
      if (drafts.isEmpty) {
        setState(() {
          _phase = _Phase.input;
          _error = 'No importable gists found for that input.';
        });
        return;
      }
      setState(() {
        _drafts = drafts;
        _selected
          ..clear()
          ..addAll(List.generate(drafts.length, (i) => i));
        _phase = _Phase.preview;
        _error = null;
      });
    } on GistImportException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.input;
        _error = _friendlyError(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.input;
        _error = 'Could not reach GitHub. Check your connection and try again.';
      });
    } finally {
      importer.dispose();
    }
  }

  Future<void> _import() async {
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one gist to import.');
      return;
    }
    setState(() {
      _phase = _Phase.importing;
      _error = null;
    });

    final repo = ref.read(snippetRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final toImport = [
      for (var i = 0; i < _drafts.length; i++)
        if (_selected.contains(i)) _drafts[i],
    ];

    var created = 0;
    String? failure;
    for (final draft in toImport) {
      try {
        await repo.create(draft);
        created++;
      } catch (_) {
        failure ??= draft.title;
      }
    }

    if (!mounted) return;
    navigator.pop();
    if (failure != null && created == 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Import failed. No snippets were added.')),
      );
    } else if (failure != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Imported $created of ${toImport.length} gists; some failed.',
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Imported $created ${created == 1 ? 'gist' : 'gists'}.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width < 560 ? size.width - 32 : 520.0;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.cloud_download_outlined, size: 22),
          const SizedBox(width: 10),
          const Expanded(child: Text('Import from GitHub Gist')),
        ],
      ),
      content: SizedBox(
        width: width,
        child: _phase == _Phase.preview
            ? _buildPreview(context)
            : _buildInput(context),
      ),
      actions: _buildActions(context),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _sourceController,
          autofocus: true,
          enabled: !_busy,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'GitHub username or gist URL/ID',
            hintText: 'octocat  or  https://gist.github.com/...',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _tokenController,
          enabled: !_busy,
          obscureText: true,
          onSubmitted: (_) => _busy ? null : _fetch(),
          decoration: const InputDecoration(
            labelText: 'Personal access token (optional)',
            hintText: 'For private gists / higher rate limits',
            prefixIcon: Icon(Icons.key_outlined),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          _ErrorBanner(message: _error!),
        ],
        if (_phase == _Phase.fetching) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'Fetching gists...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${_selected.length} of ${_drafts.length} selected',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: _busy ? null : _toggleSelectAll,
              child: Text(
                _selected.length == _drafts.length
                    ? 'Deselect all'
                    : 'Select all',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 340),
          child: Scrollbar(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _drafts.length,
              itemBuilder: (context, i) {
                final draft = _drafts[i];
                final fileCount = draft.files.isEmpty ? 1 : draft.files.length;
                return CheckboxListTile(
                  dense: true,
                  value: _selected.contains(i),
                  onChanged: _busy
                      ? null
                      : (checked) => setState(() {
                            if (checked ?? false) {
                              _selected.add(i);
                            } else {
                              _selected.remove(i);
                            }
                          }),
                  title: Text(
                    draft.title.isEmpty ? '(untitled)' : draft.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '$fileCount ${fileCount == 1 ? 'file' : 'files'}'
                    '${draft.visibility.wire == 'public' ? '' : ' · private'}',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          _ErrorBanner(message: _error!),
        ],
        if (_phase == _Phase.importing) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'Importing...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (_phase == _Phase.preview) {
      return [
        TextButton(
          onPressed: _busy
              ? null
              : () => setState(() {
                    _phase = _Phase.input;
                    _error = null;
                  }),
          child: const Text('Back'),
        ),
        FilledButton.icon(
          onPressed: _busy || _selected.isEmpty ? null : _import,
          icon: const Icon(Icons.download, size: 18),
          label: Text(
            _selected.isEmpty
                ? 'Import'
                : 'Import ${_selected.length}',
          ),
        ),
      ];
    }
    return [
      TextButton(
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _busy ? null : _fetch,
        icon: const Icon(Icons.search, size: 18),
        label: const Text('Fetch'),
      ),
    ];
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selected.length == _drafts.length) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(List.generate(_drafts.length, (i) => i));
      }
    });
  }

  static bool _looksLikeGistId(String s) {
    // GitHub gist ids are long hex strings (typically 20+ chars). A bare
    // username won't match, so this only catches pasted raw ids.
    if (s.length < 16) return false;
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);
  }

  static String _friendlyError(GistImportException e) {
    switch (e.statusCode) {
      case 404:
        return 'Not found. Check the username or gist URL/ID.';
      case 401:
      case 403:
        return 'Access denied or rate-limited. Add a personal access token '
            'and try again.';
      default:
        return e.message;
    }
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
