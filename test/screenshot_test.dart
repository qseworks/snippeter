// Renders the real app surfaces to PNGs (run with --update-goldens) so the
// redesign can be eyeballed without a browser. NOT a pass/fail golden suite.
//
//   flutter test test/screenshot_test.dart --update-goldens
//
// Output lands in test/goldens/. Uses a synchronous in-memory fake repository
// (no Drift) so the fake-async testWidgets zone never blocks, and loads the
// real Inter / JetBrains Mono fonts in setUpAll (real event loop) so text is
// rendered, not boxed.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snippet_manager/app.dart';
import 'package:snippet_manager/core/theme/app_theme.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';
import 'package:snippet_manager/features/settings/application/settings_providers.dart';
import 'package:snippet_manager/features/snippets/application/snippet_providers.dart';
import 'package:snippet_manager/features/snippets/domain/snippet.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_query.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_repository.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_type.dart';
import 'package:snippet_manager/features/snippets/domain/value_objects.dart';
import 'package:snippet_manager/features/snippets/presentation/snippet_editor_screen.dart';

// ---------------------------------------------------------------------------
// Seed data (pure value objects — no async, no Drift).
// ---------------------------------------------------------------------------

const _languages = <Language>[
  Language(id: 'python', name: 'Python', fileExtension: '.py', grammarId: 'python'),
  Language(id: 'typescript', name: 'TypeScript', fileExtension: '.ts', grammarId: 'typescript'),
  Language(id: 'bash', name: 'Shell', fileExtension: '.sh', grammarId: 'bash'),
  Language(id: 'sql', name: 'SQL', fileExtension: '.sql', grammarId: 'sql'),
  Language(id: 'dart', name: 'Dart', fileExtension: '.dart', grammarId: 'dart'),
  Language(id: 'json', name: 'JSON', fileExtension: '.json', grammarId: 'json'),
];

Label _lab(String id, String name) =>
    Label(id: id, name: name, normalizedName: Label.normalize(name));

final List<Label> _labels = [
  _lab('l1', 'algorithms'),
  _lab('l2', 'interview'),
  _lab('l3', 'react'),
  _lab('l4', 'hooks'),
  _lab('l5', 'devops'),
  _lab('l6', 'writing'),
  _lab('l7', 'ai'),
  _lab('l8', 'analytics'),
];

List<Snippet> _snippets() {
  final now = DateTime.now().millisecondsSinceEpoch;
  int ago(int minutes) => now - minutes * 60000;
  SnippetFile f(String id, String name, String? lang, String body) =>
      SnippetFile(id: id, filename: name, languageId: lang, content: body);

  return [
    Snippet(
      id: 's1',
      title: 'Binary search (iterative)',
      body: 'def bisect(a, x): ...',
      type: SnippetType.code,
      languageId: 'python',
      createdAt: ago(600),
      updatedAt: ago(7),
      isFavorite: true,
      labels: [_lab('l1', 'algorithms'), _lab('l2', 'interview')],
      files: [f('f1', 'bisect.py', 'python', 'def bisect(a, x):\n    ...')],
    ),
    Snippet(
      id: 's2',
      title: 'useDebounce hook',
      body: 'export function useDebounce ...',
      type: SnippetType.code,
      languageId: 'typescript',
      createdAt: ago(1500),
      updatedAt: ago(95),
      labels: [_lab('l3', 'react'), _lab('l4', 'hooks')],
      files: [f('f2', 'useDebounce.ts', 'typescript', 'export function useDebounce() {}')],
    ),
    Snippet(
      id: 's3',
      title: 'Dockerfile — Flutter web',
      body: 'FROM nginx:alpine ...',
      type: SnippetType.code,
      languageId: 'bash',
      createdAt: ago(2880),
      updatedAt: ago(1440),
      labels: [_lab('l5', 'devops')],
      files: [f('f3', 'Dockerfile', 'bash', 'FROM nginx:alpine')],
    ),
    Snippet(
      id: 's4',
      title: 'Summarize meeting notes',
      body: 'Summarize the transcript ...',
      type: SnippetType.aiPrompt,
      createdAt: ago(4320),
      updatedAt: ago(2880),
      labels: [_lab('l6', 'writing'), _lab('l7', 'ai')],
      files: [f('f4', 'prompt.txt', null, 'Summarize {{transcript}}')],
    ),
    Snippet(
      id: 's5',
      title: 'Top customers by revenue',
      body: 'SELECT ...',
      type: SnippetType.code,
      languageId: 'sql',
      createdAt: ago(10080),
      updatedAt: ago(4320),
      labels: [_lab('l8', 'analytics')],
      files: [f('f5', 'top_customers.sql', 'sql', 'SELECT name, SUM(total) ...')],
    ),
    Snippet(
      id: 's6',
      title: 'Release checklist',
      body: 'Bump version, tag, run CI ...',
      type: SnippetType.text,
      createdAt: ago(20160),
      updatedAt: ago(10080),
      files: [f('f6', 'release.md', null, 'Bump version, tag, run CI.')],
    ),
  ];
}

/// Synchronous fake — every read returns a resolved Stream/Future, so there are
/// no Drift timers and the fake-async test zone settles immediately.
class _SeedRepo implements SnippetRepository {
  @override
  Stream<List<Snippet>> watchSnippets(SnippetQuery query) {
    var list = _snippets();
    if (query.favoritesOnly) list = list.where((s) => s.isFavorite).toList();
    if (query.languageId != null) {
      list = list.where((s) => s.languageId == query.languageId).toList();
    }
    return Stream.value(list);
  }

