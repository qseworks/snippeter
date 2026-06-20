import 'dart:convert';
import 'dart:typed_data';

/// A programming language: maps a slug -> display name -> file extension ->
/// highlight grammar id. Seeded, user-extendable.
class Language {
  const Language({
    required this.id,
    required this.name,
    required this.fileExtension,
    required this.grammarId,
    this.aliases = const [],
  });

  final String id;
  final String name;
  final String fileExtension; // includes the dot, e.g. '.py'
  final String grammarId; // highlight.js grammar id
  final List<String> aliases;
}

/// Whether a snippet is visible only to its owner ([private]) or shared
/// ([public]). [wire] is the stable string persisted in the database and synced
/// to Postgres — never change these values.
enum SnippetVisibility {
  private('private'),
  public('public');

  const SnippetVisibility(this.wire);

  final String wire;

  static SnippetVisibility fromWire(String wire) => values.firstWhere(
        (e) => e.wire == wire,
        orElse: () => SnippetVisibility.private,
      );
}

/// One file within a (possibly multi-file) snippet. The first file mirrors the
/// snippet's denormalized body/languageId for back-compat.
class SnippetFile {
  const SnippetFile({
    required this.id,
    this.filename = '',
    this.languageId,
    this.content = '',
    this.position = 0,
  });

  final String id;
  final String filename;
  final String? languageId;
  final String content;
  final int position;
}

/// The editable shape used to create or update a single snippet file.
class SnippetFileDraft {
  const SnippetFileDraft({
    this.filename = '',
    this.languageId,
    this.content = '',
  });

  final String filename;
  final String? languageId;
  final String content;

  factory SnippetFileDraft.fromFile(SnippetFile f) => SnippetFileDraft(
        filename: f.filename,
        languageId: f.languageId,
        content: f.content,
      );
}

/// A binary attachment belonging to a snippet (image, file, etc.). Carries the
/// raw [bytes] inline so the UI can render/save them without a second fetch.
class Attachment {
  const Attachment({
    required this.id,
    required this.snippetId,
    required this.filename,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdAt,
    required this.bytes,
  });

  final String id;
  final String snippetId;
  final String filename;
  final String mimeType;
  final int sizeBytes;
  final int createdAt;
  final Uint8List bytes;
}

/// A categorization "purpose" (orthogonal to language and type).
class Purpose {
  const Purpose({required this.id, required this.label, this.appliesToType});

  final String id;
  final String label;

  /// Comma-separated snippet types this purpose suits, or null for any.
  final String? appliesToType;

  bool appliesTo(String typeWire) {
    final a = appliesToType;
    if (a == null || a.isEmpty) return true;
    return a.split(',').map((e) => e.trim()).contains(typeWire);
  }
}

/// A folder. Self-nestable via [parentId]; a snippet lives in 0..1 collection.
class Collection {
  const Collection({
    required this.id,
    required this.name,
    this.parentId,
    this.icon,
    this.color,
  });

  final String id;
  final String name;
  final String? parentId;
  final String? icon;
  final String? color;
}

/// A free-form label (many-to-many with snippets).
class Label {
  const Label({
    required this.id,
    required this.name,
    required this.normalizedName,
    this.color,
    this.parentId,
  });

  final String id;
  final String name;
  final String normalizedName;
  final String? color;

  /// Optional parent label id for a nested label hierarchy (app-enforced).
  final String? parentId;

  static String normalize(String name) => name.trim().toLowerCase();
}

/// A `{{placeholder}}` discovered in an AI-prompt body. [name] is parsed from
/// the body; the rest is optional metadata the user can fill in.
class PromptVariable {
  const PromptVariable({
    required this.name,
    this.label,
    this.defaultValue,
    this.description,
    this.required = false,
  });

  final String name;
  final String? label;
  final String? defaultValue;
  final String? description;
  final bool required;

  factory PromptVariable.fromJson(Map<String, dynamic> json) => PromptVariable(
        name: json['name'] as String,
        label: json['label'] as String?,
        defaultValue: json['default'] as String?,
        description: json['description'] as String?,
        required: json['required'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        if (label != null) 'label': label,
        if (defaultValue != null) 'default': defaultValue,
        if (description != null) 'description': description,
        'required': required,
      };

  PromptVariable copyWith({
    String? label,
    String? defaultValue,
    String? description,
    bool? required,
  }) =>
      PromptVariable(
        name: name,
        label: label ?? this.label,
        defaultValue: defaultValue ?? this.defaultValue,
        description: description ?? this.description,
        required: required ?? this.required,
      );
}

/// Extra fields that exist only for snippets of type ai_prompt.
class AiPromptMeta {
  const AiPromptMeta({
    this.targetModel,
    this.modelProvider,
    this.systemPrompt,
    this.temperature,
    this.maxTokens,
    this.variables = const [],
  });

  final String? targetModel;
  final String? modelProvider;
  final String? systemPrompt;
  final double? temperature;
  final int? maxTokens;
  final List<PromptVariable> variables;

  static List<PromptVariable> decodeVariables(String json) {
    if (json.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((m) {
            try {
              return PromptVariable.fromJson(m);
            } catch (_) {
              return null; // skip a malformed variable rather than poisoning
            }
          })
          .whereType<PromptVariable>()
          .toList();
    } catch (_) {
      return const []; // malformed JSON -> no variables, never crash the stream
    }
  }

  static String encodeVariables(List<PromptVariable> variables) =>
      jsonEncode([for (final v in variables) v.toJson()]);

  AiPromptMeta copyWith({
    String? targetModel,
    String? modelProvider,
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
    List<PromptVariable>? variables,
  }) =>
      AiPromptMeta(
        targetModel: targetModel ?? this.targetModel,
        modelProvider: modelProvider ?? this.modelProvider,
        systemPrompt: systemPrompt ?? this.systemPrompt,
        temperature: temperature ?? this.temperature,
        maxTokens: maxTokens ?? this.maxTokens,
        variables: variables ?? this.variables,
      );
}
