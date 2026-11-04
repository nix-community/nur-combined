import 'package:flutter/material.dart';

import '../../../Core/Offline/PendingWrites.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Widgets/Components/AlertDialogBuilder.dart';

class PendingSyncCard extends StatelessWidget {
  final PendingWrites pending;

  const PendingSyncCard({super.key, required this.pending});

  @override
  Widget build(BuildContext context) => Watch(() {
    final count = pending.entries.length;
    if (count == 0) return const SizedBox.shrink();
    final scheme = context.colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: Dimens.gapSm),
      padding: EdgeInsets.all(Dimens.gap),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: Dimens.borderSm,
      ),
      child: Row(
        children: [
          Icon(Icons.sync_problem_rounded, color: scheme.onTertiaryContainer),
          SizedBox(width: Dimens.gap),
          Expanded(
            child: Text(
              getString.offlinePending(count),
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
          TextButton(
            onPressed: pending.busy.value ? null : pending.replay,
            child: Text(getString.offlineSyncNow),
          ),
          TextButton(
            onPressed: () => AlertDialogBuilder(context)
                .setTitle(getString.offlineDiscard)
                .setMessage(getString.offlineDiscardConfirm(count))
                .setPositiveButton(getString.offlineDiscard, pending.discardAll)
                .setNegativeButton(getString.cancel, null)
                .show<void>(),
            child: Text(getString.offlineDiscard),
          ),
        ],
      ),
    );
  });
}
