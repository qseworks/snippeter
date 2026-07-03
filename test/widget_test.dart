import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snippet_manager/app.dart';
import 'package:snippet_manager/features/settings/application/settings_providers.dart';
import 'package:snippet_manager/features/snippets/application/snippet_providers.dart';
import 'package:snippet_manager/features/snippets/domain/snippet.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_query.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_repository.dart';
import 'package:snippet_manager/features/snippets/domain/value_objects.dart';

/// Deterministic in-memory fake — no Drift, so the widget tree has no
/// rescheduling stream timers to make pumpAndSettle spin forever.
class _FakeRepo implements SnippetRepository {
  @override
  Stream<List<Snippet>> watchSnippets(SnippetQuery query) =>
      Stream.value(const []);
  @override
  Stream<Snippet?> watchSnippet(String id) => Stream.value(null);
  @override
  Future<Snippet?> getSnippet(String id) async => null;
  @override
  Future<String> create(SnippetDraft draft) async => 'id';
  @override
  Future<void> update(String id, SnippetDraft draft) async {}
  @override
  Future<void> setFavorite(String id, {required bool value}) async {}
  @override
  Future<void> softDelete(String id) async {}
  @override
  Future<void> undoDelete(String id) async {}
  @override
  Future<List<SnippetVersion>> getVersions(String snippetId) async => const [];
  @override
  Future<void> restoreVersion(String snippetId, int savedAt) async {}
  @override
  Stream<List<Label>> watchLabels() => Stream.value(const []);
  @override
  Future<String> createLabel(String name, {String? color, String? parentId}) async => 'l';
  @override
  Future<void> setLabelColor(String id, String color) async {}
  @override
  Future<void> setLabelParent(String id, String? parentId) async {}
  @override
  Future<void> renameLabel(String id, String name) async {}
  @override
  Future<void> deleteLabel(String id) async {}
  @override
  Stream<List<Collection>> watchCollections() => Stream.value(const []);
  @override
  Future<String> createCollection(String name, {String? parentId}) async => 'c';
  @override
  Future<void> renameCollection(String id, String name) async {}
  @override
  Future<void> deleteCollection(String id) async {}
  @override
  Future<String> addAttachment(
    String snippetId, {
    required String filename,
    required String mimeType,
    required Uint8List bytes,
  }) async => 'a';
  @override
  Future<void> deleteAttachment(String id) async {}
  @override
  Stream<List<Attachment>> watchAttachments(String snippetId) =>
      Stream.value(const []);
  @override
  Future<List<Language>> getLanguages() async => const [];
  @override
  Future<List<Purpose>> getPurposes() async => const [];
}

void main() {
  testWidgets('App boots into the library shell with an empty state',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          snippetRepositoryProvider.overrideWithValue(_FakeRepo()),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const SnippetManagerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All Snippets'), findsWidgets);
    expect(find.text('Starred'), findsWidgets);
    expect(find.text('No snippets yet'), findsOneWidget);
  });

  testWidgets('Boots right-to-left and localized when the locale is Arabic',
      (tester) async {
    // Persisted UI language drives localeProvider -> MaterialApp.locale.
    SharedPreferences.setMockInitialValues({'localeCode': 'ar'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          snippetRepositoryProvider.overrideWithValue(_FakeRepo()),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const SnippetManagerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // The whole UI flips to RTL (Flutter resolves direction from the locale).
    final dir = tester.widget<Directionality>(find.byType(Directionality).first);
    expect(dir.textDirection, TextDirection.rtl);

    // And it resolved to Arabic — so the English chrome is gone.
    final ctx = tester.element(find.byType(Scaffold).first);
    expect(Localizations.localeOf(ctx).languageCode, 'ar');
    expect(find.text('All Snippets'), findsNothing);
    expect(find.text('No snippets yet'), findsNothing);
  });
}
