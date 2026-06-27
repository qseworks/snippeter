import 'package:flutter/material.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/prompt_variables.dart';
import '../../domain/snippet.dart';
import '../../domain/value_objects.dart';
import 'snippet_copy.dart';

/// Interactive "Fill variables" panel for an `ai_prompt` snippet: one labeled
/// field per `{{variable}}`, a live-resolved preview of the prompt, and a
/// "Copy filled prompt" action. Pure UI over [reconcilePromptVariables] +
/// [resolvePromptVariables] — no schema, no backend.
///
/// Key this widget by the variable-name signature so it rebuilds its
/// controllers only when the set of variables actually changes (not on every
/// unrelated snippet-stream tick); the preview itself stays live because
/// [build] re-resolves against the current [snippet] body each frame.
class PromptFillPanel extends StatefulWidget {
  const PromptFillPanel({super.key, required this.snippet});

  final Snippet snippet;

  @override
  State<PromptFillPanel> createState() => _PromptFillPanelState();
}

class _PromptFillPanelState extends State<PromptFillPanel> {
  late final List<PromptVariable> _variables;
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _variables = reconcilePromptVariables(
      widget.snippet.body,
      widget.snippet.promptMeta?.variables ?? const [],
    );
    _controllers = {
      for (final v in _variables)
        v.name: TextEditingController(text: v.defaultValue ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _values =>
      {for (final e in _controllers.entries) e.key: e.value.text};

  int get _emptyRequired => _variables
      .where((v) => v.required && (_controllers[v.name]?.text.isEmpty ?? true))
      .length;

  Future<void> _copyFilled() async {
    final l10n = AppLocalizations.of(context);
    final resolved = resolvePromptVariables(widget.snippet.body, _values);
    final message = _emptyRequired > 0
        ? l10n.promptFillEmptyWarning
        : l10n.exportMenuCopiedSnack;
    await copyWithFeedback(context, resolved, message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final resolved = resolvePromptVariables(widget.snippet.body, _values);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(Icons.tune, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(l10n.promptFillTitle, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.promptFillSubtitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        for (final v in _variables) ...[
          _VariableField(
            variable: v,
            controller: _controllers[v.name]!,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        Text(
          l10n.promptFillPreviewLabel,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        _PreviewBox(text: resolved),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: _copyFilled,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(l10n.promptFillCopyButton),
          ),
        ),
      ],
    );
  }
}

/// One labeled, multi-line-capable field for a single `{{variable}}`.
class _VariableField extends StatelessWidget {
  const _VariableField({
    required this.variable,
    required this.controller,
    required this.onChanged,
  });

  final PromptVariable variable;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = variable.label ?? variable.name;
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      minLines: 1,
      maxLines: 6,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: variable.required ? '$label *' : label,
        helperText: variable.description,
        helperMaxLines: 2,
        hintText: l10n.promptFillFieldHint(variable.name),
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// The live-resolved prompt, in a selectable mono block so it can be skimmed or
/// partially copied without the "Copy filled prompt" button.
class _PreviewBox extends StatelessWidget {
  const _PreviewBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SelectableText(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: AppTheme.monoFamily,
          height: 1.45,
        ),
      ),
    );
  }
}
