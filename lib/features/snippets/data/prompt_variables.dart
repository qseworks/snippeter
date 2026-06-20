import '../domain/value_objects.dart';

/// Matches `{{ name }}` placeholders (identifier-style names) in a prompt body.
final RegExp _variablePattern =
    RegExp(r'\{\{\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\}\}');

/// Distinct variable names in first-seen order.
List<String> parsePromptVariableNames(String body) {
  final seen = <String>{};
  final out = <String>[];
  for (final match in _variablePattern.allMatches(body)) {
    final name = match.group(1)!;
    if (seen.add(name)) out.add(name);
  }
  return out;
}

/// Reconciles the variables currently present in [body] with any [existing]
/// metadata, preserving user-set labels/defaults and dropping stale entries.
List<PromptVariable> reconcilePromptVariables(
  String body,
  List<PromptVariable> existing,
) {
  final byName = {for (final v in existing) v.name: v};
  return [
    for (final name in parsePromptVariableNames(body))
      byName[name] ?? PromptVariable(name: name),
  ];
}
