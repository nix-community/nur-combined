import '../../../../Core/Services/MediaService.dart';
import '../../../../Model/SearchResults.dart';
import '../../../../Utils/Functions/SnackBar.dart';
import '../Auth.dart';
import '../Data/Browse.dart';
import '../Data/Mapper.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

class SimklSearchView extends SearchScreenView {
  @override
  List<MediaType> get types => const [
    MediaType.anime,
    MediaType.movie,
    MediaType.series,
  ];

  @override
  SearchFilterSpec filters(MediaType type) {
    final kind = switch (type) {
      MediaType.movie => SimklKind.movies,
      MediaType.series => SimklKind.tv,
      _ => SimklKind.anime,
    };
    return SearchFilterSpec(
      sorts: simklSearchSorts,
      formats: kind == SimklKind.anime ? simklAnimeFormats : const [],
      genres: simklGenres(kind),
      countries: kind == SimklKind.anime
          ? const {}
          : {
              '': getString.anyCountry,
              'US': 'United States',
              'GB': 'United Kingdom',
              'JP': 'Japan',
              'KR': 'Korea',
              'CN': 'China',
              'FR': 'France',
              'DE': 'Germany',
              'IN': 'India',
            },
      year: true,
      onList: simklAuth.isLoggedIn,
    );
  }

  @override
  Future<SearchResults?> search(SearchResults query) async {
    if (!simklAuth.isLoggedIn) {
      snackString(getString.simklSignInToSearch);
      return query
        ..results = const []
        ..hasNextPage = false;
    }
    return simklAuth.queries.search(query);
  }
}
