// Plain seed data (no Drift dependency). Inserted on first database creation.

class SeedLanguage {
  const SeedLanguage(
    this.id,
    this.name,
    this.extension,
    this.grammarId, [
    this.aliases = const [],
  ]);

  final String id;
  final String name;
  final String extension;
  final String grammarId;
  final List<String> aliases;
}

/// Launch language set. `grammarId` matches a highlight.js grammar name so the
/// highlighter can resolve it; `extension` drives source-file export.
const List<SeedLanguage> seedLanguages = [
  SeedLanguage('python', 'Python', '.py', 'python', ['py', 'python3']),
  SeedLanguage('javascript', 'JavaScript', '.js', 'javascript', ['js', 'node']),
  SeedLanguage('typescript', 'TypeScript', '.ts', 'typescript', ['ts']),
  SeedLanguage('dart', 'Dart', '.dart', 'dart'),
  SeedLanguage('go', 'Go', '.go', 'go', ['golang']),
  SeedLanguage('rust', 'Rust', '.rs', 'rust', ['rs']),
  SeedLanguage('java', 'Java', '.java', 'java'),
  SeedLanguage('kotlin', 'Kotlin', '.kt', 'kotlin'),
  SeedLanguage('swift', 'Swift', '.swift', 'swift'),
  SeedLanguage('c', 'C', '.c', 'c'),
  SeedLanguage('cpp', 'C++', '.cpp', 'cpp', ['c++']),
  SeedLanguage('csharp', 'C#', '.cs', 'csharp', ['cs']),
  SeedLanguage('php', 'PHP', '.php', 'php'),
  SeedLanguage('ruby', 'Ruby', '.rb', 'ruby', ['rb']),
  SeedLanguage('sql', 'SQL', '.sql', 'sql'),
  SeedLanguage('bash', 'Shell', '.sh', 'bash', ['sh', 'shell', 'zsh']),
  SeedLanguage('html', 'HTML', '.html', 'xml', ['htm']),
  SeedLanguage('css', 'CSS', '.css', 'css'),
  SeedLanguage('json', 'JSON', '.json', 'json'),
  SeedLanguage('yaml', 'YAML', '.yaml', 'yaml', ['yml']),
  SeedLanguage('markdown', 'Markdown', '.md', 'markdown', ['md']),
  SeedLanguage('plaintext', 'Plain Text', '.txt', 'plaintext', ['text', 'txt']),
];

class SeedPurpose {
  const SeedPurpose(this.id, this.label, [this.appliesToType]);

  final String id;
  final String label;

  /// Comma-separated snippet types this purpose suits, or null for "any".
  final String? appliesToType;
}

const List<SeedPurpose> seedPurposes = [
  SeedPurpose('utility', 'Utility'),
  SeedPurpose('boilerplate', 'Boilerplate'),
  SeedPurpose('algorithm', 'Algorithm'),
  SeedPurpose('regex', 'Regex'),
  SeedPurpose('sql-query', 'SQL Query'),
  SeedPurpose('config', 'Configuration'),
  SeedPurpose('reference', 'Reference'),
  SeedPurpose('prompt-coding', 'Coding Prompt', 'ai_prompt'),
  SeedPurpose('prompt-summarization', 'Summarization Prompt', 'ai_prompt'),
  SeedPurpose('prompt-system', 'System Prompt', 'ai_prompt'),
];
