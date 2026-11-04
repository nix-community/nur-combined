import 'package:flutter/material.dart';

import '../Engine/AniSkip.dart';
import '../Engine/PlayerEngine.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';

String formatClock(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  return [
    if (h > 0) h.toString().padLeft(2, '0'),
    m.toString().padLeft(2, '0'),
    s.toString().padLeft(2, '0'),
  ].join(':');
}

class PlayerSeekBar extends StatelessWidget {
  final Duration position;
  final Duration buffer;
  final Duration duration;
  final List<SkipStamp> stamps;
  final List<PlayerChapter> chapters;
  final bool thumbless;
  final bool enabled;
  final ValueChanged<Duration> onScrub;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onScrubStart;
  final Duration? previewAt;
  final Widget? preview;
  final ValueChanged<Duration?>? onHover;

  const PlayerSeekBar({
    super.key,
    required this.position,
    required this.buffer,
    required this.duration,
    required this.stamps,
    required this.chapters,
    required this.thumbless,
    required this.enabled,
    required this.onScrub,
    required this.onSeek,
    required this.onScrubStart,
    this.previewAt,
    this.preview,
    this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return LayoutBuilder(
      builder: (context, box) {
        Duration at(double dx) {
          final f = (dx / box.maxWidth).clamp(0.0, 1.0);
          return Duration(milliseconds: (duration.inMilliseconds * f).round());
        }

        final bar = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: enabled && duration > Duration.zero
              ? (d) => onSeek(at(d.localPosition.dx))
              : null,
          onHorizontalDragStart: enabled && duration > Duration.zero
              ? (_) => onScrubStart()
              : null,
          onHorizontalDragUpdate: enabled && duration > Duration.zero
              ? (d) => onScrub(at(d.localPosition.dx))
              : null,
          onHorizontalDragEnd: enabled && duration > Duration.zero
              ? (_) => onSeek(position)
              : null,
          onHorizontalDragCancel: enabled && duration > Duration.zero
              ? () => onSeek(position)
              : null,
          child: SizedBox(
            height: 28,
            width: double.infinity,
            child: CustomPaint(
              painter: _SeekPainter(
                position: position,
                buffer: buffer,
                duration: duration,
                stamps: stamps,
                chapters: chapters,
                thumbless: thumbless,
                active: scheme.primary,
                stampColor: scheme.tertiary,
                track: Colors.white.withValues(alpha: 0.28),
                bufferColor: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
        );

        final hoverable = onHover == null || duration <= Duration.zero
            ? bar
            : MouseRegion(
                onHover: (e) => onHover!(at(e.localPosition.dx)),
                onExit: (_) => onHover!(null),
                child: bar,
              );
        final shown = previewAt;
        const previewWidth = 176.0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            hoverable,
            if (shown != null && preview != null && duration > Duration.zero)
              Positioned(
                left:
                    (shown.inMilliseconds /
                                duration.inMilliseconds *
                                box.maxWidth -
                            previewWidth / 2)
                        .clamp(
                          0.0,
                          (box.maxWidth - previewWidth).clamp(
                            0.0,
                            double.infinity,
                          ),
                        ),
                bottom: 34,
                width: previewWidth,
                child: IgnorePointer(child: preview!),
              ),
          ],
        );
      },
    );
  }
}

class _SeekPainter extends CustomPainter {
  final Duration position;
  final Duration buffer;
  final Duration duration;
  final List<SkipStamp> stamps;
  final List<PlayerChapter> chapters;
  final bool thumbless;
  final Color active;
  final Color stampColor;
  final Color track;
  final Color bufferColor;

  _SeekPainter({
    required this.position,
    required this.buffer,
    required this.duration,
    required this.stamps,
    required this.chapters,
    required this.thumbless,
    required this.active,
    required this.stampColor,
    required this.track,
    required this.bufferColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = duration.inMilliseconds.toDouble();
    final height = thumbless ? 8.0 : 4.0;
    final top = (size.height - height) / 2;
    final radius = Radius.circular(height / 2);
    RRect bar(double from, double to) => RRect.fromLTRBR(
      from,
      top,
      to.clamp(from, size.width),
      top + height,
      radius,
    );
    canvas.drawRRect(bar(0, size.width), Paint()..color = track);
    if (total <= 0) return;
    double x(double ms) => (ms / total).clamp(0.0, 1.0) * size.width;
    canvas.drawRRect(
      bar(0, x(buffer.inMilliseconds.toDouble())),
      Paint()..color = bufferColor,
    );
    for (final s in stamps) {
      canvas.drawRRect(
        bar(x(s.start * 1000), x(s.end * 1000)),
        Paint()..color = stampColor.withValues(alpha: 0.7),
      );
    }
    final px = x(position.inMilliseconds.toDouble());
    canvas.drawRRect(bar(0, px), Paint()..color = active);
    for (final c in chapters) {
      final cx = x(c.start * 1000);
      if (cx < 4 || cx > size.width - 4) continue;
      canvas.drawRect(
        Rect.fromLTWH(cx - 1, top - 1, 2, height + 2),
        Paint()..color = Colors.black.withValues(alpha: 0.6),
      );
    }
    if (!thumbless) {
      canvas.drawCircle(
        Offset(px, size.height / 2),
        7,
        Paint()..color = active,
      );
    }
  }

  @override
  bool shouldRepaint(_SeekPainter old) =>
      old.position != position ||
      old.buffer != buffer ||
      old.duration != duration ||
      old.stamps != stamps ||
      old.chapters != chapters ||
      old.thumbless != thumbless ||
      old.active != active;
}
