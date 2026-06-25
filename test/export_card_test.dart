import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snippet_manager/core/highlight/code_themes.dart';
import 'package:snippet_manager/features/export/domain/snippet_export_data.dart';
import 'package:snippet_manager/features/export/presentation/code_image_card.dart';
import 'package:snippet_manager/features/export/presentation/export_background.dart';

void main() {
  testWidgets(
    'export card contains NO raster Image (web toImage safety rule)',
    (tester) async {
      const data = SnippetExportData(
        title: 'Demo',
        body: 'def greet(name):\n    return f"Hi {name}"',
        fileExtension: '.py',
        grammarId: 'python',
        languageName: 'Python',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CodeImageCard(
                data: data,
                themeName: CodeThemes.exportThemeNames.first,
                background: ExportBackground.presets.first,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // HARD RULE: no raster Image widgets — CanvasKit's toImage silently drops
      // embedded raster images from web captures (flutter#106314).
      expect(find.byType(Image), findsNothing);
      // The card and its window frame render (vector decorations).
      expect(find.byType(DecoratedBox), findsWidgets);
      // The watermark text is present.
      expect(find.textContaining('Snippeter'), findsOneWidget);
    },
  );

  testWidgets('export card honors the no-watermark option', (tester) async {
    const data = SnippetExportData(
      title: 'Demo',
      body: 'x = 1',
      fileExtension: '.py',
      grammarId: 'python',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CodeImageCard(
              data: data,
              themeName: 'github',
              background: ExportBackground.presets.last, // 'None'
              showWatermark: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsNothing);
    expect(find.textContaining('Snippeter'), findsNothing);
  });
}
