import '../../../../Core/Services/MediaService.dart';
import '../../../../Model/SearchResults.dart';
import '../Auth.dart';
import '../Queries.dart';

class MangaBakaSearchView extends SearchScreenView {
  @override
  List<MediaType> get types => const [MediaType.manga, MediaType.novel];

  @override
  Future<SearchResults?> search(SearchResults query) =>
      mangaBakaAuth.queries.search(query);

  @override
  Future<void> prepare() async {
    await mangaBakaAuth.queries.getGenresAndTags();
  }

  @override
  List<SearchType> get searchTypes => const [SearchType.MANGA];

  @override
  SearchFilterSpec filters(MediaType type) => SearchFilterSpec(
    sorts: mangaBakaSearchSorts,
    formats: const ['MANGA', 'NOVEL', 'MANHWA', 'MANHUA', 'OEL'],
    statuses: const [
      'RELEASING',
      'FINISHED',
      'NOT YET RELEASED',
      'HIATUS',
      'CANCELLED',
    ],
    genres: mangaBakaGenres(),
    tags: mangaBakaTags(),
    adult: true,
    onList: mangaBakaAuth.isLoggedIn,
  );
}
