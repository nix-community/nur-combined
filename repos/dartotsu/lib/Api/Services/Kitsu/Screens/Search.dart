import '../../../../Core/Services/MediaService.dart';
import '../../../../Model/SearchResults.dart';
import '../Auth.dart';
import '../Queries.dart';

class KitsuSearchView extends SearchScreenView {
  @override
  Future<SearchResults?> search(SearchResults query) =>
      kitsuAuth.queries.search(query);

  @override
  Future<void> prepare() async {
    await kitsuAuth.queries.getGenresAndTags();
  }

  @override
  List<SearchType> get searchTypes => const [
    SearchType.ANIME,
    SearchType.MANGA,
    SearchType.NOVEL,
    SearchType.CHARACTER,
    SearchType.USER,
  ];

  @override
  SearchFilterSpec filters(MediaType type) {
    final anime = type.isVideo;
    return SearchFilterSpec(
      sorts: kitsuSearchSorts,
      formats: anime
          ? const ['TV', 'MOVIE', 'OVA', 'ONA', 'SPECIAL', 'MUSIC']
          : const [
              'MANGA',
              'NOVEL',
              'ONE SHOT',
              'MANHWA',
              'MANHUA',
              'DOUJIN',
              'OEL',
            ],
      statuses: const ['RELEASING', 'FINISHED', 'NOT YET RELEASED'],
      genres: kitsuGenres(),
      season: anime,
      year: true,
      onList: kitsuAuth.isLoggedIn,
    );
  }
}
