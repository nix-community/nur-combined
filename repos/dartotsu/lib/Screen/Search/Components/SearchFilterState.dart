import '../../../Core/Services/MediaService.dart';
import '../../../Core/State/State.dart';
import '../../../Model/SearchResults.dart';
import '../../../Widgets/Components/ScreenState.dart';

class SearchFilterState extends ScreenState {
  final SearchFilterSpec spec;
  final SearchResults start;
  final void Function(SearchResults) onApply;

  SearchFilterState({
    required this.spec,
    required this.start,
    required this.onApply,
  });

  late final sort = Live<String?>(start.sort);
  late final format = Live<String?>(start.format);
  late final status = Live<String?>(start.status);
  late final source = Live<String?>(start.source);
  late final country = Live<String?>(start.countryOfOrigin);
  late final season = Live<String?>(start.season);
  late final year = Live<int?>(start.seasonYear ?? start.startYear);
  late final Set<String> genres = {...?start.genres};
  late final Set<String> noGenres = {...?start.excludedGenres};
  late final Set<String> tags = {...?start.tags};
  late final Set<String> noTags = {...?start.excludedTags};
  final allTags = false.live;
  final tagQuery = ''.live;

  final selection = Trigger();

  SearchFilterSpec get s => spec;

  void apply() {
    final q = start
      ..sort = sort.value
      ..format = format.value
      ..status = status.value
      ..source = source.value
      ..countryOfOrigin = country.value?.isEmpty == true ? null : country.value
      ..season = season.value
      ..seasonYear = s.season ? year.value : null
      ..startYear = s.season ? null : year.value
      ..genres = genres.isEmpty ? null : genres.toList()
      ..tags = tags.isEmpty ? null : tags.toList()
      ..excludedGenres = noGenres.isEmpty ? null : noGenres.toList()
      ..excludedTags = noTags.isEmpty ? null : noTags.toList()
      ..page = 1;
    onApply(q);
    pop();
  }

  void clear() {
    sort.value = null;
    format.value = null;
    status.value = null;
    source.value = null;
    country.value = null;
    season.value = null;
    year.value = null;
    genres.clear();
    noGenres.clear();
    tags.clear();
    noTags.clear();
    tagQuery.value = '';
    selection.fire();
  }
}
