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

  /// Corner radius vocabulary used across components.
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;

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
        .apply(fontFamily: uiFamily);

    final textTheme = baseText.copyWith(
      displaySmall: baseText.displaySmall?.copyWith(
          fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: baseText.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium:
          baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: baseText.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

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
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 20),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: const EdgeInsets.symmetric(vertical: 5),
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
        fillColor: scheme.surfaceContainerHighest,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: rSm,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: rSm,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: rSm,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: rSm),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: rSm),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: rSm),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
