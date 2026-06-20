import '../../features/snippets/domain/value_objects.dart';

/// Resolves a [Language] from a [filename]'s extension. Extracts the substring
/// after the last '.', then matches (case-insensitively) against each
/// language's [Language.fileExtension] (which includes the leading dot) and its
/// aliases. Returns null when there is no extension or no match.
Language? detectLanguageFromFilename(
  String filename,
  Iterable<Language> languages,
) {
  final name = filename.trim();
  final dot = name.lastIndexOf('.');
  // No dot, or a leading dot with nothing after it (e.g. '.gitignore' -> no ext,
  // 'foo.' -> empty ext) means there is no usable extension.
  if (dot < 0 || dot == name.length - 1) return null;
  final ext = name.substring(dot + 1).toLowerCase(); // without the dot
  final dotted = '.$ext'; // with the dot, to match fileExtension

  for (final lang in languages) {
    if (lang.fileExtension.toLowerCase() == dotted) return lang;
    for (final alias in lang.aliases) {
      if (alias.toLowerCase() == ext) return lang;
    }
  }
  return null;
}
