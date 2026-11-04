import '../../../../Core/Services/MediaService.dart';
import '../Data/Entity.dart';
import 'Entity.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

class AnilistStaffScreen extends AnilistEntityScreen {
  @override
  String get kind => 'staff';

  @override
  Future<Map<String, dynamic>?> fetch(String id) => queries.staff(id);

  @override
  EntityProfile profile(Map<String, dynamic> json) => staffProfile(json);

  @override
  List<ScreenWidget> widgets(Map<String, dynamic> json, String id) {
    final voiced = mapStaffCharacters(
      json['characters'] as Map<String, dynamic>?,
    );
    return [
      if (voiced.isNotEmpty)
        ScreenWidget.characters(getString.voicedCharacters, voiced),
      ...mediaSection(
        getString.animeCredits,
        json['anime'] as Map<String, dynamic>?,
        'staffRole',
        (page) => queries.staffMedia(id, 'ANIME', page),
      ),
      ...mediaSection(
        getString.mangaCredits,
        json['manga'] as Map<String, dynamic>?,
        'staffRole',
        (page) => queries.staffMedia(id, 'MANGA', page),
      ),
    ];
  }
}
