import '../../../../Core/Services/MediaService.dart';
import '../Data/Entity.dart';
import 'Entity.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

class AnilistCharacterScreen extends AnilistEntityScreen {
  @override
  String get kind => 'character';

  @override
  Future<Map<String, dynamic>?> fetch(String id) => queries.character(id);

  @override
  EntityProfile profile(Map<String, dynamic> json) => characterProfile(json);

  @override
  List<ScreenWidget> widgets(Map<String, dynamic> json, String id) {
    final anime = json['anime'] as Map<String, dynamic>?;
    final manga = json['manga'] as Map<String, dynamic>?;
    return [
      for (final entry in voiceActorsByLanguage(anime).entries)
        ScreenWidget.staff(getString.voiceActorsIn(entry.key), entry.value),
      ...mediaSection(
        getString.animeAppearances,
        anime,
        'characterRole',
        (page) => queries.characterMedia(id, 'ANIME', page),
      ),
      ...mediaSection(
        getString.mangaAppearances,
        manga,
        'characterRole',
        (page) => queries.characterMedia(id, 'MANGA', page),
      ),
    ];
  }
}
