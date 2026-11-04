import '../../../../Core/Services/MediaService.dart';
import '../Auth.dart';
import '../Prefs.dart';

class KitsuHomeView extends HomeScreenView {
  KitsuHomeView(super.service);

  @override
  Stream<List<ScreenWidget>> screenStream() {
    if (!kitsuAuth.isLoggedIn) return super.screenStream();
    return sectionWidgets(
      kitsuAuth.queries.homeJobs(),
      build: ScreenWidget.media,
    );
  }

  @override
  bool isHiddenSection(String title) =>
      title == 'Hidden Media' &&
      KitsuPref.homeLayout.value['Hidden Media'] != true;
}
