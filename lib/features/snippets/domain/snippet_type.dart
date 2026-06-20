/// The kind of a snippet. [wire] is the stable string persisted in the database
/// and (later) synced to Postgres — never change these values.
enum SnippetType {
  code('code', 'Code'),
  aiPrompt('ai_prompt', 'AI Prompt'),
  text('text', 'Text');

  const SnippetType(this.wire, this.label);

  final String wire;
  final String label;

  static SnippetType fromWire(String wire) =>
      values.firstWhere((e) => e.wire == wire, orElse: () => SnippetType.text);
}