  @override
  Stream<Snippet?> watchSnippet(String id) =>
      Stream.value(_snippets().where((s) => s.id == id).firstOrNull);
  @override
  Future<Snippet?> getSnippet(String id) async =>
      _snippets().where((s) => s.id == id).firstOrNull;
  @override
  Future<List<Language>> getLanguages() async => _languages;
  @override
  Future<List<Purpose>> getPurposes() async => const [
        Purpose(id: 'snippet', label: 'Snippet'),
        Purpose(id: 'reference', label: 'Reference'),
        Purpose(id: 'template', label: 'Template'),
      ];
  @override
  Stream<List<Label>> watchLabels() => Stream.value(_labels);
  @override
  Stream<LibraryStats> watchLibraryStats({String? workspaceId}) {
    final all = _snippets();
    final byLanguageId = <String, int>{};
    final byLabelId = <String, int>{};
    for (final s in all) {
      if (s.languageId != null) {
        byLanguageId[s.languageId!] = (byLanguageId[s.languageId!] ?? 0) + 1;
      }
      for (final l in s.labels) {
        byLabelId[l.id] = (byLabelId[l.id] ?? 0) + 1;
      }
    }
    return Stream.value(LibraryStats(
      total: all.length,
      starred: all.where((s) => s.isFavorite).length,
      unlabeled: all.where((s) => s.labels.isEmpty).length,
      byLanguageId: byLanguageId,
      byLabelId: byLabelId,
    ));
  }
  @override
  Stream<List<Collection>> watchCollections() => Stream.value(const [
        Collection(id: 'c1', name: 'Work'),
        Collection(id: 'c2', name: 'Personal'),
      ]);
  @override
  Stream<List<Attachment>> watchAttachments(String snippetId) =>
      Stream.value(const []);

  // --- Mutations / unused in screenshots: no-ops. ---------------------------
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
}

// ---------------------------------------------------------------------------

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    loader.addFont(File(path).readAsBytes().then((b) => ByteData.sublistView(b)));
  }
  await loader.load();
}

void _configureView(WidgetTester tester, Size physical) {
  tester.view.physicalSize = physical;
  tester.view.devicePixelRatio = 2.0;
  tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearPlatformBrightnessTestValue();
  });
}

Future<ProviderScope> _appScope(Widget child) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      snippetRepositoryProvider.overrideWithValue(_SeedRepo()),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: child,
  );
}

void main() {
  setUpAll(() async {
    // The full app graph lazily constructs the real Drift DB (sync layer),
    // which calls path_provider — absent under flutter test. Stub the channel
    // so it resolves quietly instead of throwing after the frame is captured.
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.path,
    );

    // Real event loop here (not fake-async), so file I/O completes.
    await _loadFont('Inter', ['assets/fonts/Inter-Variable.ttf']);
    await _loadFont('JetBrains Mono', [
      'assets/fonts/JetBrainsMono-Regular.ttf',
      'assets/fonts/JetBrainsMono-Medium.ttf',
      'assets/fonts/JetBrainsMono-Bold.ttf',
    ]);
    // flutter test runs with --disable-asset-fonts, so the bundled icon font is
    // absent and Icons render as tofu. Load it back from the build assets (or
    // the Flutter cache) so the screenshots match the real app.
    final iconCandidates = [
      'build/flutter_assets/fonts/MaterialIcons-Regular.otf',
      '${Platform.environment['HOME']}/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ];
    final iconFont = iconCandidates.firstWhere(
      (p) => File(p).existsSync(),
      orElse: () => '',
    );
    if (iconFont.isNotEmpty) await _loadFont('MaterialIcons', [iconFont]);
  });

  // Screenshot utilities, not assertions: golden comparison is platform/font
  // sensitive, so only run them when explicitly regenerating with
  // --update-goldens. They are skipped in a normal `flutter test`.
  final skip = !autoUpdateGoldenFiles;

  testWidgets('capture: library (dark)', skip: skip, (tester) async {
    _configureView(tester, const Size(2560, 1600)); // logical 1280 x 800
    await tester.pumpWidget(await _appScope(const SnippetManagerApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle(const Duration(milliseconds: 80));
    await expectLater(
      find.byType(SnippetManagerApp),
      matchesGoldenFile('goldens/library_dark.png'),
    );
  });

  testWidgets('capture: add-snippet modal (dark)', skip: skip, (tester) async {
    _configureView(tester, const Size(2640, 1800)); // logical 1320 x 900
    await tester.pumpWidget(await _appScope(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          backgroundColor: const Color(0xFF050509),
          body: Center(
            child: SizedBox(
              width: 1180,
              height: 820,
              child: Builder(
                builder: (context) {
                  final scheme = Theme.of(context).colorScheme;
                  return Material(
                    color: scheme.surface,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      side: BorderSide(color: scheme.outlineVariant),
                    ),
                    child: const SnippetEditorScreen(isModal: true),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ));
    // The code editor may schedule a cursor-blink timer, so pump fixed frames
    // rather than pumpAndSettle.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/add_snippet_modal_dark.png'),
    );
  });
}
