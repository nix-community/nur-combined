import '../../../Model/SearchResults.dart';
import '../Model/Media.dart';

String _norm(String s) => s.toLowerCase().trim();

bool _matches(Media m, SearchResults q) {
  final term = _norm(q.search ?? '');
  if (term.isNotEmpty) {
    final names = [
      m.name,
      m.nameRomaji,
      ...m.synonyms,
    ].whereType<String>().map(_norm);
    if (!names.any((n) => n.contains(term))) return false;
  }
  final genres = q.genres ?? const <String>[];
  if (genres.isNotEmpty) {
    final have = m.genres.map(_norm).toSet();
    if (!genres.every((g) => have.contains(_norm(g)))) return false;
  }
  final excluded = q.excludedGenres ?? const <String>[];
  if (excluded.isNotEmpty) {
    final have = m.genres.map(_norm).toSet();
    if (excluded.any((g) => have.contains(_norm(g)))) return false;
  }
  if (q.format != null && _norm(m.format ?? '') != _norm(q.format!)) {
    return false;
  }
  if (q.status != null &&
      _norm((m.status ?? '').replaceAll('_', ' ')) !=
          _norm(q.status!.replaceAll('_', ' '))) {
    return false;
  }
  if (q.seasonYear != null && m.startDate?.year != q.seasonYear) return false;
  if (q.isAdult != true && m.isAdult) return false;
  return true;
}

SearchResults searchLibrary(List<Media> library, SearchResults q) {
  final found = [
    for (final m in library)
      if (_matches(m, q)) m,
  ];
  final per = (q.perPage ?? 25).clamp(1, 100);
  final page = q.page ?? 1;
  final from = (page - 1) * per;
  final slice = from >= found.length
      ? const <Media>[]
      : found.sublist(from, (from + per).clamp(0, found.length));
  return q
    ..results = slice
    ..hasNextPage = from + per < found.length;
}
