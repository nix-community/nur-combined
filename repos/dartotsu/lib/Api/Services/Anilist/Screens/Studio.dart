import '../../../../Core/Services/MediaService.dart';
import '../Data/Entity.dart';
import 'Entity.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

class AnilistStudioScreen extends AnilistEntityScreen {
  @override
  String get kind => 'studio';

  @override
  Future<Map<String, dynamic>?> fetch(String id) => queries.studio(id);

  @override
  EntityProfile profile(Map<String, dynamic> json) => studioProfile(json);

  @override
  List<ScreenWidget> widgets(Map<String, dynamic> json, String id) => [
    ...mediaSection(
      getString.mainProductions,
      json['main'] as Map<String, dynamic>?,
      'none',
      (page) => queries.studioMedia(id, true, page),
    ),
    ...mediaSection(
      getString.otherWorks,
      json['other'] as Map<String, dynamic>?,
      'none',
      (page) => queries.studioMedia(id, false, page),
    ),
  ];
}
