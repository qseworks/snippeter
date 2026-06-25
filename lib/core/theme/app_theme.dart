import 'package:flutter/material.dart';

/// App-wide Material 3 themes. Export-card themes (carbon-style) live separately
/// in the export feature; these are only the chrome of the app itself.
///
/// Design language: a Snippet-style green identity, bundled type (Inter for UI,
/// JetBrains Mono for code), soft 16px geometry, hairline borders instead of
/// shadows, and tonal "container" surfaces for depth.
class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF16B378); // Snippet green

  /// UI typeface (bundled, variable weight). See [pubspec.yaml].
  static const String uiFamily = 'Inter';

  /// Monospace typeface used wherever code is displayed or exported.
  static const String monoFamily = 'JetBrains Mono';

  /// Glyph fallback chain for scripts Inter doesn't cover (Arabic/Urdu, CJK,
  /// Devanagari, Bengali). Flutter walks this list when the primary family is
  /// missing a glyph; unknown family names are skipped, so listing the common
  /// system fonts across Apple/Windows/Android plus the Noto families keeps
  /// non-Latin UI text legible instead of rendering tofu (□). On web, CanvasKit
  /// additionally auto-fetches Noto fallbacks for any glyph still unresolved.
  static const List<String> uiFontFallback = <String>[
    // Apple (macOS/iOS)
    'PingFang SC', 'Hiragino Sans', 'Geeza Pro',
    'Devanagari Sangam MN', 'Bangla Sangam MN', 'Noto Nastaliq Urdu',
    // Windows
    'Microsoft YaHei', 'Segoe UI', 'Nirmala UI',
    // Android / bundled Noto
    'Noto Sans', 'Noto Sans CJK SC', 'Noto Sans Arabic',
    'Noto Sans Devanagari', 'Noto Sans Bengali', 'Arial Unicode MS',
  ];

  /// Corner radius vocabulary used across components.
  static const double radiusXs = 8;
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusPill = 999;

  // --- Snippet-style dark sidebar tokens (used by the shell/sidebar) --------
  static const Color sidebarBg = Color(0xFF21262F);
  static const Color sidebarRailBg = Color(0xFF181C23);
  static const Color sidebarText = Color(0xFFE6E8EC);
  static const Color sidebarMuted = Color(0xFF98A1B0);
  static const Color sidebarSection = Color(0xFF6E7888);
  static const Color sidebarSelected = Color(0xFF2B313C);
  static const Color sidebarHover = Color(0xFF272D37);
  static const Color accent = Color(0xFF16B378);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  /// A subtle brand gradient used for accents (app mark, hero chips).
  static LinearGradient brandGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? const LinearGradient(
            colors: [Color(0xFF1FD18C), Color(0xFF12996A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF16B378), Color(0xFF0E8F5E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    var scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.expressive,
    );

    // Deepen the dark surface to a near-black tone so code blocks and cards
    // read as floating panels rather than grey-on-grey.
    if (isDark) {
      scheme = scheme.copyWith(
        surface: const Color(0xFF111016),
        surfaceContainerLowest: const Color(0xFF0C0B11),
        surfaceContainerLow: const Color(0xFF16151C),
        surfaceContainer: const Color(0xFF1B1A22),
        surfaceContainerHigh: const Color(0xFF222029),
        surfaceContainerHighest: const Color(0xFF2A2833),
        outlineVariant: const Color(0xFF34323D),
      );
    }

    final baseText = (isDark ? Typography.material2021().white
            : Typography.material2021().black)
        .apply(fontFamily: uiFamily, fontFamilyFallback: uiFontFallback);

    // A compact, desktop-first type scale. Sizes run roughly 10–15% below the
    // Material defaults and headings carry tight negative tracking — the dense,
    // high-information feel of Linear/Snippet rather than stock Material.
    final textTheme = baseText.copyWith(
      displaySmall: baseText.displaySmall?.copyWith(
          fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.6),
      headlineMedium: baseText.headlineMedium?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: baseText.headlineSmall?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4),
      titleLarge: baseText.titleLarge?.copyWith(
          fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: baseText.titleMedium?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.1),
      titleSmall: baseText.titleSmall?.copyWith(
          fontSize: 12.5, fontWeight: FontWeight.w600, letterSpacing: -0.1),
      bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 14, height: 1.45),
      bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 13, height: 1.45),
      bodySmall: baseText.bodySmall?.copyWith(fontSize: 11.5, height: 1.4),
      labelLarge: baseText.labelLarge?.copyWith(
          fontSize: 12.5, fontWeight: FontWeight.w600, letterSpacing: 0),
      labelMedium: baseText.labelMedium?.copyWith(
          fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelSmall: baseText.labelSmall?.copyWith(
          fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 0.3),
    );

    final rXs = BorderRadius.circular(radiusXs);
    final rSm = BorderRadius.circular(radiusSm);
    final rMd = BorderRadius.circular(radiusMd);
    final rLg = BorderRadius.circular(radiusLg);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: uiFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 2,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 17),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: rMd,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(borderRadius: rMd),
        selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
        selectedLabelTextStyle: textTheme.labelMedium
            ?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        useIndicator: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
        height: 68,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerHighest,
        isDense: true,
        hintStyle: textTheme.bodyMedium
            ?.copyWith(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: rXs,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: rXs,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: rXs,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        side: BorderSide(color: scheme.outlineVariant),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXs)),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: rXs),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: rXs),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: rXs),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        focusElevation: 1,
        hoverElevation: 2,
        highlightElevation: 1,
        shape: RoundedRectangleBorder(borderRadius: rMd),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: rLg),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: rMd),
        elevation: 3,
        surfaceTintColor: Colors.transparent,
        color: scheme.surfaceContainerHigh,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: rSm),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: rSm),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: textTheme.labelSmall?.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }
}
