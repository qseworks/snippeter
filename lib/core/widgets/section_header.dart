import 'package:flutter/material.dart';

/// The one uppercase section-header recipe for content panes (editor,
/// settings, team) — previously each screen hand-rolled its own size/color/
/// tracking. The dark sidebar keeps its own header style: it sits on a
/// different surface with its own palette.
///
/// Uppercasing happens here so arb values can be stored naturally; it is a
/// no-op for scripts without case.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;

  /// Optional affordance rendered at the trailing edge (e.g. the editor's
  /// ATTACH / ADD FILE actions).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Flexible(
          child: Text(
            title.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}
