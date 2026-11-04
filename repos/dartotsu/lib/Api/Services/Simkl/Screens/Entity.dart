import '../../../../Core/Services/MediaService.dart';
import '../../MyAnimeList/Screens/Entity.dart';

class SimklEntityView extends MalEntityView {
  SimklEntityView(super.service);

  @override
  Stream<List<ScreenWidget>> screenStream(EntityHost host) => super
      .screenStream(host)
      .map(
        (widgets) => [
          for (final w in widgets)
            if (w.type != ScreenWidgetType.media) w,
        ],
      );
}
