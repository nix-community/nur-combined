import '../../../../Core/Services/MediaService.dart';
import '../Auth.dart';
import '../Prefs.dart';

class MangaBakaHomeView extends HomeScreenView {
  MangaBakaHomeView(super.service);

  @override
  Stream<List<ScreenWidget>> screenStream() {
    if (!mangaBakaAuth.isLoggedIn) return super.screenStream();
    return sectionWidgets(
      mangaBakaAuth.queries.homeJobs(),
      build: ScreenWidget.media,
    );
  }

  @override
  bool isHiddenSection(String title) =>
      title == 'Hidden Media' &&
      MangaBakaPref.homeLayout.value['Hidden Media'] != true;
}
