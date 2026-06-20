import 'dart:convert';

import 'package:http/http.dart' as http;

import '../snippets/domain/snippet.dart';
import '../snippets/domain/snippet_type.dart';
import '../snippets/domain/value_objects.dart';

/// Imports GitHub Gists into [SnippetDraft]s, ready to be persisted via the
/// repository. The network call and the JSON→drafts mapping are deliberately
/// separated: [gistsJsonToDrafts] / [gistJsonToDraft] are pure functions so the
/// mapping can be unit-tested without touching the network.
class GistImporter {
  GistImporter({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _apiBase = 'https://api.github.com';

  /// Fetches gists from GitHub and maps them to drafts.
  ///
  /// Exactly one of [username] or [gistIdOrUrl] should be provided:
  ///   - [username]    -> GET /users/{user}/gists (the user's public gists)
  ///   - [gistIdOrUrl] -> GET /gists/{id} (a single gist; id extracted from URL)
  ///
  /// When [token] is provided it is sent as a Bearer token (lets you read your
  /// own private gists / raises the rate limit); otherwise the call is anonymous.
  Future<List<SnippetDraft>> fetchGists({
    String? username,
    String? gistIdOrUrl,
    String? token,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/vnd.github+json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    if (gistIdOrUrl != null && gistIdOrUrl.trim().isNotEmpty) {
      final id = extractGistId(gistIdOrUrl);
      final res =
          await _client.get(Uri.parse('$_apiBase/gists/$id'), headers: headers);
      _ensureOk(res);
      final json = jsonDecode(res.body);
      final draft = gistJsonToDraft(json as Map<String, dynamic>);
      return draft == null ? const [] : [draft];
    }

    if (username != null && username.trim().isNotEmpty) {
      final res = await _client.get(
        Uri.parse('$_apiBase/users/${username.trim()}/gists'),
        headers: headers,
      );
      _ensureOk(res);
      final json = jsonDecode(res.body) as List<dynamic>;
      return gistsJsonToDrafts(json);
    }

    throw ArgumentError('Provide either a username or a gist id/URL.');
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw GistImportException(
        'GitHub API request failed (${res.statusCode}).',
        statusCode: res.statusCode,
      );
    }
  }

  void dispose() => _client.close();
}

/// Thrown when the GitHub API returns a non-success status.
class GistImportException implements Exception {
  GistImportException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'GistImportException: $message';
}

/// Extracts the gist id from a raw id or a gist URL such as
/// `https://gist.github.com/user/<id>` or `https://gist.github.com/<id>`.
String extractGistId(String idOrUrl) {
  final trimmed = idOrUrl.trim();
  if (!trimmed.contains('/')) return trimmed;
  final uri = Uri.tryParse(trimmed);
  final segments = (uri?.pathSegments ?? trimmed.split('/'))
      .where((s) => s.isNotEmpty)
      .toList();
  if (segments.isEmpty) return trimmed;
  // The id is the last non-empty path segment (handles user/<id> and /<id>).
  return segments.last;
}

/// PURE: maps a list of gist JSON objects to drafts. Skips entries that map to
/// nothing (e.g. a gist with no readable files).
List<SnippetDraft> gistsJsonToDrafts(List<dynamic> json) {
  final drafts = <SnippetDraft>[];
  for (final entry in json) {
    if (entry is! Map<String, dynamic>) continue;
    final draft = gistJsonToDraft(entry);
    if (draft != null) drafts.add(draft);
  }
  return drafts;
}

/// PURE: maps a single gist JSON object to a [SnippetDraft], or null if it has
/// no files to import.
SnippetDraft? gistJsonToDraft(Map<String, dynamic> gist) {
  final id = (gist['id'] as String?) ?? '';
  final filesMap = gist['files'];
  final files = <SnippetFileDraft>[];
  if (filesMap is Map<String, dynamic>) {
    for (final entry in filesMap.entries) {
      final file = entry.value;
      if (file is! Map<String, dynamic>) continue;
      final name = (file['filename'] as String?) ?? entry.key;
      final content = (file['content'] as String?) ?? '';
      files.add(
        SnippetFileDraft(
          filename: name,
          languageId: gistLanguageToId(file['language'] as String?),
          content: content,
        ),
      );
    }
  }
  if (files.isEmpty) return null;

  final description = (gist['description'] as String?)?.trim() ?? '';
  final title = description.isNotEmpty
      ? description
      : (files.first.filename.isNotEmpty ? files.first.filename : 'Gist $id');

  final isPublic = gist['public'] == true;

  return SnippetDraft(
    title: title,
    body: files.first.content,
    type: SnippetType.code,
    languageId: files.first.languageId,
    files: files,
    visibility:
        isPublic ? SnippetVisibility.public : SnippetVisibility.private,
  );
}

/// Maps a GitHub-reported language name (e.g. "Python", "Shell") to our internal
/// language slug, or null if there is no confident match.
String? gistLanguageToId(String? githubLanguage) {
  if (githubLanguage == null) return null;
  final key = githubLanguage.trim().toLowerCase();
  if (key.isEmpty) return null;
  return _githubLanguageToId[key];
}

/// GitHub language name (lowercased) -> our seeded language slug. Covers the
/// languages we seed plus common GitHub naming variations.
const Map<String, String> _githubLanguageToId = {
  'python': 'python',
  'javascript': 'javascript',
  'typescript': 'typescript',
  'dart': 'dart',
  'go': 'go',
  'rust': 'rust',
  'java': 'java',
  'kotlin': 'kotlin',
  'swift': 'swift',
  'c': 'c',
  'c++': 'cpp',
  'cpp': 'cpp',
  'c#': 'csharp',
  'csharp': 'csharp',
  'php': 'php',
  'ruby': 'ruby',
  'sql': 'sql',
  'plpgsql': 'sql',
  'shell': 'bash',
  'bash': 'bash',
  'zsh': 'bash',
  'shellscript': 'bash',
  'html': 'html',
  'css': 'css',
  'json': 'json',
  'yaml': 'yaml',
  'markdown': 'markdown',
  'text': 'plaintext',
};
