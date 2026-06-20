// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SnippetsTable extends Snippets
    with TableInfo<$SnippetsTable, SnippetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnippetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageIdMeta = const VerificationMeta(
    'languageId',
  );
  @override
  late final GeneratedColumn<String> languageId = GeneratedColumn<String>(
    'language_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('private'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    body,
    type,
    languageId,
    purpose,
    description,
    collectionId,
    visibility,
    isFavorite,
    sortIndex,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
    ownerId,
    workspaceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snippets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnippetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('language_id')) {
      context.handle(
        _languageIdMeta,
        languageId.isAcceptableOrUnknown(data['language_id']!, _languageIdMeta),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnippetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnippetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      languageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_id'],
      ),
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      ),
    );
  }

  @override
  $SnippetsTable createAlias(String alias) {
    return $SnippetsTable(attachedDatabase, alias);
  }
}

class SnippetRow extends DataClass implements Insertable<SnippetRow> {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? languageId;
  final String? purpose;
  final String? description;
  final String? collectionId;
  final String visibility;
  final bool isFavorite;
  final int? sortIndex;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final bool dirty;
  final String? ownerId;
  final String? workspaceId;
  const SnippetRow({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.languageId,
    this.purpose,
    this.description,
    this.collectionId,
    required this.visibility,
    required this.isFavorite,
    this.sortIndex,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.ownerId,
    this.workspaceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || languageId != null) {
      map['language_id'] = Variable<String>(languageId);
    }
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    map['visibility'] = Variable<String>(visibility);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || sortIndex != null) {
      map['sort_index'] = Variable<int>(sortIndex);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<String>(workspaceId);
    }
    return map;
  }

  SnippetsCompanion toCompanion(bool nullToAbsent) {
    return SnippetsCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      type: Value(type),
      languageId: languageId == null && nullToAbsent
          ? const Value.absent()
          : Value(languageId),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      visibility: Value(visibility),
      isFavorite: Value(isFavorite),
      sortIndex: sortIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(sortIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
    );
  }

  factory SnippetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnippetRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      type: serializer.fromJson<String>(json['type']),
      languageId: serializer.fromJson<String?>(json['languageId']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      description: serializer.fromJson<String?>(json['description']),
      collectionId: serializer.fromJson<String?>(json['collectionId']),
      visibility: serializer.fromJson<String>(json['visibility']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      sortIndex: serializer.fromJson<int?>(json['sortIndex']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      workspaceId: serializer.fromJson<String?>(json['workspaceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'type': serializer.toJson<String>(type),
      'languageId': serializer.toJson<String?>(languageId),
      'purpose': serializer.toJson<String?>(purpose),
      'description': serializer.toJson<String?>(description),
      'collectionId': serializer.toJson<String?>(collectionId),
      'visibility': serializer.toJson<String>(visibility),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'sortIndex': serializer.toJson<int?>(sortIndex),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'ownerId': serializer.toJson<String?>(ownerId),
      'workspaceId': serializer.toJson<String?>(workspaceId),
    };
  }

  SnippetRow copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Value<String?> languageId = const Value.absent(),
    Value<String?> purpose = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> collectionId = const Value.absent(),
    String? visibility,
    bool? isFavorite,
    Value<int?> sortIndex = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<String?> ownerId = const Value.absent(),
    Value<String?> workspaceId = const Value.absent(),
  }) => SnippetRow(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    type: type ?? this.type,
    languageId: languageId.present ? languageId.value : this.languageId,
    purpose: purpose.present ? purpose.value : this.purpose,
    description: description.present ? description.value : this.description,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    visibility: visibility ?? this.visibility,
    isFavorite: isFavorite ?? this.isFavorite,
    sortIndex: sortIndex.present ? sortIndex.value : this.sortIndex,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
  );
  SnippetRow copyWithCompanion(SnippetsCompanion data) {
    return SnippetRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      type: data.type.present ? data.type.value : this.type,
      languageId: data.languageId.present
          ? data.languageId.value
          : this.languageId,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      description: data.description.present
          ? data.description.value
          : this.description,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnippetRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('languageId: $languageId, ')
          ..write('purpose: $purpose, ')
          ..write('description: $description, ')
          ..write('collectionId: $collectionId, ')
          ..write('visibility: $visibility, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    body,
    type,
    languageId,
    purpose,
    description,
    collectionId,
    visibility,
    isFavorite,
    sortIndex,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
    ownerId,
    workspaceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnippetRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.type == this.type &&
          other.languageId == this.languageId &&
          other.purpose == this.purpose &&
          other.description == this.description &&
          other.collectionId == this.collectionId &&
          other.visibility == this.visibility &&
          other.isFavorite == this.isFavorite &&
          other.sortIndex == this.sortIndex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.ownerId == this.ownerId &&
          other.workspaceId == this.workspaceId);
}

class SnippetsCompanion extends UpdateCompanion<SnippetRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> body;
  final Value<String> type;
  final Value<String?> languageId;
  final Value<String?> purpose;
  final Value<String?> description;
  final Value<String?> collectionId;
  final Value<String> visibility;
  final Value<bool> isFavorite;
  final Value<int?> sortIndex;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> dirty;
  final Value<String?> ownerId;
  final Value<String?> workspaceId;
  final Value<int> rowid;
  const SnippetsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.type = const Value.absent(),
    this.languageId = const Value.absent(),
    this.purpose = const Value.absent(),
    this.description = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.visibility = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnippetsCompanion.insert({
    required String id,
    required String title,
    required String body,
    required String type,
    this.languageId = const Value.absent(),
    this.purpose = const Value.absent(),
    this.description = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.visibility = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.sortIndex = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       body = Value(body),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SnippetRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? type,
    Expression<String>? languageId,
    Expression<String>? purpose,
    Expression<String>? description,
    Expression<String>? collectionId,
    Expression<String>? visibility,
    Expression<bool>? isFavorite,
    Expression<int>? sortIndex,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? dirty,
    Expression<String>? ownerId,
    Expression<String>? workspaceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (type != null) 'type': type,
      if (languageId != null) 'language_id': languageId,
      if (purpose != null) 'purpose': purpose,
      if (description != null) 'description': description,
      if (collectionId != null) 'collection_id': collectionId,
      if (visibility != null) 'visibility': visibility,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (ownerId != null) 'owner_id': ownerId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnippetsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? body,
    Value<String>? type,
    Value<String?>? languageId,
    Value<String?>? purpose,
    Value<String?>? description,
    Value<String?>? collectionId,
    Value<String>? visibility,
    Value<bool>? isFavorite,
    Value<int?>? sortIndex,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? dirty,
    Value<String?>? ownerId,
    Value<String?>? workspaceId,
    Value<int>? rowid,
  }) {
    return SnippetsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      languageId: languageId ?? this.languageId,
      purpose: purpose ?? this.purpose,
      description: description ?? this.description,
      collectionId: collectionId ?? this.collectionId,
      visibility: visibility ?? this.visibility,
      isFavorite: isFavorite ?? this.isFavorite,
      sortIndex: sortIndex ?? this.sortIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      ownerId: ownerId ?? this.ownerId,
      workspaceId: workspaceId ?? this.workspaceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (languageId.present) {
      map['language_id'] = Variable<String>(languageId.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnippetsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('languageId: $languageId, ')
          ..write('purpose: $purpose, ')
          ..write('description: $description, ')
          ..write('collectionId: $collectionId, ')
          ..write('visibility: $visibility, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SnippetFilesTable extends SnippetFiles
    with TableInfo<$SnippetFilesTable, SnippetFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnippetFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snippetIdMeta = const VerificationMeta(
    'snippetId',
  );
  @override
  late final GeneratedColumn<String> snippetId = GeneratedColumn<String>(
    'snippet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _languageIdMeta = const VerificationMeta(
    'languageId',
  );
  @override
  late final GeneratedColumn<String> languageId = GeneratedColumn<String>(
    'language_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    snippetId,
    filename,
    languageId,
    content,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
    ownerId,
    workspaceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snippet_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnippetFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('snippet_id')) {
      context.handle(
        _snippetIdMeta,
        snippetId.isAcceptableOrUnknown(data['snippet_id']!, _snippetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_snippetIdMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    }
    if (data.containsKey('language_id')) {
      context.handle(
        _languageIdMeta,
        languageId.isAcceptableOrUnknown(data['language_id']!, _languageIdMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnippetFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnippetFileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      snippetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet_id'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      languageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_id'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      ),
    );
  }

  @override
  $SnippetFilesTable createAlias(String alias) {
    return $SnippetFilesTable(attachedDatabase, alias);
  }
}

class SnippetFileRow extends DataClass implements Insertable<SnippetFileRow> {
  final String id;
  final String snippetId;
  final String filename;
  final String? languageId;
  final String content;
  final int position;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final bool dirty;
  final String? ownerId;
  final String? workspaceId;
  const SnippetFileRow({
    required this.id,
    required this.snippetId,
    required this.filename,
    this.languageId,
    required this.content,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.ownerId,
    this.workspaceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['snippet_id'] = Variable<String>(snippetId);
    map['filename'] = Variable<String>(filename);
    if (!nullToAbsent || languageId != null) {
      map['language_id'] = Variable<String>(languageId);
    }
    map['content'] = Variable<String>(content);
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<String>(workspaceId);
    }
    return map;
  }

  SnippetFilesCompanion toCompanion(bool nullToAbsent) {
    return SnippetFilesCompanion(
      id: Value(id),
      snippetId: Value(snippetId),
      filename: Value(filename),
      languageId: languageId == null && nullToAbsent
          ? const Value.absent()
          : Value(languageId),
      content: Value(content),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
    );
  }

  factory SnippetFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnippetFileRow(
      id: serializer.fromJson<String>(json['id']),
      snippetId: serializer.fromJson<String>(json['snippetId']),
      filename: serializer.fromJson<String>(json['filename']),
      languageId: serializer.fromJson<String?>(json['languageId']),
      content: serializer.fromJson<String>(json['content']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      workspaceId: serializer.fromJson<String?>(json['workspaceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'snippetId': serializer.toJson<String>(snippetId),
      'filename': serializer.toJson<String>(filename),
      'languageId': serializer.toJson<String?>(languageId),
      'content': serializer.toJson<String>(content),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'ownerId': serializer.toJson<String?>(ownerId),
      'workspaceId': serializer.toJson<String?>(workspaceId),
    };
  }

  SnippetFileRow copyWith({
    String? id,
    String? snippetId,
    String? filename,
    Value<String?> languageId = const Value.absent(),
    String? content,
    int? position,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<String?> ownerId = const Value.absent(),
    Value<String?> workspaceId = const Value.absent(),
  }) => SnippetFileRow(
    id: id ?? this.id,
    snippetId: snippetId ?? this.snippetId,
    filename: filename ?? this.filename,
    languageId: languageId.present ? languageId.value : this.languageId,
    content: content ?? this.content,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
  );
  SnippetFileRow copyWithCompanion(SnippetFilesCompanion data) {
    return SnippetFileRow(
      id: data.id.present ? data.id.value : this.id,
      snippetId: data.snippetId.present ? data.snippetId.value : this.snippetId,
      filename: data.filename.present ? data.filename.value : this.filename,
      languageId: data.languageId.present
          ? data.languageId.value
          : this.languageId,
      content: data.content.present ? data.content.value : this.content,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnippetFileRow(')
          ..write('id: $id, ')
          ..write('snippetId: $snippetId, ')
          ..write('filename: $filename, ')
          ..write('languageId: $languageId, ')
          ..write('content: $content, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    snippetId,
    filename,
    languageId,
    content,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
    ownerId,
    workspaceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnippetFileRow &&
          other.id == this.id &&
          other.snippetId == this.snippetId &&
          other.filename == this.filename &&
          other.languageId == this.languageId &&
          other.content == this.content &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.ownerId == this.ownerId &&
          other.workspaceId == this.workspaceId);
}

class SnippetFilesCompanion extends UpdateCompanion<SnippetFileRow> {
  final Value<String> id;
  final Value<String> snippetId;
  final Value<String> filename;
  final Value<String?> languageId;
  final Value<String> content;
  final Value<int> position;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> dirty;
  final Value<String?> ownerId;
  final Value<String?> workspaceId;
  final Value<int> rowid;
  const SnippetFilesCompanion({
    this.id = const Value.absent(),
    this.snippetId = const Value.absent(),
    this.filename = const Value.absent(),
    this.languageId = const Value.absent(),
    this.content = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnippetFilesCompanion.insert({
    required String id,
    required String snippetId,
    this.filename = const Value.absent(),
    this.languageId = const Value.absent(),
    this.content = const Value.absent(),
    this.position = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       snippetId = Value(snippetId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SnippetFileRow> custom({
    Expression<String>? id,
    Expression<String>? snippetId,
    Expression<String>? filename,
    Expression<String>? languageId,
    Expression<String>? content,
    Expression<int>? position,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? dirty,
    Expression<String>? ownerId,
    Expression<String>? workspaceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (snippetId != null) 'snippet_id': snippetId,
      if (filename != null) 'filename': filename,
      if (languageId != null) 'language_id': languageId,
      if (content != null) 'content': content,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (ownerId != null) 'owner_id': ownerId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnippetFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? snippetId,
    Value<String>? filename,
    Value<String?>? languageId,
    Value<String>? content,
    Value<int>? position,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? dirty,
    Value<String?>? ownerId,
    Value<String?>? workspaceId,
    Value<int>? rowid,
  }) {
    return SnippetFilesCompanion(
      id: id ?? this.id,
      snippetId: snippetId ?? this.snippetId,
      filename: filename ?? this.filename,
      languageId: languageId ?? this.languageId,
      content: content ?? this.content,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      ownerId: ownerId ?? this.ownerId,
      workspaceId: workspaceId ?? this.workspaceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (snippetId.present) {
      map['snippet_id'] = Variable<String>(snippetId.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (languageId.present) {
      map['language_id'] = Variable<String>(languageId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnippetFilesCompanion(')
          ..write('id: $id, ')
          ..write('snippetId: $snippetId, ')
          ..write('filename: $filename, ')
          ..write('languageId: $languageId, ')
          ..write('content: $content, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SnippetFileVersionsTable extends SnippetFileVersions
    with TableInfo<$SnippetFileVersionsTable, SnippetFileVersionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnippetFileVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snippetIdMeta = const VerificationMeta(
    'snippetId',
  );
  @override
  late final GeneratedColumn<String> snippetId = GeneratedColumn<String>(
    'snippet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _languageIdMeta = const VerificationMeta(
    'languageId',
  );
  @override
  late final GeneratedColumn<String> languageId = GeneratedColumn<String>(
    'language_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<int> savedAt = GeneratedColumn<int>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    snippetId,
    filename,
    languageId,
    content,
    position,
    savedAt,
    dirty,
    ownerId,
    workspaceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snippet_file_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnippetFileVersionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('snippet_id')) {
      context.handle(
        _snippetIdMeta,
        snippetId.isAcceptableOrUnknown(data['snippet_id']!, _snippetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_snippetIdMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    }
    if (data.containsKey('language_id')) {
      context.handle(
        _languageIdMeta,
        languageId.isAcceptableOrUnknown(data['language_id']!, _languageIdMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnippetFileVersionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnippetFileVersionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      snippetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet_id'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      languageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_id'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      ),
    );
  }

  @override
  $SnippetFileVersionsTable createAlias(String alias) {
    return $SnippetFileVersionsTable(attachedDatabase, alias);
  }
}

class SnippetFileVersionRow extends DataClass
    implements Insertable<SnippetFileVersionRow> {
  final String id;
  final String snippetId;
  final String filename;
  final String? languageId;
  final String content;
  final int position;
  final int savedAt;
  final bool dirty;
  final String? ownerId;
  final String? workspaceId;
  const SnippetFileVersionRow({
    required this.id,
    required this.snippetId,
    required this.filename,
    this.languageId,
    required this.content,
    required this.position,
    required this.savedAt,
    required this.dirty,
    this.ownerId,
    this.workspaceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['snippet_id'] = Variable<String>(snippetId);
    map['filename'] = Variable<String>(filename);
    if (!nullToAbsent || languageId != null) {
      map['language_id'] = Variable<String>(languageId);
    }
    map['content'] = Variable<String>(content);
    map['position'] = Variable<int>(position);
    map['saved_at'] = Variable<int>(savedAt);
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<String>(workspaceId);
    }
    return map;
  }

  SnippetFileVersionsCompanion toCompanion(bool nullToAbsent) {
    return SnippetFileVersionsCompanion(
      id: Value(id),
      snippetId: Value(snippetId),
      filename: Value(filename),
      languageId: languageId == null && nullToAbsent
          ? const Value.absent()
          : Value(languageId),
      content: Value(content),
      position: Value(position),
      savedAt: Value(savedAt),
      dirty: Value(dirty),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
    );
  }

  factory SnippetFileVersionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnippetFileVersionRow(
      id: serializer.fromJson<String>(json['id']),
      snippetId: serializer.fromJson<String>(json['snippetId']),
      filename: serializer.fromJson<String>(json['filename']),
      languageId: serializer.fromJson<String?>(json['languageId']),
      content: serializer.fromJson<String>(json['content']),
      position: serializer.fromJson<int>(json['position']),
      savedAt: serializer.fromJson<int>(json['savedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      workspaceId: serializer.fromJson<String?>(json['workspaceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'snippetId': serializer.toJson<String>(snippetId),
      'filename': serializer.toJson<String>(filename),
      'languageId': serializer.toJson<String?>(languageId),
      'content': serializer.toJson<String>(content),
      'position': serializer.toJson<int>(position),
      'savedAt': serializer.toJson<int>(savedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'ownerId': serializer.toJson<String?>(ownerId),
      'workspaceId': serializer.toJson<String?>(workspaceId),
    };
  }

  SnippetFileVersionRow copyWith({
    String? id,
    String? snippetId,
    String? filename,
    Value<String?> languageId = const Value.absent(),
    String? content,
    int? position,
    int? savedAt,
    bool? dirty,
    Value<String?> ownerId = const Value.absent(),
    Value<String?> workspaceId = const Value.absent(),
  }) => SnippetFileVersionRow(
    id: id ?? this.id,
    snippetId: snippetId ?? this.snippetId,
    filename: filename ?? this.filename,
    languageId: languageId.present ? languageId.value : this.languageId,
    content: content ?? this.content,
    position: position ?? this.position,
    savedAt: savedAt ?? this.savedAt,
    dirty: dirty ?? this.dirty,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
  );
  SnippetFileVersionRow copyWithCompanion(SnippetFileVersionsCompanion data) {
    return SnippetFileVersionRow(
      id: data.id.present ? data.id.value : this.id,
      snippetId: data.snippetId.present ? data.snippetId.value : this.snippetId,
      filename: data.filename.present ? data.filename.value : this.filename,
      languageId: data.languageId.present
          ? data.languageId.value
          : this.languageId,
      content: data.content.present ? data.content.value : this.content,
      position: data.position.present ? data.position.value : this.position,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnippetFileVersionRow(')
          ..write('id: $id, ')
          ..write('snippetId: $snippetId, ')
          ..write('filename: $filename, ')
          ..write('languageId: $languageId, ')
          ..write('content: $content, ')
          ..write('position: $position, ')
          ..write('savedAt: $savedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    snippetId,
    filename,
    languageId,
    content,
    position,
    savedAt,
    dirty,
    ownerId,
    workspaceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnippetFileVersionRow &&
          other.id == this.id &&
          other.snippetId == this.snippetId &&
          other.filename == this.filename &&
          other.languageId == this.languageId &&
          other.content == this.content &&
          other.position == this.position &&
          other.savedAt == this.savedAt &&
          other.dirty == this.dirty &&
          other.ownerId == this.ownerId &&
          other.workspaceId == this.workspaceId);
}

class SnippetFileVersionsCompanion
    extends UpdateCompanion<SnippetFileVersionRow> {
  final Value<String> id;
  final Value<String> snippetId;
  final Value<String> filename;
  final Value<String?> languageId;
  final Value<String> content;
  final Value<int> position;
  final Value<int> savedAt;
  final Value<bool> dirty;
  final Value<String?> ownerId;
  final Value<String?> workspaceId;
  final Value<int> rowid;
  const SnippetFileVersionsCompanion({
    this.id = const Value.absent(),
    this.snippetId = const Value.absent(),
    this.filename = const Value.absent(),
    this.languageId = const Value.absent(),
    this.content = const Value.absent(),
    this.position = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnippetFileVersionsCompanion.insert({
    required String id,
    required String snippetId,
    this.filename = const Value.absent(),
    this.languageId = const Value.absent(),
    this.content = const Value.absent(),
    this.position = const Value.absent(),
    required int savedAt,
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       snippetId = Value(snippetId),
       savedAt = Value(savedAt);
  static Insertable<SnippetFileVersionRow> custom({
    Expression<String>? id,
    Expression<String>? snippetId,
    Expression<String>? filename,
    Expression<String>? languageId,
    Expression<String>? content,
    Expression<int>? position,
    Expression<int>? savedAt,
    Expression<bool>? dirty,
    Expression<String>? ownerId,
    Expression<String>? workspaceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (snippetId != null) 'snippet_id': snippetId,
      if (filename != null) 'filename': filename,
      if (languageId != null) 'language_id': languageId,
      if (content != null) 'content': content,
      if (position != null) 'position': position,
      if (savedAt != null) 'saved_at': savedAt,
      if (dirty != null) 'dirty': dirty,
      if (ownerId != null) 'owner_id': ownerId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnippetFileVersionsCompanion copyWith({
    Value<String>? id,
    Value<String>? snippetId,
    Value<String>? filename,
    Value<String?>? languageId,
    Value<String>? content,
    Value<int>? position,
    Value<int>? savedAt,
    Value<bool>? dirty,
    Value<String?>? ownerId,
    Value<String?>? workspaceId,
    Value<int>? rowid,
  }) {
    return SnippetFileVersionsCompanion(
      id: id ?? this.id,
      snippetId: snippetId ?? this.snippetId,
      filename: filename ?? this.filename,
      languageId: languageId ?? this.languageId,
      content: content ?? this.content,
      position: position ?? this.position,
      savedAt: savedAt ?? this.savedAt,
      dirty: dirty ?? this.dirty,
      ownerId: ownerId ?? this.ownerId,
      workspaceId: workspaceId ?? this.workspaceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (snippetId.present) {
      map['snippet_id'] = Variable<String>(snippetId.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (languageId.present) {
      map['language_id'] = Variable<String>(languageId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<int>(savedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnippetFileVersionsCompanion(')
          ..write('id: $id, ')
          ..write('snippetId: $snippetId, ')
          ..write('filename: $filename, ')
          ..write('languageId: $languageId, ')
          ..write('content: $content, ')
          ..write('position: $position, ')
          ..write('savedAt: $savedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LanguagesTable extends Languages
    with TableInfo<$LanguagesTable, LanguageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LanguagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileExtensionMeta = const VerificationMeta(
    'fileExtension',
  );
  @override
  late final GeneratedColumn<String> fileExtension = GeneratedColumn<String>(
    'file_extension',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grammarIdMeta = const VerificationMeta(
    'grammarId',
  );
  @override
  late final GeneratedColumn<String> grammarId = GeneratedColumn<String>(
    'grammar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasesJsonMeta = const VerificationMeta(
    'aliasesJson',
  );
  @override
  late final GeneratedColumn<String> aliasesJson = GeneratedColumn<String>(
    'aliases_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fileExtension,
    grammarId,
    aliasesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'languages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LanguageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('file_extension')) {
      context.handle(
        _fileExtensionMeta,
        fileExtension.isAcceptableOrUnknown(
          data['file_extension']!,
          _fileExtensionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileExtensionMeta);
    }
    if (data.containsKey('grammar_id')) {
      context.handle(
        _grammarIdMeta,
        grammarId.isAcceptableOrUnknown(data['grammar_id']!, _grammarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_grammarIdMeta);
    }
    if (data.containsKey('aliases_json')) {
      context.handle(
        _aliasesJsonMeta,
        aliasesJson.isAcceptableOrUnknown(
          data['aliases_json']!,
          _aliasesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LanguageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LanguageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fileExtension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_extension'],
      )!,
      grammarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_id'],
      )!,
      aliasesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases_json'],
      )!,
    );
  }

  @override
  $LanguagesTable createAlias(String alias) {
    return $LanguagesTable(attachedDatabase, alias);
  }
}

class LanguageRow extends DataClass implements Insertable<LanguageRow> {
  final String id;
  final String name;
  final String fileExtension;
  final String grammarId;
  final String aliasesJson;
  const LanguageRow({
    required this.id,
    required this.name,
    required this.fileExtension,
    required this.grammarId,
    required this.aliasesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['file_extension'] = Variable<String>(fileExtension);
    map['grammar_id'] = Variable<String>(grammarId);
    map['aliases_json'] = Variable<String>(aliasesJson);
    return map;
  }

  LanguagesCompanion toCompanion(bool nullToAbsent) {
    return LanguagesCompanion(
      id: Value(id),
      name: Value(name),
      fileExtension: Value(fileExtension),
      grammarId: Value(grammarId),
      aliasesJson: Value(aliasesJson),
    );
  }

  factory LanguageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LanguageRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fileExtension: serializer.fromJson<String>(json['fileExtension']),
      grammarId: serializer.fromJson<String>(json['grammarId']),
      aliasesJson: serializer.fromJson<String>(json['aliasesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'fileExtension': serializer.toJson<String>(fileExtension),
      'grammarId': serializer.toJson<String>(grammarId),
      'aliasesJson': serializer.toJson<String>(aliasesJson),
    };
  }

  LanguageRow copyWith({
    String? id,
    String? name,
    String? fileExtension,
    String? grammarId,
    String? aliasesJson,
  }) => LanguageRow(
    id: id ?? this.id,
    name: name ?? this.name,
    fileExtension: fileExtension ?? this.fileExtension,
    grammarId: grammarId ?? this.grammarId,
    aliasesJson: aliasesJson ?? this.aliasesJson,
  );
  LanguageRow copyWithCompanion(LanguagesCompanion data) {
    return LanguageRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fileExtension: data.fileExtension.present
          ? data.fileExtension.value
          : this.fileExtension,
      grammarId: data.grammarId.present ? data.grammarId.value : this.grammarId,
      aliasesJson: data.aliasesJson.present
          ? data.aliasesJson.value
          : this.aliasesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LanguageRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fileExtension: $fileExtension, ')
          ..write('grammarId: $grammarId, ')
          ..write('aliasesJson: $aliasesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, fileExtension, grammarId, aliasesJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LanguageRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.fileExtension == this.fileExtension &&
          other.grammarId == this.grammarId &&
          other.aliasesJson == this.aliasesJson);
}

class LanguagesCompanion extends UpdateCompanion<LanguageRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> fileExtension;
  final Value<String> grammarId;
  final Value<String> aliasesJson;
  final Value<int> rowid;
  const LanguagesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fileExtension = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.aliasesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LanguagesCompanion.insert({
    required String id,
    required String name,
    required String fileExtension,
    required String grammarId,
    this.aliasesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       fileExtension = Value(fileExtension),
       grammarId = Value(grammarId);
  static Insertable<LanguageRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? fileExtension,
    Expression<String>? grammarId,
    Expression<String>? aliasesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fileExtension != null) 'file_extension': fileExtension,
      if (grammarId != null) 'grammar_id': grammarId,
      if (aliasesJson != null) 'aliases_json': aliasesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LanguagesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? fileExtension,
    Value<String>? grammarId,
    Value<String>? aliasesJson,
    Value<int>? rowid,
  }) {
    return LanguagesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fileExtension: fileExtension ?? this.fileExtension,
      grammarId: grammarId ?? this.grammarId,
      aliasesJson: aliasesJson ?? this.aliasesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fileExtension.present) {
      map['file_extension'] = Variable<String>(fileExtension.value);
    }
    if (grammarId.present) {
      map['grammar_id'] = Variable<String>(grammarId.value);
    }
    if (aliasesJson.present) {
      map['aliases_json'] = Variable<String>(aliasesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LanguagesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fileExtension: $fileExtension, ')
          ..write('grammarId: $grammarId, ')
          ..write('aliasesJson: $aliasesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    parentId,
    icon,
    color,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
    ownerId,
    workspaceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      ),
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class CollectionRow extends DataClass implements Insertable<CollectionRow> {
  final String id;
  final String name;
  final String? parentId;
  final String? icon;
  final String? color;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final bool dirty;
  final String? ownerId;
  final String? workspaceId;
  const CollectionRow({
    required this.id,
    required this.name,
    this.parentId,
    this.icon,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.ownerId,
    this.workspaceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<String>(workspaceId);
    }
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
    );
  }

  factory CollectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      workspaceId: serializer.fromJson<String?>(json['workspaceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'ownerId': serializer.toJson<String?>(ownerId),
      'workspaceId': serializer.toJson<String?>(workspaceId),
    };
  }

  CollectionRow copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<String?> ownerId = const Value.absent(),
    Value<String?> workspaceId = const Value.absent(),
  }) => CollectionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
  );
  CollectionRow copyWithCompanion(CollectionsCompanion data) {
    return CollectionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    parentId,
    icon,
    color,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
    ownerId,
    workspaceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.ownerId == this.ownerId &&
          other.workspaceId == this.workspaceId);
}

class CollectionsCompanion extends UpdateCompanion<CollectionRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> dirty;
  final Value<String?> ownerId;
  final Value<String?> workspaceId;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CollectionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? dirty,
    Expression<String>? ownerId,
    Expression<String>? workspaceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (ownerId != null) 'owner_id': ownerId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<String?>? icon,
    Value<String?>? color,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? dirty,
    Value<String?>? ownerId,
    Value<String?>? workspaceId,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      ownerId: ownerId ?? this.ownerId,
      workspaceId: workspaceId ?? this.workspaceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    normalizedName,
    color,
    parentId,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
    ownerId,
    workspaceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String name;
  final String normalizedName;
  final String? color;
  final String? parentId;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final bool dirty;
  final String? ownerId;
  final String? workspaceId;
  const TagRow({
    required this.id,
    required this.name,
    required this.normalizedName,
    this.color,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.ownerId,
    this.workspaceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<String>(workspaceId);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      normalizedName: Value(normalizedName),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      color: serializer.fromJson<String?>(json['color']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      workspaceId: serializer.fromJson<String?>(json['workspaceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'color': serializer.toJson<String?>(color),
      'parentId': serializer.toJson<String?>(parentId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'ownerId': serializer.toJson<String?>(ownerId),
      'workspaceId': serializer.toJson<String?>(workspaceId),
    };
  }

  TagRow copyWith({
    String? id,
    String? name,
    String? normalizedName,
    Value<String?> color = const Value.absent(),
    Value<String?> parentId = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<String?> ownerId = const Value.absent(),
    Value<String?> workspaceId = const Value.absent(),
  }) => TagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    color: color.present ? color.value : this.color,
    parentId: parentId.present ? parentId.value : this.parentId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      color: data.color.present ? data.color.value : this.color,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    normalizedName,
    color,
    parentId,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
    ownerId,
    workspaceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.color == this.color &&
          other.parentId == this.parentId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.ownerId == this.ownerId &&
          other.workspaceId == this.workspaceId);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String?> color;
  final Value<String?> parentId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> dirty;
  final Value<String?> ownerId;
  final Value<String?> workspaceId;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required String normalizedName,
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       normalizedName = Value(normalizedName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? color,
    Expression<String>? parentId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? dirty,
    Expression<String>? ownerId,
    Expression<String>? workspaceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (color != null) 'color': color,
      if (parentId != null) 'parent_id': parentId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (ownerId != null) 'owner_id': ownerId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String?>? color,
    Value<String?>? parentId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? dirty,
    Value<String?>? ownerId,
    Value<String?>? workspaceId,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      ownerId: ownerId ?? this.ownerId,
      workspaceId: workspaceId ?? this.workspaceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SnippetTagsTable extends SnippetTags
    with TableInfo<$SnippetTagsTable, SnippetTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnippetTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _snippetIdMeta = const VerificationMeta(
    'snippetId',
  );
  @override
  late final GeneratedColumn<String> snippetId = GeneratedColumn<String>(
    'snippet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    snippetId,
    tagId,
    createdAt,
    workspaceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snippet_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnippetTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('snippet_id')) {
      context.handle(
        _snippetIdMeta,
        snippetId.isAcceptableOrUnknown(data['snippet_id']!, _snippetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_snippetIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {snippetId, tagId};
  @override
  SnippetTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnippetTagRow(
      snippetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      ),
    );
  }

  @override
  $SnippetTagsTable createAlias(String alias) {
    return $SnippetTagsTable(attachedDatabase, alias);
  }
}

class SnippetTagRow extends DataClass implements Insertable<SnippetTagRow> {
  final String snippetId;
  final String tagId;
  final int createdAt;
  final String? workspaceId;
  const SnippetTagRow({
    required this.snippetId,
    required this.tagId,
    required this.createdAt,
    this.workspaceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['snippet_id'] = Variable<String>(snippetId);
    map['tag_id'] = Variable<String>(tagId);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<String>(workspaceId);
    }
    return map;
  }

  SnippetTagsCompanion toCompanion(bool nullToAbsent) {
    return SnippetTagsCompanion(
      snippetId: Value(snippetId),
      tagId: Value(tagId),
      createdAt: Value(createdAt),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
    );
  }

  factory SnippetTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnippetTagRow(
      snippetId: serializer.fromJson<String>(json['snippetId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      workspaceId: serializer.fromJson<String?>(json['workspaceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'snippetId': serializer.toJson<String>(snippetId),
      'tagId': serializer.toJson<String>(tagId),
      'createdAt': serializer.toJson<int>(createdAt),
      'workspaceId': serializer.toJson<String?>(workspaceId),
    };
  }

  SnippetTagRow copyWith({
    String? snippetId,
    String? tagId,
    int? createdAt,
    Value<String?> workspaceId = const Value.absent(),
  }) => SnippetTagRow(
    snippetId: snippetId ?? this.snippetId,
    tagId: tagId ?? this.tagId,
    createdAt: createdAt ?? this.createdAt,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
  );
  SnippetTagRow copyWithCompanion(SnippetTagsCompanion data) {
    return SnippetTagRow(
      snippetId: data.snippetId.present ? data.snippetId.value : this.snippetId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnippetTagRow(')
          ..write('snippetId: $snippetId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('workspaceId: $workspaceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(snippetId, tagId, createdAt, workspaceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnippetTagRow &&
          other.snippetId == this.snippetId &&
          other.tagId == this.tagId &&
          other.createdAt == this.createdAt &&
          other.workspaceId == this.workspaceId);
}

class SnippetTagsCompanion extends UpdateCompanion<SnippetTagRow> {
  final Value<String> snippetId;
  final Value<String> tagId;
  final Value<int> createdAt;
  final Value<String?> workspaceId;
  final Value<int> rowid;
  const SnippetTagsCompanion({
    this.snippetId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnippetTagsCompanion.insert({
    required String snippetId,
    required String tagId,
    required int createdAt,
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : snippetId = Value(snippetId),
       tagId = Value(tagId),
       createdAt = Value(createdAt);
  static Insertable<SnippetTagRow> custom({
    Expression<String>? snippetId,
    Expression<String>? tagId,
    Expression<int>? createdAt,
    Expression<String>? workspaceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (snippetId != null) 'snippet_id': snippetId,
      if (tagId != null) 'tag_id': tagId,
      if (createdAt != null) 'created_at': createdAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnippetTagsCompanion copyWith({
    Value<String>? snippetId,
    Value<String>? tagId,
    Value<int>? createdAt,
    Value<String?>? workspaceId,
    Value<int>? rowid,
  }) {
    return SnippetTagsCompanion(
      snippetId: snippetId ?? this.snippetId,
      tagId: tagId ?? this.tagId,
      createdAt: createdAt ?? this.createdAt,
      workspaceId: workspaceId ?? this.workspaceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (snippetId.present) {
      map['snippet_id'] = Variable<String>(snippetId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnippetTagsCompanion(')
          ..write('snippetId: $snippetId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiPromptMetaTable extends AiPromptMeta
    with TableInfo<$AiPromptMetaTable, AiPromptMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiPromptMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _snippetIdMeta = const VerificationMeta(
    'snippetId',
  );
  @override
  late final GeneratedColumn<String> snippetId = GeneratedColumn<String>(
    'snippet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetModelMeta = const VerificationMeta(
    'targetModel',
  );
  @override
  late final GeneratedColumn<String> targetModel = GeneratedColumn<String>(
    'target_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelProviderMeta = const VerificationMeta(
    'modelProvider',
  );
  @override
  late final GeneratedColumn<String> modelProvider = GeneratedColumn<String>(
    'model_provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _systemPromptMeta = const VerificationMeta(
    'systemPrompt',
  );
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
    'system_prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxTokensMeta = const VerificationMeta(
    'maxTokens',
  );
  @override
  late final GeneratedColumn<int> maxTokens = GeneratedColumn<int>(
    'max_tokens',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variablesJsonMeta = const VerificationMeta(
    'variablesJson',
  );
  @override
  late final GeneratedColumn<String> variablesJson = GeneratedColumn<String>(
    'variables_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    snippetId,
    targetModel,
    modelProvider,
    systemPrompt,
    temperature,
    maxTokens,
    variablesJson,
    updatedAt,
    workspaceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_prompt_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiPromptMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('snippet_id')) {
      context.handle(
        _snippetIdMeta,
        snippetId.isAcceptableOrUnknown(data['snippet_id']!, _snippetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_snippetIdMeta);
    }
    if (data.containsKey('target_model')) {
      context.handle(
        _targetModelMeta,
        targetModel.isAcceptableOrUnknown(
          data['target_model']!,
          _targetModelMeta,
        ),
      );
    }
    if (data.containsKey('model_provider')) {
      context.handle(
        _modelProviderMeta,
        modelProvider.isAcceptableOrUnknown(
          data['model_provider']!,
          _modelProviderMeta,
        ),
      );
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
        _systemPromptMeta,
        systemPrompt.isAcceptableOrUnknown(
          data['system_prompt']!,
          _systemPromptMeta,
        ),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('max_tokens')) {
      context.handle(
        _maxTokensMeta,
        maxTokens.isAcceptableOrUnknown(data['max_tokens']!, _maxTokensMeta),
      );
    }
    if (data.containsKey('variables_json')) {
      context.handle(
        _variablesJsonMeta,
        variablesJson.isAcceptableOrUnknown(
          data['variables_json']!,
          _variablesJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {snippetId};
  @override
  AiPromptMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiPromptMetaRow(
      snippetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet_id'],
      )!,
      targetModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_model'],
      ),
      modelProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_provider'],
      ),
      systemPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_prompt'],
      ),
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      ),
      maxTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_tokens'],
      ),
      variablesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variables_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      ),
    );
  }

  @override
  $AiPromptMetaTable createAlias(String alias) {
    return $AiPromptMetaTable(attachedDatabase, alias);
  }
}

class AiPromptMetaRow extends DataClass implements Insertable<AiPromptMetaRow> {
  final String snippetId;
  final String? targetModel;
  final String? modelProvider;
  final String? systemPrompt;
  final double? temperature;
  final int? maxTokens;
  final String variablesJson;
  final int updatedAt;
  final String? workspaceId;
  const AiPromptMetaRow({
    required this.snippetId,
    this.targetModel,
    this.modelProvider,
    this.systemPrompt,
    this.temperature,
    this.maxTokens,
    required this.variablesJson,
    required this.updatedAt,
    this.workspaceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['snippet_id'] = Variable<String>(snippetId);
    if (!nullToAbsent || targetModel != null) {
      map['target_model'] = Variable<String>(targetModel);
    }
    if (!nullToAbsent || modelProvider != null) {
      map['model_provider'] = Variable<String>(modelProvider);
    }
    if (!nullToAbsent || systemPrompt != null) {
      map['system_prompt'] = Variable<String>(systemPrompt);
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || maxTokens != null) {
      map['max_tokens'] = Variable<int>(maxTokens);
    }
    map['variables_json'] = Variable<String>(variablesJson);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<String>(workspaceId);
    }
    return map;
  }

  AiPromptMetaCompanion toCompanion(bool nullToAbsent) {
    return AiPromptMetaCompanion(
      snippetId: Value(snippetId),
      targetModel: targetModel == null && nullToAbsent
          ? const Value.absent()
          : Value(targetModel),
      modelProvider: modelProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(modelProvider),
      systemPrompt: systemPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(systemPrompt),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      maxTokens: maxTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(maxTokens),
      variablesJson: Value(variablesJson),
      updatedAt: Value(updatedAt),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
    );
  }

  factory AiPromptMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiPromptMetaRow(
      snippetId: serializer.fromJson<String>(json['snippetId']),
      targetModel: serializer.fromJson<String?>(json['targetModel']),
      modelProvider: serializer.fromJson<String?>(json['modelProvider']),
      systemPrompt: serializer.fromJson<String?>(json['systemPrompt']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      maxTokens: serializer.fromJson<int?>(json['maxTokens']),
      variablesJson: serializer.fromJson<String>(json['variablesJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      workspaceId: serializer.fromJson<String?>(json['workspaceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'snippetId': serializer.toJson<String>(snippetId),
      'targetModel': serializer.toJson<String?>(targetModel),
      'modelProvider': serializer.toJson<String?>(modelProvider),
      'systemPrompt': serializer.toJson<String?>(systemPrompt),
      'temperature': serializer.toJson<double?>(temperature),
      'maxTokens': serializer.toJson<int?>(maxTokens),
      'variablesJson': serializer.toJson<String>(variablesJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'workspaceId': serializer.toJson<String?>(workspaceId),
    };
  }

  AiPromptMetaRow copyWith({
    String? snippetId,
    Value<String?> targetModel = const Value.absent(),
    Value<String?> modelProvider = const Value.absent(),
    Value<String?> systemPrompt = const Value.absent(),
    Value<double?> temperature = const Value.absent(),
    Value<int?> maxTokens = const Value.absent(),
    String? variablesJson,
    int? updatedAt,
    Value<String?> workspaceId = const Value.absent(),
  }) => AiPromptMetaRow(
    snippetId: snippetId ?? this.snippetId,
    targetModel: targetModel.present ? targetModel.value : this.targetModel,
    modelProvider: modelProvider.present
        ? modelProvider.value
        : this.modelProvider,
    systemPrompt: systemPrompt.present ? systemPrompt.value : this.systemPrompt,
    temperature: temperature.present ? temperature.value : this.temperature,
    maxTokens: maxTokens.present ? maxTokens.value : this.maxTokens,
    variablesJson: variablesJson ?? this.variablesJson,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
  );
  AiPromptMetaRow copyWithCompanion(AiPromptMetaCompanion data) {
    return AiPromptMetaRow(
      snippetId: data.snippetId.present ? data.snippetId.value : this.snippetId,
      targetModel: data.targetModel.present
          ? data.targetModel.value
          : this.targetModel,
      modelProvider: data.modelProvider.present
          ? data.modelProvider.value
          : this.modelProvider,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      maxTokens: data.maxTokens.present ? data.maxTokens.value : this.maxTokens,
      variablesJson: data.variablesJson.present
          ? data.variablesJson.value
          : this.variablesJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiPromptMetaRow(')
          ..write('snippetId: $snippetId, ')
          ..write('targetModel: $targetModel, ')
          ..write('modelProvider: $modelProvider, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('temperature: $temperature, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('variablesJson: $variablesJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    snippetId,
    targetModel,
    modelProvider,
    systemPrompt,
    temperature,
    maxTokens,
    variablesJson,
    updatedAt,
    workspaceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiPromptMetaRow &&
          other.snippetId == this.snippetId &&
          other.targetModel == this.targetModel &&
          other.modelProvider == this.modelProvider &&
          other.systemPrompt == this.systemPrompt &&
          other.temperature == this.temperature &&
          other.maxTokens == this.maxTokens &&
          other.variablesJson == this.variablesJson &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId);
}

class AiPromptMetaCompanion extends UpdateCompanion<AiPromptMetaRow> {
  final Value<String> snippetId;
  final Value<String?> targetModel;
  final Value<String?> modelProvider;
  final Value<String?> systemPrompt;
  final Value<double?> temperature;
  final Value<int?> maxTokens;
  final Value<String> variablesJson;
  final Value<int> updatedAt;
  final Value<String?> workspaceId;
  final Value<int> rowid;
  const AiPromptMetaCompanion({
    this.snippetId = const Value.absent(),
    this.targetModel = const Value.absent(),
    this.modelProvider = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.temperature = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.variablesJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiPromptMetaCompanion.insert({
    required String snippetId,
    this.targetModel = const Value.absent(),
    this.modelProvider = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.temperature = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.variablesJson = const Value.absent(),
    required int updatedAt,
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : snippetId = Value(snippetId),
       updatedAt = Value(updatedAt);
  static Insertable<AiPromptMetaRow> custom({
    Expression<String>? snippetId,
    Expression<String>? targetModel,
    Expression<String>? modelProvider,
    Expression<String>? systemPrompt,
    Expression<double>? temperature,
    Expression<int>? maxTokens,
    Expression<String>? variablesJson,
    Expression<int>? updatedAt,
    Expression<String>? workspaceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (snippetId != null) 'snippet_id': snippetId,
      if (targetModel != null) 'target_model': targetModel,
      if (modelProvider != null) 'model_provider': modelProvider,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (variablesJson != null) 'variables_json': variablesJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiPromptMetaCompanion copyWith({
    Value<String>? snippetId,
    Value<String?>? targetModel,
    Value<String?>? modelProvider,
    Value<String?>? systemPrompt,
    Value<double?>? temperature,
    Value<int?>? maxTokens,
    Value<String>? variablesJson,
    Value<int>? updatedAt,
    Value<String?>? workspaceId,
    Value<int>? rowid,
  }) {
    return AiPromptMetaCompanion(
      snippetId: snippetId ?? this.snippetId,
      targetModel: targetModel ?? this.targetModel,
      modelProvider: modelProvider ?? this.modelProvider,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      variablesJson: variablesJson ?? this.variablesJson,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (snippetId.present) {
      map['snippet_id'] = Variable<String>(snippetId.value);
    }
    if (targetModel.present) {
      map['target_model'] = Variable<String>(targetModel.value);
    }
    if (modelProvider.present) {
      map['model_provider'] = Variable<String>(modelProvider.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (maxTokens.present) {
      map['max_tokens'] = Variable<int>(maxTokens.value);
    }
    if (variablesJson.present) {
      map['variables_json'] = Variable<String>(variablesJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiPromptMetaCompanion(')
          ..write('snippetId: $snippetId, ')
          ..write('targetModel: $targetModel, ')
          ..write('modelProvider: $modelProvider, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('temperature: $temperature, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('variablesJson: $variablesJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurposesTable extends Purposes
    with TableInfo<$PurposesTable, PurposeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurposesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliesToTypeMeta = const VerificationMeta(
    'appliesToType',
  );
  @override
  late final GeneratedColumn<String> appliesToType = GeneratedColumn<String>(
    'applies_to_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, appliesToType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purposes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurposeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('applies_to_type')) {
      context.handle(
        _appliesToTypeMeta,
        appliesToType.isAcceptableOrUnknown(
          data['applies_to_type']!,
          _appliesToTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurposeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurposeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      appliesToType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applies_to_type'],
      ),
    );
  }

  @override
  $PurposesTable createAlias(String alias) {
    return $PurposesTable(attachedDatabase, alias);
  }
}

class PurposeRow extends DataClass implements Insertable<PurposeRow> {
  final String id;
  final String label;
  final String? appliesToType;
  const PurposeRow({required this.id, required this.label, this.appliesToType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || appliesToType != null) {
      map['applies_to_type'] = Variable<String>(appliesToType);
    }
    return map;
  }

  PurposesCompanion toCompanion(bool nullToAbsent) {
    return PurposesCompanion(
      id: Value(id),
      label: Value(label),
      appliesToType: appliesToType == null && nullToAbsent
          ? const Value.absent()
          : Value(appliesToType),
    );
  }

  factory PurposeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurposeRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      appliesToType: serializer.fromJson<String?>(json['appliesToType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'appliesToType': serializer.toJson<String?>(appliesToType),
    };
  }

  PurposeRow copyWith({
    String? id,
    String? label,
    Value<String?> appliesToType = const Value.absent(),
  }) => PurposeRow(
    id: id ?? this.id,
    label: label ?? this.label,
    appliesToType: appliesToType.present
        ? appliesToType.value
        : this.appliesToType,
  );
  PurposeRow copyWithCompanion(PurposesCompanion data) {
    return PurposeRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      appliesToType: data.appliesToType.present
          ? data.appliesToType.value
          : this.appliesToType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurposeRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('appliesToType: $appliesToType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, appliesToType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurposeRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.appliesToType == this.appliesToType);
}

class PurposesCompanion extends UpdateCompanion<PurposeRow> {
  final Value<String> id;
  final Value<String> label;
  final Value<String?> appliesToType;
  final Value<int> rowid;
  const PurposesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.appliesToType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurposesCompanion.insert({
    required String id,
    required String label,
    this.appliesToType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label);
  static Insertable<PurposeRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? appliesToType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (appliesToType != null) 'applies_to_type': appliesToType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurposesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String?>? appliesToType,
    Value<int>? rowid,
  }) {
    return PurposesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      appliesToType: appliesToType ?? this.appliesToType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (appliesToType.present) {
      map['applies_to_type'] = Variable<String>(appliesToType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurposesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('appliesToType: $appliesToType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snippetIdMeta = const VerificationMeta(
    'snippetId',
  );
  @override
  late final GeneratedColumn<String> snippetId = GeneratedColumn<String>(
    'snippet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    snippetId,
    filename,
    mimeType,
    bytes,
    sizeBytes,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
    ownerId,
    workspaceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('snippet_id')) {
      context.handle(
        _snippetIdMeta,
        snippetId.isAcceptableOrUnknown(data['snippet_id']!, _snippetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_snippetIdMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      snippetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet_id'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      ),
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final String id;
  final String snippetId;
  final String filename;
  final String mimeType;
  final Uint8List bytes;
  final int sizeBytes;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final bool dirty;
  final String? ownerId;
  final String? workspaceId;
  const AttachmentRow({
    required this.id,
    required this.snippetId,
    required this.filename,
    required this.mimeType,
    required this.bytes,
    required this.sizeBytes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.ownerId,
    this.workspaceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['snippet_id'] = Variable<String>(snippetId);
    map['filename'] = Variable<String>(filename);
    map['mime_type'] = Variable<String>(mimeType);
    map['bytes'] = Variable<Uint8List>(bytes);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<String>(workspaceId);
    }
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      snippetId: Value(snippetId),
      filename: Value(filename),
      mimeType: Value(mimeType),
      bytes: Value(bytes),
      sizeBytes: Value(sizeBytes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      snippetId: serializer.fromJson<String>(json['snippetId']),
      filename: serializer.fromJson<String>(json['filename']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      workspaceId: serializer.fromJson<String?>(json['workspaceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'snippetId': serializer.toJson<String>(snippetId),
      'filename': serializer.toJson<String>(filename),
      'mimeType': serializer.toJson<String>(mimeType),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'ownerId': serializer.toJson<String?>(ownerId),
      'workspaceId': serializer.toJson<String?>(workspaceId),
    };
  }

  AttachmentRow copyWith({
    String? id,
    String? snippetId,
    String? filename,
    String? mimeType,
    Uint8List? bytes,
    int? sizeBytes,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<String?> ownerId = const Value.absent(),
    Value<String?> workspaceId = const Value.absent(),
  }) => AttachmentRow(
    id: id ?? this.id,
    snippetId: snippetId ?? this.snippetId,
    filename: filename ?? this.filename,
    mimeType: mimeType ?? this.mimeType,
    bytes: bytes ?? this.bytes,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      snippetId: data.snippetId.present ? data.snippetId.value : this.snippetId,
      filename: data.filename.present ? data.filename.value : this.filename,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('id: $id, ')
          ..write('snippetId: $snippetId, ')
          ..write('filename: $filename, ')
          ..write('mimeType: $mimeType, ')
          ..write('bytes: $bytes, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    snippetId,
    filename,
    mimeType,
    $driftBlobEquality.hash(bytes),
    sizeBytes,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
    ownerId,
    workspaceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.id == this.id &&
          other.snippetId == this.snippetId &&
          other.filename == this.filename &&
          other.mimeType == this.mimeType &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.ownerId == this.ownerId &&
          other.workspaceId == this.workspaceId);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<String> id;
  final Value<String> snippetId;
  final Value<String> filename;
  final Value<String> mimeType;
  final Value<Uint8List> bytes;
  final Value<int> sizeBytes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> dirty;
  final Value<String?> ownerId;
  final Value<String?> workspaceId;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.snippetId = const Value.absent(),
    this.filename = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.bytes = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String snippetId,
    this.filename = const Value.absent(),
    this.mimeType = const Value.absent(),
    required Uint8List bytes,
    this.sizeBytes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       snippetId = Value(snippetId),
       bytes = Value(bytes),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AttachmentRow> custom({
    Expression<String>? id,
    Expression<String>? snippetId,
    Expression<String>? filename,
    Expression<String>? mimeType,
    Expression<Uint8List>? bytes,
    Expression<int>? sizeBytes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? dirty,
    Expression<String>? ownerId,
    Expression<String>? workspaceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (snippetId != null) 'snippet_id': snippetId,
      if (filename != null) 'filename': filename,
      if (mimeType != null) 'mime_type': mimeType,
      if (bytes != null) 'bytes': bytes,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (ownerId != null) 'owner_id': ownerId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? snippetId,
    Value<String>? filename,
    Value<String>? mimeType,
    Value<Uint8List>? bytes,
    Value<int>? sizeBytes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? dirty,
    Value<String?>? ownerId,
    Value<String?>? workspaceId,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      snippetId: snippetId ?? this.snippetId,
      filename: filename ?? this.filename,
      mimeType: mimeType ?? this.mimeType,
      bytes: bytes ?? this.bytes,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      ownerId: ownerId ?? this.ownerId,
      workspaceId: workspaceId ?? this.workspaceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (snippetId.present) {
      map['snippet_id'] = Variable<String>(snippetId.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('snippetId: $snippetId, ')
          ..write('filename: $filename, ')
          ..write('mimeType: $mimeType, ')
          ..write('bytes: $bytes, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('ownerId: $ownerId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, WorkspaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    ownerId,
    role,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkspaceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkspaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class WorkspaceRow extends DataClass implements Insertable<WorkspaceRow> {
  final String id;
  final String name;
  final String ownerId;
  final String? role;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final bool dirty;
  const WorkspaceRow({
    required this.id,
    required this.name,
    required this.ownerId,
    this.role,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['owner_id'] = Variable<String>(ownerId);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      name: Value(name),
      ownerId: Value(ownerId),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
    );
  }

  factory WorkspaceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      role: serializer.fromJson<String?>(json['role']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'ownerId': serializer.toJson<String>(ownerId),
      'role': serializer.toJson<String?>(role),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  WorkspaceRow copyWith({
    String? id,
    String? name,
    String? ownerId,
    Value<String?> role = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? dirty,
  }) => WorkspaceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    ownerId: ownerId ?? this.ownerId,
    role: role.present ? role.value : this.role,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
  );
  WorkspaceRow copyWithCompanion(WorkspacesCompanion data) {
    return WorkspaceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ownerId: $ownerId, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    ownerId,
    role,
    createdAt,
    updatedAt,
    deletedAt,
    dirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.ownerId == this.ownerId &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty);
}

class WorkspacesCompanion extends UpdateCompanion<WorkspaceRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> ownerId;
  final Value<String?> role;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> dirty;
  final Value<int> rowid;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    required String id,
    required String name,
    required String ownerId,
    this.role = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkspaceRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? ownerId,
    Expression<String>? role,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (ownerId != null) 'owner_id': ownerId,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspacesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? ownerId,
    Value<String?>? role,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? dirty,
    Value<int>? rowid,
  }) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ownerId: $ownerId, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspaceMembersTable extends WorkspaceMembers
    with TableInfo<$WorkspaceMembersTable, WorkspaceMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspaceMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    workspaceId,
    userId,
    email,
    role,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspace_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkspaceMemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workspaceId, userId};
  @override
  WorkspaceMemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceMemberRow(
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkspaceMembersTable createAlias(String alias) {
    return $WorkspaceMembersTable(attachedDatabase, alias);
  }
}

class WorkspaceMemberRow extends DataClass
    implements Insertable<WorkspaceMemberRow> {
  final String workspaceId;
  final String userId;
  final String email;
  final String role;
  final int createdAt;
  const WorkspaceMemberRow({
    required this.workspaceId,
    required this.userId,
    required this.email,
    required this.role,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workspace_id'] = Variable<String>(workspaceId);
    map['user_id'] = Variable<String>(userId);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  WorkspaceMembersCompanion toCompanion(bool nullToAbsent) {
    return WorkspaceMembersCompanion(
      workspaceId: Value(workspaceId),
      userId: Value(userId),
      email: Value(email),
      role: Value(role),
      createdAt: Value(createdAt),
    );
  }

  factory WorkspaceMemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceMemberRow(
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      userId: serializer.fromJson<String>(json['userId']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workspaceId': serializer.toJson<String>(workspaceId),
      'userId': serializer.toJson<String>(userId),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  WorkspaceMemberRow copyWith({
    String? workspaceId,
    String? userId,
    String? email,
    String? role,
    int? createdAt,
  }) => WorkspaceMemberRow(
    workspaceId: workspaceId ?? this.workspaceId,
    userId: userId ?? this.userId,
    email: email ?? this.email,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkspaceMemberRow copyWithCompanion(WorkspaceMembersCompanion data) {
    return WorkspaceMemberRow(
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceMemberRow(')
          ..write('workspaceId: $workspaceId, ')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workspaceId, userId, email, role, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceMemberRow &&
          other.workspaceId == this.workspaceId &&
          other.userId == this.userId &&
          other.email == this.email &&
          other.role == this.role &&
          other.createdAt == this.createdAt);
}

class WorkspaceMembersCompanion extends UpdateCompanion<WorkspaceMemberRow> {
  final Value<String> workspaceId;
  final Value<String> userId;
  final Value<String> email;
  final Value<String> role;
  final Value<int> createdAt;
  final Value<int> rowid;
  const WorkspaceMembersCompanion({
    this.workspaceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspaceMembersCompanion.insert({
    required String workspaceId,
    required String userId,
    required String email,
    required String role,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       userId = Value(userId),
       email = Value(email),
       role = Value(role),
       createdAt = Value(createdAt);
  static Insertable<WorkspaceMemberRow> custom({
    Expression<String>? workspaceId,
    Expression<String>? userId,
    Expression<String>? email,
    Expression<String>? role,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (userId != null) 'user_id': userId,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspaceMembersCompanion copyWith({
    Value<String>? workspaceId,
    Value<String>? userId,
    Value<String>? email,
    Value<String>? role,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return WorkspaceMembersCompanion(
      workspaceId: workspaceId ?? this.workspaceId,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceMembersCompanion(')
          ..write('workspaceId: $workspaceId, ')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SnippetsTable snippets = $SnippetsTable(this);
  late final $SnippetFilesTable snippetFiles = $SnippetFilesTable(this);
  late final $SnippetFileVersionsTable snippetFileVersions =
      $SnippetFileVersionsTable(this);
  late final $LanguagesTable languages = $LanguagesTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $SnippetTagsTable snippetTags = $SnippetTagsTable(this);
  late final $AiPromptMetaTable aiPromptMeta = $AiPromptMetaTable(this);
  late final $PurposesTable purposes = $PurposesTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $WorkspaceMembersTable workspaceMembers = $WorkspaceMembersTable(
    this,
  );
  late final Index snippetTypeIdx = Index(
    'snippet_type_idx',
    'CREATE INDEX snippet_type_idx ON snippets (type)',
  );
  late final Index snippetLanguageIdx = Index(
    'snippet_language_idx',
    'CREATE INDEX snippet_language_idx ON snippets (language_id)',
  );
  late final Index snippetCollectionIdx = Index(
    'snippet_collection_idx',
    'CREATE INDEX snippet_collection_idx ON snippets (collection_id)',
  );
  late final Index snippetFavoriteIdx = Index(
    'snippet_favorite_idx',
    'CREATE INDEX snippet_favorite_idx ON snippets (is_favorite)',
  );
  late final Index snippetUpdatedIdx = Index(
    'snippet_updated_idx',
    'CREATE INDEX snippet_updated_idx ON snippets (updated_at)',
  );
  late final Index snippetDeletedIdx = Index(
    'snippet_deleted_idx',
    'CREATE INDEX snippet_deleted_idx ON snippets (deleted_at)',
  );
  late final Index snippetFilesSnippetIdx = Index(
    'snippet_files_snippet_idx',
    'CREATE INDEX snippet_files_snippet_idx ON snippet_files (snippet_id)',
  );
  late final Index snippetFilesDeletedIdx = Index(
    'snippet_files_deleted_idx',
    'CREATE INDEX snippet_files_deleted_idx ON snippet_files (deleted_at)',
  );
  late final Index snippetFileVersionsSnippetIdx = Index(
    'snippet_file_versions_snippet_idx',
    'CREATE INDEX snippet_file_versions_snippet_idx ON snippet_file_versions (snippet_id)',
  );
  late final Index snippetFileVersionsSavedIdx = Index(
    'snippet_file_versions_saved_idx',
    'CREATE INDEX snippet_file_versions_saved_idx ON snippet_file_versions (saved_at)',
  );
  late final Index collectionParentIdx = Index(
    'collection_parent_idx',
    'CREATE INDEX collection_parent_idx ON collections (parent_id)',
  );
  late final Index tagNormalizedIdx = Index(
    'tag_normalized_idx',
    'CREATE INDEX tag_normalized_idx ON tags (normalized_name)',
  );
  late final Index snippetTagsTagIdx = Index(
    'snippet_tags_tag_idx',
    'CREATE INDEX snippet_tags_tag_idx ON snippet_tags (tag_id)',
  );
  late final Index attachmentsSnippetIdx = Index(
    'attachments_snippet_idx',
    'CREATE INDEX attachments_snippet_idx ON attachments (snippet_id)',
  );
  late final Index attachmentsDeletedIdx = Index(
    'attachments_deleted_idx',
    'CREATE INDEX attachments_deleted_idx ON attachments (deleted_at)',
  );
  late final Index workspaceMembersWsIdx = Index(
    'workspace_members_ws_idx',
    'CREATE INDEX workspace_members_ws_idx ON workspace_members (workspace_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    snippets,
    snippetFiles,
    snippetFileVersions,
    languages,
    collections,
    tags,
    snippetTags,
    aiPromptMeta,
    purposes,
    attachments,
    workspaces,
    workspaceMembers,
    snippetTypeIdx,
    snippetLanguageIdx,
    snippetCollectionIdx,
    snippetFavoriteIdx,
    snippetUpdatedIdx,
    snippetDeletedIdx,
    snippetFilesSnippetIdx,
    snippetFilesDeletedIdx,
    snippetFileVersionsSnippetIdx,
    snippetFileVersionsSavedIdx,
    collectionParentIdx,
    tagNormalizedIdx,
    snippetTagsTagIdx,
    attachmentsSnippetIdx,
    attachmentsDeletedIdx,
    workspaceMembersWsIdx,
  ];
}

typedef $$SnippetsTableCreateCompanionBuilder =
    SnippetsCompanion Function({
      required String id,
      required String title,
      required String body,
      required String type,
      Value<String?> languageId,
      Value<String?> purpose,
      Value<String?> description,
      Value<String?> collectionId,
      Value<String> visibility,
      Value<bool> isFavorite,
      Value<int?> sortIndex,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });
typedef $$SnippetsTableUpdateCompanionBuilder =
    SnippetsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> body,
      Value<String> type,
      Value<String?> languageId,
      Value<String?> purpose,
      Value<String?> description,
      Value<String?> collectionId,
      Value<String> visibility,
      Value<bool> isFavorite,
      Value<int?> sortIndex,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });

class $$SnippetsTableFilterComposer
    extends Composer<_$AppDatabase, $SnippetsTable> {
  $$SnippetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SnippetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SnippetsTable> {
  $$SnippetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnippetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnippetsTable> {
  $$SnippetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );
}

class $$SnippetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnippetsTable,
          SnippetRow,
          $$SnippetsTableFilterComposer,
          $$SnippetsTableOrderingComposer,
          $$SnippetsTableAnnotationComposer,
          $$SnippetsTableCreateCompanionBuilder,
          $$SnippetsTableUpdateCompanionBuilder,
          (
            SnippetRow,
            BaseReferences<_$AppDatabase, $SnippetsTable, SnippetRow>,
          ),
          SnippetRow,
          PrefetchHooks Function()
        > {
  $$SnippetsTableTableManager(_$AppDatabase db, $SnippetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnippetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnippetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnippetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> languageId = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int?> sortIndex = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnippetsCompanion(
                id: id,
                title: title,
                body: body,
                type: type,
                languageId: languageId,
                purpose: purpose,
                description: description,
                collectionId: collectionId,
                visibility: visibility,
                isFavorite: isFavorite,
                sortIndex: sortIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String body,
                required String type,
                Value<String?> languageId = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int?> sortIndex = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnippetsCompanion.insert(
                id: id,
                title: title,
                body: body,
                type: type,
                languageId: languageId,
                purpose: purpose,
                description: description,
                collectionId: collectionId,
                visibility: visibility,
                isFavorite: isFavorite,
                sortIndex: sortIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SnippetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnippetsTable,
      SnippetRow,
      $$SnippetsTableFilterComposer,
      $$SnippetsTableOrderingComposer,
      $$SnippetsTableAnnotationComposer,
      $$SnippetsTableCreateCompanionBuilder,
      $$SnippetsTableUpdateCompanionBuilder,
      (SnippetRow, BaseReferences<_$AppDatabase, $SnippetsTable, SnippetRow>),
      SnippetRow,
      PrefetchHooks Function()
    >;
typedef $$SnippetFilesTableCreateCompanionBuilder =
    SnippetFilesCompanion Function({
      required String id,
      required String snippetId,
      Value<String> filename,
      Value<String?> languageId,
      Value<String> content,
      Value<int> position,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });
typedef $$SnippetFilesTableUpdateCompanionBuilder =
    SnippetFilesCompanion Function({
      Value<String> id,
      Value<String> snippetId,
      Value<String> filename,
      Value<String?> languageId,
      Value<String> content,
      Value<int> position,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });

class $$SnippetFilesTableFilterComposer
    extends Composer<_$AppDatabase, $SnippetFilesTable> {
  $$SnippetFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snippetId => $composableBuilder(
    column: $table.snippetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SnippetFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $SnippetFilesTable> {
  $$SnippetFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snippetId => $composableBuilder(
    column: $table.snippetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnippetFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnippetFilesTable> {
  $$SnippetFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get snippetId =>
      $composableBuilder(column: $table.snippetId, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );
}

class $$SnippetFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnippetFilesTable,
          SnippetFileRow,
          $$SnippetFilesTableFilterComposer,
          $$SnippetFilesTableOrderingComposer,
          $$SnippetFilesTableAnnotationComposer,
          $$SnippetFilesTableCreateCompanionBuilder,
          $$SnippetFilesTableUpdateCompanionBuilder,
          (
            SnippetFileRow,
            BaseReferences<_$AppDatabase, $SnippetFilesTable, SnippetFileRow>,
          ),
          SnippetFileRow,
          PrefetchHooks Function()
        > {
  $$SnippetFilesTableTableManager(_$AppDatabase db, $SnippetFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnippetFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnippetFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnippetFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> snippetId = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<String?> languageId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnippetFilesCompanion(
                id: id,
                snippetId: snippetId,
                filename: filename,
                languageId: languageId,
                content: content,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String snippetId,
                Value<String> filename = const Value.absent(),
                Value<String?> languageId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> position = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnippetFilesCompanion.insert(
                id: id,
                snippetId: snippetId,
                filename: filename,
                languageId: languageId,
                content: content,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SnippetFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnippetFilesTable,
      SnippetFileRow,
      $$SnippetFilesTableFilterComposer,
      $$SnippetFilesTableOrderingComposer,
      $$SnippetFilesTableAnnotationComposer,
      $$SnippetFilesTableCreateCompanionBuilder,
      $$SnippetFilesTableUpdateCompanionBuilder,
      (
        SnippetFileRow,
        BaseReferences<_$AppDatabase, $SnippetFilesTable, SnippetFileRow>,
      ),
      SnippetFileRow,
      PrefetchHooks Function()
    >;
typedef $$SnippetFileVersionsTableCreateCompanionBuilder =
    SnippetFileVersionsCompanion Function({
      required String id,
      required String snippetId,
      Value<String> filename,
      Value<String?> languageId,
      Value<String> content,
      Value<int> position,
      required int savedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });
typedef $$SnippetFileVersionsTableUpdateCompanionBuilder =
    SnippetFileVersionsCompanion Function({
      Value<String> id,
      Value<String> snippetId,
      Value<String> filename,
      Value<String?> languageId,
      Value<String> content,
      Value<int> position,
      Value<int> savedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });

class $$SnippetFileVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $SnippetFileVersionsTable> {
  $$SnippetFileVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snippetId => $composableBuilder(
    column: $table.snippetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SnippetFileVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SnippetFileVersionsTable> {
  $$SnippetFileVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snippetId => $composableBuilder(
    column: $table.snippetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnippetFileVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnippetFileVersionsTable> {
  $$SnippetFileVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get snippetId =>
      $composableBuilder(column: $table.snippetId, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );
}

class $$SnippetFileVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnippetFileVersionsTable,
          SnippetFileVersionRow,
          $$SnippetFileVersionsTableFilterComposer,
          $$SnippetFileVersionsTableOrderingComposer,
          $$SnippetFileVersionsTableAnnotationComposer,
          $$SnippetFileVersionsTableCreateCompanionBuilder,
          $$SnippetFileVersionsTableUpdateCompanionBuilder,
          (
            SnippetFileVersionRow,
            BaseReferences<
              _$AppDatabase,
              $SnippetFileVersionsTable,
              SnippetFileVersionRow
            >,
          ),
          SnippetFileVersionRow,
          PrefetchHooks Function()
        > {
  $$SnippetFileVersionsTableTableManager(
    _$AppDatabase db,
    $SnippetFileVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnippetFileVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnippetFileVersionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SnippetFileVersionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> snippetId = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<String?> languageId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> savedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnippetFileVersionsCompanion(
                id: id,
                snippetId: snippetId,
                filename: filename,
                languageId: languageId,
                content: content,
                position: position,
                savedAt: savedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String snippetId,
                Value<String> filename = const Value.absent(),
                Value<String?> languageId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> position = const Value.absent(),
                required int savedAt,
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnippetFileVersionsCompanion.insert(
                id: id,
                snippetId: snippetId,
                filename: filename,
                languageId: languageId,
                content: content,
                position: position,
                savedAt: savedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SnippetFileVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnippetFileVersionsTable,
      SnippetFileVersionRow,
      $$SnippetFileVersionsTableFilterComposer,
      $$SnippetFileVersionsTableOrderingComposer,
      $$SnippetFileVersionsTableAnnotationComposer,
      $$SnippetFileVersionsTableCreateCompanionBuilder,
      $$SnippetFileVersionsTableUpdateCompanionBuilder,
      (
        SnippetFileVersionRow,
        BaseReferences<
          _$AppDatabase,
          $SnippetFileVersionsTable,
          SnippetFileVersionRow
        >,
      ),
      SnippetFileVersionRow,
      PrefetchHooks Function()
    >;
typedef $$LanguagesTableCreateCompanionBuilder =
    LanguagesCompanion Function({
      required String id,
      required String name,
      required String fileExtension,
      required String grammarId,
      Value<String> aliasesJson,
      Value<int> rowid,
    });
typedef $$LanguagesTableUpdateCompanionBuilder =
    LanguagesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> fileExtension,
      Value<String> grammarId,
      Value<String> aliasesJson,
      Value<int> rowid,
    });

class $$LanguagesTableFilterComposer
    extends Composer<_$AppDatabase, $LanguagesTable> {
  $$LanguagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LanguagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LanguagesTable> {
  $$LanguagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LanguagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LanguagesTable> {
  $$LanguagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grammarId =>
      $composableBuilder(column: $table.grammarId, builder: (column) => column);

  GeneratedColumn<String> get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => column,
  );
}

class $$LanguagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LanguagesTable,
          LanguageRow,
          $$LanguagesTableFilterComposer,
          $$LanguagesTableOrderingComposer,
          $$LanguagesTableAnnotationComposer,
          $$LanguagesTableCreateCompanionBuilder,
          $$LanguagesTableUpdateCompanionBuilder,
          (
            LanguageRow,
            BaseReferences<_$AppDatabase, $LanguagesTable, LanguageRow>,
          ),
          LanguageRow,
          PrefetchHooks Function()
        > {
  $$LanguagesTableTableManager(_$AppDatabase db, $LanguagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LanguagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LanguagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LanguagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fileExtension = const Value.absent(),
                Value<String> grammarId = const Value.absent(),
                Value<String> aliasesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LanguagesCompanion(
                id: id,
                name: name,
                fileExtension: fileExtension,
                grammarId: grammarId,
                aliasesJson: aliasesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String fileExtension,
                required String grammarId,
                Value<String> aliasesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LanguagesCompanion.insert(
                id: id,
                name: name,
                fileExtension: fileExtension,
                grammarId: grammarId,
                aliasesJson: aliasesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LanguagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LanguagesTable,
      LanguageRow,
      $$LanguagesTableFilterComposer,
      $$LanguagesTableOrderingComposer,
      $$LanguagesTableAnnotationComposer,
      $$LanguagesTableCreateCompanionBuilder,
      $$LanguagesTableUpdateCompanionBuilder,
      (
        LanguageRow,
        BaseReferences<_$AppDatabase, $LanguagesTable, LanguageRow>,
      ),
      LanguageRow,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String id,
      required String name,
      Value<String?> parentId,
      Value<String?> icon,
      Value<String?> color,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<String?> icon,
      Value<String?> color,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          CollectionRow,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            CollectionRow,
            BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow>,
          ),
          CollectionRow,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                parentId: parentId,
                icon: icon,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> parentId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                icon: icon,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      CollectionRow,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        CollectionRow,
        BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow>,
      ),
      CollectionRow,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      required String normalizedName,
      Value<String?> color,
      Value<String?> parentId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> normalizedName,
      Value<String?> color,
      Value<String?> parentId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, BaseReferences<_$AppDatabase, $TagsTable, TagRow>),
          TagRow,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                normalizedName: normalizedName,
                color: color,
                parentId: parentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String normalizedName,
                Value<String?> color = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                normalizedName: normalizedName,
                color: color,
                parentId: parentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, BaseReferences<_$AppDatabase, $TagsTable, TagRow>),
      TagRow,
      PrefetchHooks Function()
    >;
typedef $$SnippetTagsTableCreateCompanionBuilder =
    SnippetTagsCompanion Function({
      required String snippetId,
      required String tagId,
      required int createdAt,
      Value<String?> workspaceId,
      Value<int> rowid,
    });
typedef $$SnippetTagsTableUpdateCompanionBuilder =
    SnippetTagsCompanion Function({
      Value<String> snippetId,
      Value<String> tagId,
      Value<int> createdAt,
      Value<String?> workspaceId,
      Value<int> rowid,
    });

class $$SnippetTagsTableFilterComposer
    extends Composer<_$AppDatabase, $SnippetTagsTable> {
  $$SnippetTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get snippetId => $composableBuilder(
    column: $table.snippetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SnippetTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $SnippetTagsTable> {
  $$SnippetTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get snippetId => $composableBuilder(
    column: $table.snippetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnippetTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnippetTagsTable> {
  $$SnippetTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get snippetId =>
      $composableBuilder(column: $table.snippetId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );
}

class $$SnippetTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnippetTagsTable,
          SnippetTagRow,
          $$SnippetTagsTableFilterComposer,
          $$SnippetTagsTableOrderingComposer,
          $$SnippetTagsTableAnnotationComposer,
          $$SnippetTagsTableCreateCompanionBuilder,
          $$SnippetTagsTableUpdateCompanionBuilder,
          (
            SnippetTagRow,
            BaseReferences<_$AppDatabase, $SnippetTagsTable, SnippetTagRow>,
          ),
          SnippetTagRow,
          PrefetchHooks Function()
        > {
  $$SnippetTagsTableTableManager(_$AppDatabase db, $SnippetTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnippetTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnippetTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnippetTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> snippetId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnippetTagsCompanion(
                snippetId: snippetId,
                tagId: tagId,
                createdAt: createdAt,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String snippetId,
                required String tagId,
                required int createdAt,
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnippetTagsCompanion.insert(
                snippetId: snippetId,
                tagId: tagId,
                createdAt: createdAt,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SnippetTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnippetTagsTable,
      SnippetTagRow,
      $$SnippetTagsTableFilterComposer,
      $$SnippetTagsTableOrderingComposer,
      $$SnippetTagsTableAnnotationComposer,
      $$SnippetTagsTableCreateCompanionBuilder,
      $$SnippetTagsTableUpdateCompanionBuilder,
      (
        SnippetTagRow,
        BaseReferences<_$AppDatabase, $SnippetTagsTable, SnippetTagRow>,
      ),
      SnippetTagRow,
      PrefetchHooks Function()
    >;
typedef $$AiPromptMetaTableCreateCompanionBuilder =
    AiPromptMetaCompanion Function({
      required String snippetId,
      Value<String?> targetModel,
      Value<String?> modelProvider,
      Value<String?> systemPrompt,
      Value<double?> temperature,
      Value<int?> maxTokens,
      Value<String> variablesJson,
      required int updatedAt,
      Value<String?> workspaceId,
      Value<int> rowid,
    });
typedef $$AiPromptMetaTableUpdateCompanionBuilder =
    AiPromptMetaCompanion Function({
      Value<String> snippetId,
      Value<String?> targetModel,
      Value<String?> modelProvider,
      Value<String?> systemPrompt,
      Value<double?> temperature,
      Value<int?> maxTokens,
      Value<String> variablesJson,
      Value<int> updatedAt,
      Value<String?> workspaceId,
      Value<int> rowid,
    });

class $$AiPromptMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AiPromptMetaTable> {
  $$AiPromptMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get snippetId => $composableBuilder(
    column: $table.snippetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetModel => $composableBuilder(
    column: $table.targetModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelProvider => $composableBuilder(
    column: $table.modelProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxTokens => $composableBuilder(
    column: $table.maxTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variablesJson => $composableBuilder(
    column: $table.variablesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiPromptMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AiPromptMetaTable> {
  $$AiPromptMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get snippetId => $composableBuilder(
    column: $table.snippetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetModel => $composableBuilder(
    column: $table.targetModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelProvider => $composableBuilder(
    column: $table.modelProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxTokens => $composableBuilder(
    column: $table.maxTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variablesJson => $composableBuilder(
    column: $table.variablesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiPromptMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiPromptMetaTable> {
  $$AiPromptMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get snippetId =>
      $composableBuilder(column: $table.snippetId, builder: (column) => column);

  GeneratedColumn<String> get targetModel => $composableBuilder(
    column: $table.targetModel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelProvider => $composableBuilder(
    column: $table.modelProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxTokens =>
      $composableBuilder(column: $table.maxTokens, builder: (column) => column);

  GeneratedColumn<String> get variablesJson => $composableBuilder(
    column: $table.variablesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );
}

class $$AiPromptMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiPromptMetaTable,
          AiPromptMetaRow,
          $$AiPromptMetaTableFilterComposer,
          $$AiPromptMetaTableOrderingComposer,
          $$AiPromptMetaTableAnnotationComposer,
          $$AiPromptMetaTableCreateCompanionBuilder,
          $$AiPromptMetaTableUpdateCompanionBuilder,
          (
            AiPromptMetaRow,
            BaseReferences<_$AppDatabase, $AiPromptMetaTable, AiPromptMetaRow>,
          ),
          AiPromptMetaRow,
          PrefetchHooks Function()
        > {
  $$AiPromptMetaTableTableManager(_$AppDatabase db, $AiPromptMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiPromptMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiPromptMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiPromptMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> snippetId = const Value.absent(),
                Value<String?> targetModel = const Value.absent(),
                Value<String?> modelProvider = const Value.absent(),
                Value<String?> systemPrompt = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<int?> maxTokens = const Value.absent(),
                Value<String> variablesJson = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiPromptMetaCompanion(
                snippetId: snippetId,
                targetModel: targetModel,
                modelProvider: modelProvider,
                systemPrompt: systemPrompt,
                temperature: temperature,
                maxTokens: maxTokens,
                variablesJson: variablesJson,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String snippetId,
                Value<String?> targetModel = const Value.absent(),
                Value<String?> modelProvider = const Value.absent(),
                Value<String?> systemPrompt = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<int?> maxTokens = const Value.absent(),
                Value<String> variablesJson = const Value.absent(),
                required int updatedAt,
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiPromptMetaCompanion.insert(
                snippetId: snippetId,
                targetModel: targetModel,
                modelProvider: modelProvider,
                systemPrompt: systemPrompt,
                temperature: temperature,
                maxTokens: maxTokens,
                variablesJson: variablesJson,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiPromptMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiPromptMetaTable,
      AiPromptMetaRow,
      $$AiPromptMetaTableFilterComposer,
      $$AiPromptMetaTableOrderingComposer,
      $$AiPromptMetaTableAnnotationComposer,
      $$AiPromptMetaTableCreateCompanionBuilder,
      $$AiPromptMetaTableUpdateCompanionBuilder,
      (
        AiPromptMetaRow,
        BaseReferences<_$AppDatabase, $AiPromptMetaTable, AiPromptMetaRow>,
      ),
      AiPromptMetaRow,
      PrefetchHooks Function()
    >;
typedef $$PurposesTableCreateCompanionBuilder =
    PurposesCompanion Function({
      required String id,
      required String label,
      Value<String?> appliesToType,
      Value<int> rowid,
    });
typedef $$PurposesTableUpdateCompanionBuilder =
    PurposesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String?> appliesToType,
      Value<int> rowid,
    });

class $$PurposesTableFilterComposer
    extends Composer<_$AppDatabase, $PurposesTable> {
  $$PurposesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliesToType => $composableBuilder(
    column: $table.appliesToType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PurposesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurposesTable> {
  $$PurposesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliesToType => $composableBuilder(
    column: $table.appliesToType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurposesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurposesTable> {
  $$PurposesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get appliesToType => $composableBuilder(
    column: $table.appliesToType,
    builder: (column) => column,
  );
}

class $$PurposesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurposesTable,
          PurposeRow,
          $$PurposesTableFilterComposer,
          $$PurposesTableOrderingComposer,
          $$PurposesTableAnnotationComposer,
          $$PurposesTableCreateCompanionBuilder,
          $$PurposesTableUpdateCompanionBuilder,
          (
            PurposeRow,
            BaseReferences<_$AppDatabase, $PurposesTable, PurposeRow>,
          ),
          PurposeRow,
          PrefetchHooks Function()
        > {
  $$PurposesTableTableManager(_$AppDatabase db, $PurposesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurposesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurposesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurposesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> appliesToType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurposesCompanion(
                id: id,
                label: label,
                appliesToType: appliesToType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                Value<String?> appliesToType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurposesCompanion.insert(
                id: id,
                label: label,
                appliesToType: appliesToType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurposesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurposesTable,
      PurposeRow,
      $$PurposesTableFilterComposer,
      $$PurposesTableOrderingComposer,
      $$PurposesTableAnnotationComposer,
      $$PurposesTableCreateCompanionBuilder,
      $$PurposesTableUpdateCompanionBuilder,
      (PurposeRow, BaseReferences<_$AppDatabase, $PurposesTable, PurposeRow>),
      PurposeRow,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String snippetId,
      Value<String> filename,
      Value<String> mimeType,
      required Uint8List bytes,
      Value<int> sizeBytes,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> snippetId,
      Value<String> filename,
      Value<String> mimeType,
      Value<Uint8List> bytes,
      Value<int> sizeBytes,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<String?> ownerId,
      Value<String?> workspaceId,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snippetId => $composableBuilder(
    column: $table.snippetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snippetId => $composableBuilder(
    column: $table.snippetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get snippetId =>
      $composableBuilder(column: $table.snippetId, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          AttachmentRow,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            AttachmentRow,
            BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow>,
          ),
          AttachmentRow,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> snippetId = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                snippetId: snippetId,
                filename: filename,
                mimeType: mimeType,
                bytes: bytes,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String snippetId,
                Value<String> filename = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                required Uint8List bytes,
                Value<int> sizeBytes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> workspaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                snippetId: snippetId,
                filename: filename,
                mimeType: mimeType,
                bytes: bytes,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                ownerId: ownerId,
                workspaceId: workspaceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      AttachmentRow,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        AttachmentRow,
        BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow>,
      ),
      AttachmentRow,
      PrefetchHooks Function()
    >;
typedef $$WorkspacesTableCreateCompanionBuilder =
    WorkspacesCompanion Function({
      required String id,
      required String name,
      required String ownerId,
      Value<String?> role,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });
typedef $$WorkspacesTableUpdateCompanionBuilder =
    WorkspacesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> ownerId,
      Value<String?> role,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });

class $$WorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$WorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspacesTable,
          WorkspaceRow,
          $$WorkspacesTableFilterComposer,
          $$WorkspacesTableOrderingComposer,
          $$WorkspacesTableAnnotationComposer,
          $$WorkspacesTableCreateCompanionBuilder,
          $$WorkspacesTableUpdateCompanionBuilder,
          (
            WorkspaceRow,
            BaseReferences<_$AppDatabase, $WorkspacesTable, WorkspaceRow>,
          ),
          WorkspaceRow,
          PrefetchHooks Function()
        > {
  $$WorkspacesTableTableManager(_$AppDatabase db, $WorkspacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion(
                id: id,
                name: name,
                ownerId: ownerId,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String ownerId,
                Value<String?> role = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion.insert(
                id: id,
                name: name,
                ownerId: ownerId,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspacesTable,
      WorkspaceRow,
      $$WorkspacesTableFilterComposer,
      $$WorkspacesTableOrderingComposer,
      $$WorkspacesTableAnnotationComposer,
      $$WorkspacesTableCreateCompanionBuilder,
      $$WorkspacesTableUpdateCompanionBuilder,
      (
        WorkspaceRow,
        BaseReferences<_$AppDatabase, $WorkspacesTable, WorkspaceRow>,
      ),
      WorkspaceRow,
      PrefetchHooks Function()
    >;
typedef $$WorkspaceMembersTableCreateCompanionBuilder =
    WorkspaceMembersCompanion Function({
      required String workspaceId,
      required String userId,
      required String email,
      required String role,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$WorkspaceMembersTableUpdateCompanionBuilder =
    WorkspaceMembersCompanion Function({
      Value<String> workspaceId,
      Value<String> userId,
      Value<String> email,
      Value<String> role,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$WorkspaceMembersTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspaceMembersTable> {
  $$WorkspaceMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspaceMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspaceMembersTable> {
  $$WorkspaceMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspaceMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspaceMembersTable> {
  $$WorkspaceMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkspaceMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspaceMembersTable,
          WorkspaceMemberRow,
          $$WorkspaceMembersTableFilterComposer,
          $$WorkspaceMembersTableOrderingComposer,
          $$WorkspaceMembersTableAnnotationComposer,
          $$WorkspaceMembersTableCreateCompanionBuilder,
          $$WorkspaceMembersTableUpdateCompanionBuilder,
          (
            WorkspaceMemberRow,
            BaseReferences<
              _$AppDatabase,
              $WorkspaceMembersTable,
              WorkspaceMemberRow
            >,
          ),
          WorkspaceMemberRow,
          PrefetchHooks Function()
        > {
  $$WorkspaceMembersTableTableManager(
    _$AppDatabase db,
    $WorkspaceMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspaceMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspaceMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspaceMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> workspaceId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspaceMembersCompanion(
                workspaceId: workspaceId,
                userId: userId,
                email: email,
                role: role,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workspaceId,
                required String userId,
                required String email,
                required String role,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkspaceMembersCompanion.insert(
                workspaceId: workspaceId,
                userId: userId,
                email: email,
                role: role,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspaceMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspaceMembersTable,
      WorkspaceMemberRow,
      $$WorkspaceMembersTableFilterComposer,
      $$WorkspaceMembersTableOrderingComposer,
      $$WorkspaceMembersTableAnnotationComposer,
      $$WorkspaceMembersTableCreateCompanionBuilder,
      $$WorkspaceMembersTableUpdateCompanionBuilder,
      (
        WorkspaceMemberRow,
        BaseReferences<
          _$AppDatabase,
          $WorkspaceMembersTable,
          WorkspaceMemberRow
        >,
      ),
      WorkspaceMemberRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SnippetsTableTableManager get snippets =>
      $$SnippetsTableTableManager(_db, _db.snippets);
  $$SnippetFilesTableTableManager get snippetFiles =>
      $$SnippetFilesTableTableManager(_db, _db.snippetFiles);
  $$SnippetFileVersionsTableTableManager get snippetFileVersions =>
      $$SnippetFileVersionsTableTableManager(_db, _db.snippetFileVersions);
  $$LanguagesTableTableManager get languages =>
      $$LanguagesTableTableManager(_db, _db.languages);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$SnippetTagsTableTableManager get snippetTags =>
      $$SnippetTagsTableTableManager(_db, _db.snippetTags);
  $$AiPromptMetaTableTableManager get aiPromptMeta =>
      $$AiPromptMetaTableTableManager(_db, _db.aiPromptMeta);
  $$PurposesTableTableManager get purposes =>
      $$PurposesTableTableManager(_db, _db.purposes);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$WorkspaceMembersTableTableManager get workspaceMembers =>
      $$WorkspaceMembersTableTableManager(_db, _db.workspaceMembers);
}
