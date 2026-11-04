import 'package:flutter/material.dart';

import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';

class DelayRow extends StatelessWidget {
  final String label;
  final Live<double> delay;
  final Future<void> Function(double seconds) onChange;

  const DelayRow({
    super.key,
    required this.label,
    required this.delay,
    required this.onChange,
  });

  String _text(double v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} s';

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Watch(() {
      final value = delay.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 6, 6),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _text(value),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (value != 0)
              TextButton(
                onPressed: () => onChange(0),
                child: Text(getString.playerDelayReset),
              ),
            IconButton(
              onPressed: () => onChange(value - 0.1),
              icon: const Icon(Icons.remove_rounded),
            ),
            IconButton(
              onPressed: () => onChange(value + 0.1),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      );
    });
  }
}
