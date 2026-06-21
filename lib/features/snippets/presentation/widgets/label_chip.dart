import 'package:flutter/material.dart';

import '../../domain/value_objects.dart';

/// A fixed, Snippet-like palette used to give labels stable, distinct colors when
/// the user hasn't picked one explicitly.
const List<Color> _labelPalette = [
  Color(0xFF16B378), // green
  Color(0xFFE5484D), // red
  Color(0xFF8E4EC6), // purple
  Color(0xFFFFB224), // amber
  Color(0xFF12A594), // teal
  Color(0xFF3E63DD), // blue
  Color(0xFFE93D82), // pink
  Color(0xFF5753C6), // indigo
];

/// Parses a hex color string like `#16B378`, `16B378`, or `#FF16B378`.
/// Returns null when the string isn't a usable hex color.
Color? _parseHexColor(String? value) {
  if (value == null) return null;
  var hex = value.trim();
  if (hex.isEmpty) return null;
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return null;
  return Color(parsed);
}

/// Stable color derived from an arbitrary name via the fixed palette.
Color labelColorByName(String name) {
  final key = name.trim().toLowerCase();
  if (key.isEmpty) return _labelPalette.first;
  var hash = 0;
  for (final unit in key.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return _labelPalette[hash % _labelPalette.length];
}

/// The effective display color for a label: its explicit hex color if parseable,
/// otherwise a stable color derived from its normalized name.
Color labelColor(Label label) {
  return _parseHexColor(label.color) ?? labelColorByName(label.normalizedName);
}

/// A small filled circle used as a label's color swatch.
class LabelDot extends StatelessWidget {
  const LabelDot({super.key, required this.color, this.size = 10});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A compact, rounded pill tinted with the label color (dot + name). When
/// [onColored] is true the chip is rendered for placement on an already-colored
/// surface (a more opaque fill + stronger text), otherwise it uses a subtle
/// tinted background suited to the default surface.
class LabelChip extends StatelessWidget {
  const LabelChip({
    super.key,
    required this.label,
    this.onTap,
    this.onColored = false,
  });

  final Label label;
  final VoidCallback? onTap;
  final bool onColored;

  @override
  Widget build(BuildContext context) {
    final color = labelColor(label);
    final theme = Theme.of(context);

    final bg = onColored
        ? color.withValues(alpha: 0.24)
        : color.withValues(alpha: 0.13);
    final fg = onColored ? Colors.white : color;
    final borderColor = onColored
        ? Colors.white.withValues(alpha: 0.16)
        : color.withValues(alpha: 0.30);

    final chip = Container(
      padding: const EdgeInsets.fromLTRB(7, 3, 9, 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LabelDot(color: color, size: 6),
          const SizedBox(width: 6),
          Text(
            label.name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: chip,
    );
  }
}
