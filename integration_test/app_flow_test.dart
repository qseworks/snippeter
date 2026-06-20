import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snippet_manager/app.dart';
import 'package:snippet_manager/core/db/app_database.dart';
import 'package:snippet_manager/core/db/database_provider.dart';
import 'package:snippet_manager/features/settings/application/settings_providers.dart';
import 'package:snippet_manager/features/snippets/data/local_snippet_repository.dart';
import 'package:snippet_manager/features/snippets/domain/snippet.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_type.dart';

/// Drives the REAL app (real Drift + real widgets) through the read-side flow:
/// list -> full-text search -> detail -> copy -> delete. Snippets are seeded
/// directly via the repository so the editor (and re_editor's highlight
/// isolate) is out of scope for this smoke.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('list → search → view → copy → delete', (tester) async {
    // Narrow window => single-pane Library (push navigation, back button).
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // Seed real data through the real repository.
    final repo = LocalSnippetRepository(db);
    await repo.create(const SnippetDraft(
      title: 'Binary Search',
      body: 'def bisect(arr, x):\n    return -1',
      type: SnippetType.code,
      languageId: 'python',
      labelNames: ['algorithm'],
    ));
    await repo.create(const SnippetDraft(
      title: 'Greeting Prompt',
      body: 'Write a greeting for {{name}}.',
      type: SnippetType.aiPrompt,
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const SnippetManagerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Both seeded snippets are listed.
    expect(find.text('Binary Search'), findsOneWidget);
    expect(find.text('Greeting Prompt'), findsOneWidget);

    // 2. Full-text search filters the list.
    await tester.enterText(find.byType(TextField).first, 'binary');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Binary Search'), findsOneWidget);
    expect(find.text('Greeting Prompt'), findsNothing);

    // A non-match shows the empty state.
    await tester.enterText(find.byType(TextField).first, 'zzz-no-match');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('No matching snippets'), findsOneWidget);

    // Clear search.
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // 3. Open the detail view.
    await tester.tap(find.text('Binary Search'));
    await tester.pumpAndSettle();
    expect(find.text('Binary Search'), findsWidgets); // app bar title
    expect(find.text('Python'), findsWidgets); // language meta chip

    // 4. Copy to clipboard (works headless; mock the platform channel).
    final clipboardCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') clipboardCalls.add(call);
        return null;
      },
    );
    await tester.tap(find.byTooltip('Export & share'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy text'));
    await tester.pumpAndSettle();
    expect(find.text('Copied to clipboard'), findsOneWidget);
    expect(clipboardCalls, isNotEmpty);
    expect(clipboardCalls.first.arguments['text'], contains('def bisect'));

    // 5. Delete it; list returns with only the other snippet.
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Binary Search'), findsNothing);
    expect(find.text('Greeting Prompt'), findsOneWidget);
  });
}
