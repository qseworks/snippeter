import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../../../core/highlight/code_themes.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/application/settings_providers.dart';
import '../application/export_providers.dart';
import '../domain/snippet_export_data.dart';
import 'code_image_card.dart';
import 'export_background.dart';
import 'widget_image_capture.dart';

/// Opens the "Export as image" sheet: a live carbon-style preview with theme,
/// background and watermark controls, plus Save / Share.
Future<void> showExportImageSheet(BuildContext context, SnippetExportData data) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _ExportImageSheet(data: data),
  );
}

class _ExportImageSheet extends ConsumerStatefulWidget {
  const _ExportImageSheet({required this.data});

  final SnippetExportData data;

  @override
  ConsumerState<_ExportImageSheet> createState() => _ExportImageSheetState();
}

class _ExportImageSheetState extends ConsumerState<_ExportImageSheet> {
  String _themeName = CodeThemes.exportThemeNames.first;
  ExportBackground _background = ExportBackground.presets.first;
  bool _watermark = true;
  bool _busy = false;

  // Cached render so Share can fire within the user gesture (Web Share API
  // needs transient activation, which a multi-frame capture would consume).
  Uint8List? _bytes;
  bool _dirty = true;
  int _renderSeq = 0;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _themeName = CodeThemes.exportThemeNames.contains(settings.exportTheme)
        ? settings.exportTheme
        : CodeThemes.exportThemeNames.first;
    _watermark = settings.exportWatermark;
    // Pre-warm the cache so the first Save/Share is instant.
    WidgetsBinding.instance.addPostFrameCallback((_) => _render());
  }

  CodeImageCard _card() => CodeImageCard(
        data: widget.data,
        themeName: _themeName,
        background: _background,
        showWatermark: _watermark,
      );

  Rect _origin() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Captures the current card to PNG bytes, ignoring out-of-order results.
  Future<void> _render() async {
    final seq = ++_renderSeq;
    final bytes = await captureWidgetToPng(context, _card());
    if (!mounted || seq != _renderSeq) return;
    setState(() {
      _bytes = bytes;
      _dirty = false;
    });
  }

  void _onOptionChanged(VoidCallback apply) {
    setState(() {
      apply();
      _dirty = true;
    });
    _render(); // pre-warm for the next Save/Share
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      if (_dirty || _bytes == null) await _render();
      if (!mounted) return;
      final bytes = _bytes;
      if (bytes == null) {
        _toast(l10n.exportImageRenderError);
        return;
      }
      await ref
          .read(exportServiceProvider)
          .saveBytes(bytes, widget.data.baseName, '.png');
      if (mounted) {
        _toast(l10n.exportImageSavedNamed(widget.data.baseName));
      }
    } catch (e, st) {
      developer.log('image save failed', name: 'export', error: e, stackTrace: st);
      if (mounted) {
        _toast(l10n.exportImageSaveFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    final origin = _origin();
    // Render only if the cache is stale; otherwise call share directly so the
    // gesture's transient activation survives (Web Share API).
    if (_dirty || _bytes == null) {
      setState(() => _busy = true);
      await _render();
      if (mounted) setState(() => _busy = false);
    }
    final bytes = _bytes;
    if (bytes == null || !mounted) return;
    try {
      await ref.read(exportServiceProvider).shareBytes(
            bytes,
            '${widget.data.baseName}.png',
            'image/png',
            subject: widget.data.title,
            origin: origin,
          );
    } catch (e, st) {
      developer.log('image share failed',
          name: 'export', error: e, stackTrace: st);
      if (mounted) {
        _toast(l10n.exportImageShareFailed);
      }
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.exportImageTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    child: _card(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 80, child: Text(l10n.exportImageThemeLabel)),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _themeName,
                    items: [
                      for (final name in CodeThemes.exportThemeNames)
                        DropdownMenuItem(value: name, child: Text(name)),
                    ],
                    onChanged: (v) => _onOptionChanged(
                        () => _themeName = v ?? _themeName),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.exportImageBackgroundLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final bg in ExportBackground.presets)
                  ChoiceChip(
                    label: Text(bg.name),
                    selected: _background.name == bg.name,
                    onSelected: (_) => _onOptionChanged(() => _background = bg),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.exportImageWatermarkLabel),
              value: _watermark,
              onChanged: (v) => _onOptionChanged(() => _watermark = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _save,
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(l10n.exportImageSavePng),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _share,
                    icon: const Icon(Icons.ios_share),
                    label: Text(l10n.commonShare),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
