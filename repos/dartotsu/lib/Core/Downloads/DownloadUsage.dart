import 'DownloadTask.dart';

class TitleUsage {
  final String slot;
  final String title;
  final List<DownloadTask> tasks;
  final Map<String, int> sizes;
  final Set<String> watched;

  const TitleUsage({
    required this.slot,
    required this.title,
    required this.tasks,
    required this.sizes,
    required this.watched,
  });

  int sizeOf(DownloadTask task) => sizes[task.id] ?? 0;

  int get bytes => tasks.fold(0, (sum, t) => sum + sizeOf(t));

  List<DownloadTask> get watchedTasks => [
    for (final t in tasks)
      if (watched.contains(t.id)) t,
  ];

  int get watchedBytes => watchedTasks.fold(0, (sum, t) => sum + sizeOf(t));
}

List<TitleUsage> downloadUsage(
  Iterable<DownloadTask> done,
  Map<String, int> sizes,
  bool Function(DownloadTask) isWatched,
) {
  final groups = <String, List<DownloadTask>>{};
  for (final t in done) {
    groups.putIfAbsent(t.mediaSlot, () => []).add(t);
  }
  final out = [
    for (final e in groups.entries)
      TitleUsage(
        slot: e.key,
        title: e.value.first.mediaTitle,
        tasks: e.value..sort((a, b) => a.number.compareTo(b.number)),
        sizes: sizes,
        watched: {
          for (final t in e.value)
            if (isWatched(t)) t.id,
        },
      ),
  ];
  out.sort((a, b) => b.bytes.compareTo(a.bytes));
  return out;
}

bool progressReached(DownloadTask task, int? progress) =>
    progress != null && progress > 0 && progress >= task.number.floor();
