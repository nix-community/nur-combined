import 'package:flutter/material.dart';

import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../../../Utils/Functions/SnackBar.dart';
import '../../../Widgets/Components/AlertDialogBuilder.dart';
import '../../../Widgets/Components/AppControls.dart';
import '../../../Widgets/Components/AppSheet.dart';
import '../../../Widgets/Components/CustomBottomDialog.dart';
import '../../../Core/Services/Api/IdMapper.dart';
import '../Engine/AniSkip.dart';
import '../PlayerState.dart';
import 'PlayerSeekBar.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Widgets/Components/AppSpinner.dart';

Future<void> showSkipSubmitSheet(BuildContext context, PlayerState state) =>
    state.whilePaused<void>(
      () => showCustomBottomDialog<void>(
        context,
        AppSheet(
          title: getString.playerSkipSubmit,
          child: _SkipSubmitPanel(state: state),
        ),
      ),
    );

class _SkipSubmitPanel extends StatefulWidget {
  final PlayerState state;

  const _SkipSubmitPanel({required this.state});

  @override
  State<_SkipSubmitPanel> createState() => _SkipSubmitPanelState();
}

class _SkipSubmitPanelState extends State<_SkipSubmitPanel> {
  late final draft = widget.state.skipDraft();
  late final type = draft.type;
  late final start = draft.start;
  late final end = draft.end;
  final sending = false.live;

  double get _length =>
      widget.state.engine.duration.value.inMilliseconds / 1000;

  double get _now => widget.state.engine.position.value.inMilliseconds / 1000;

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _time(
    BuildContext context,
    String label,
    double value,
    ValueChanged<double> set,
  ) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: context.textTheme.labelLarge),
        ),
        IconButton(
          onPressed: () => set((value - 1).clamp(0, _length)),
          icon: const Icon(Icons.remove_rounded),
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _edit(label, value, set),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                value <= 0 && label == getString.playerSkipEnd
                    ? '--:--'
                    : formatClock(value.floor()),
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => set((value + 1).clamp(0, _length)),
          icon: const Icon(Icons.add_rounded),
        ),
        IconButton(
          tooltip: getString.playerSkipUseNow,
          onPressed: () => set(_now),
          icon: const Icon(Icons.my_location_rounded),
        ),
      ],
    );
  }

  void _edit(String label, double value, ValueChanged<double> set) {
    final controller = TextEditingController(
      text: value <= 0 ? '' : formatClock(value.floor()),
    );
    void apply() {
      final parsed = parseClock(controller.text);
      if (parsed != null) set(parsed.clamp(0, _length));
    }

    AlertDialogBuilder(context)
        .setTitle(label)
        .setCustomView(
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(hintText: 'mm:ss'),
            onSubmitted: (_) {
              apply();
              Navigator.of(context, rootNavigator: true).maybePop();
            },
          ),
        )
        .setPositiveButton(getString.save, apply)
        .setNegativeButton(getString.cancel, null)
        .show<void>();
  }

  Future<void> _send() async {
    final state = widget.state;
    final media = state.request.media;
    final service = state.request.service;
    if (media == null || service == null || sending.value) return;
    sending.value = true;
    try {
      var malId = media.malId;
      malId ??= (await IdMapper.resolve(service, media)).mal;
      if (malId == null) {
        snackString(getString.playerSkipNoMal);
        return;
      }
      final error = await AniSkip.submit(
        malId: malId,
        episode: state.item.number.floor(),
        type: type.value,
        start: start.value / 1000,
        end: end.value / 1000,
        lengthSeconds: _length,
      );
      if (error != null) {
        snackString(getString.playerSkipFailed(error));
        return;
      }
      state.stamps.add(
        SkipStamp(
          skipName(type.value),
          skipKindOf(type.value),
          start.value / 1000,
          end.value / 1000,
        ),
      );
      state.clearSkipDraft();
      snackString(getString.playerSkipSent);
      if (mounted) popPage(context);
    } finally {
      sending.value = false;
    }
  }

  Widget _build(BuildContext context) {
    final valid = end.value > start.value && _length > 0;
    return Padding(
      padding: Dimens.sheetInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            getString.playerSkipSubmitDesc,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          AppChoiceChips<String>(
            value: type.value,
            onChanged: (t) => type.value = t,
            options: [
              for (final t in aniSkipTypes) AppSegment(t, label: skipName(t)),
            ],
          ),
          const SizedBox(height: 8),
          _time(
            context,
            getString.playerSkipStart,
            start.value / 1000,
            (v) => start.value = v * 1000,
          ),
          _time(
            context,
            getString.playerSkipEnd,
            end.value / 1000,
            (v) => end.value = v * 1000,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: valid && !sending.value ? _send : null,
            icon: sending.value
                ? const AppSpinner()
                : const Icon(Icons.cloud_upload_rounded),
            label: Text(getString.playerSkipSend),
          ),
        ],
      ),
    );
  }
}
