import 'dart:math';

import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

/// Find / replace panel for the code [CodeEditor]. Adapted from the re_editor
/// example (Apache-2.0); colours are themed by the caller via the constructor
/// so it blends with the app. Wire it through `CodeEditor.findBuilder`.
const EdgeInsetsGeometry _kMargin = EdgeInsetsDirectional.only(end: 10, top: 6);
const double _kPanelWidth = 360;
const double _kFindPanelHeight = 40;
const double _kReplacePanelHeight = _kFindPanelHeight * 2;
const double _kIconSize = 16;
const double _kIconWidth = 30;
const double _kIconHeight = 30;

class CodeFindPanelView extends StatelessWidget implements PreferredSizeWidget {
  const CodeFindPanelView({
    super.key,
    required this.controller,
    required this.readOnly,
    this.margin = _kMargin,
    this.iconSelectedColor,
    this.iconColor,
    this.iconSize = _kIconSize,
    this.inputFontSize = 13,
    this.resultFontSize = 12,
    this.inputTextColor,
    this.resultFontColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    this.decoration = const InputDecoration(),
  });

  final CodeFindController controller;
  final EdgeInsetsGeometry margin;
  final bool readOnly;
  final Color? iconColor;
  final Color? iconSelectedColor;
  final double iconSize;
  final double inputFontSize;
  final double resultFontSize;
  final Color? inputTextColor;
  final Color? resultFontColor;
  final EdgeInsetsGeometry padding;
  final InputDecoration decoration;

  @override
  Size get preferredSize => Size(
        double.infinity,
        controller.value == null
            ? 0
            : ((controller.value!.replaceMode
                    ? _kReplacePanelHeight
                    : _kFindPanelHeight) +
                margin.vertical),
      );

  @override
  Widget build(BuildContext context) {
    if (controller.value == null) {
      return const SizedBox(width: 0, height: 0);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // Shrink the panel to fit a narrow editor instead of overflowing its
        // right edge; the subtracted slack covers the container margin plus the
        // Material's horizontal padding.
        final available = constraints.maxWidth - margin.horizontal - 12;
        final panelWidth = min(_kPanelWidth, max(0.0, available));
        return Container(
          margin: margin,
          alignment: AlignmentDirectional.topEnd,
          height: preferredSize.height,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: SizedBox(
                  width: panelWidth,
                  child: Column(
                    children: [
                      _buildFindInputView(context),
                      if (controller.value!.replaceMode)
                        _buildReplaceInputView(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFindInputView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final CodeFindValue value = controller.value!;
    final String result;
    if (value.result == null) {
      result = l10n.findNoMatches;
    } else {
      result = '${value.result!.index + 1}/${value.result!.matches.length}';
    }
    return Row(
      children: [
        IconButton(
          onPressed: controller.toggleMode,
          icon: Icon(value.replaceMode
              ? Icons.expand_more
              : (Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right)),
          iconSize: iconSize,
          tooltip: l10n.codeFindToggleReplaceTooltip,
          constraints:
              const BoxConstraints(maxWidth: _kIconWidth, maxHeight: _kIconHeight),
        ),
        SizedBox(
          width: _kPanelWidth / 2.4,
          height: _kFindPanelHeight - 8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildTextField(
                context: context,
                controller: controller.findInputController,
                focusNode: controller.findInputFocusNode,
                hint: l10n.codeFindFindHint,
                iconsWidth: _kIconWidth * 1.5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildCheckText(
                    context: context,
                    text: 'Aa',
                    checked: value.option.caseSensitive,
                    onPressed: controller.toggleCaseSensitive,
                  ),
                  _buildCheckText(
                    context: context,
                    text: '.*',
                    checked: value.option.regex,
                    onPressed: controller.toggleRegex,
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(result,
            style: TextStyle(color: resultFontColor, fontSize: resultFontSize)),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildIconButton(
                onPressed: value.result == null ? null : controller.previousMatch,
                icon: Icons.arrow_upward,
                tooltip: l10n.codeFindPreviousTooltip,
              ),
              _buildIconButton(
                onPressed: value.result == null ? null : controller.nextMatch,
                icon: Icons.arrow_downward,
                tooltip: l10n.codeFindNextTooltip,
              ),
              _buildIconButton(
                onPressed: controller.close,
                icon: Icons.close,
                tooltip: l10n.commonClose,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplaceInputView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final CodeFindValue value = controller.value!;
    return Row(
      children: [
        const SizedBox(width: _kIconWidth),
        SizedBox(
          width: _kPanelWidth / 2.4,
          height: _kFindPanelHeight - 8,
          child: _buildTextField(
            context: context,
            controller: controller.replaceInputController,
            focusNode: controller.replaceInputFocusNode,
            hint: l10n.codeFindReplaceHint,
          ),
        ),
        _buildIconButton(
          onPressed: value.result == null ? null : controller.replaceMatch,
          icon: Icons.done,
          tooltip: l10n.codeFindReplaceHint,
        ),
        _buildIconButton(
          onPressed: value.result == null ? null : controller.replaceAllMatches,
          icon: Icons.done_all,
          tooltip: l10n.codeFindReplaceAllTooltip,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    double iconsWidth = 0,
  }) {
    return Padding(
      padding: padding,
      child: TextField(
        maxLines: 1,
        focusNode: focusNode,
        style: TextStyle(color: inputTextColor, fontSize: inputFontSize),
        decoration: decoration.copyWith(
          hintText: hint,
          isDense: true,
          contentPadding: (decoration.contentPadding ?? EdgeInsets.zero)
              .add(EdgeInsetsDirectional.only(end: iconsWidth)),
        ),
        controller: controller,
      ),
    );
  }

  Widget _buildCheckText({
    required BuildContext context,
    required String text,
    required bool checked,
    required VoidCallback onPressed,
  }) {
    final Color selectedColor =
        iconSelectedColor ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: _kIconWidth * 0.75,
          child: Text(
            text,
            style: TextStyle(
              color: checked ? selectedColor : iconColor,
              fontSize: inputFontSize,
              fontWeight: checked ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize),
      color: iconColor,
      constraints:
          const BoxConstraints(maxWidth: _kIconWidth, maxHeight: _kIconHeight),
      tooltip: tooltip,
      splashRadius: max(_kIconWidth, _kIconHeight) / 2,
    );
  }
}
