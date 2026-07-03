import 'package:flutter/material.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

/// A chips-style label editor: existing labels render as deletable chips and the
/// trailing text field adds a new label on submit (Enter) or comma.
class LabelField extends StatefulWidget {
  const LabelField({
    super.key,
    required this.labels,
    required this.onChanged,
    this.suggestions = const [],
  });

  final List<String> labels;
  final ValueChanged<List<String>> onChanged;
  final List<String> suggestions;

  @override
  State<LabelField> createState() => _LabelFieldState();
}

class _LabelFieldState extends State<LabelField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final name = raw.trim().replaceAll(',', '');
    if (name.isEmpty) return;
    final lower = name.toLowerCase();
    if (widget.labels.any((t) => t.toLowerCase() == lower)) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.labels, name]);
    _controller.clear();
  }

  void _remove(String label) {
    widget.onChanged(widget.labels.where((t) => t != label).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final available = widget.suggestions
        .where((s) => !widget.labels
            .map((t) => t.toLowerCase())
            .contains(s.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          // No border override: the themed input decoration (8px radius,
          // outlineVariant) applies, matching every other field.
          decoration: InputDecoration(labelText: l10n.labelFieldLabel),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final label in widget.labels)
                InputChip(
                  label: Text(label),
                  onDeleted: () => _remove(label),
                ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: l10n.labelFieldHint,
                  ),
                  onChanged: (value) {
                    if (value.endsWith(',')) _add(value);
                  },
                  onSubmitted: (value) {
                    _add(value);
                    _focusNode.requestFocus();
                  },
                ),
              ),
            ],
          ),
        ),
        if (available.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in available.take(12))
                ActionChip(
                  label: Text(s),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _add(s),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
