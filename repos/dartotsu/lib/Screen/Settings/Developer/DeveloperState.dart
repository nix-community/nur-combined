import '../../../Core/Preferences/PrefManager.dart';
import '../../../Core/State/State.dart';
import '../../../Widgets/Components/ScreenState.dart';
import 'Developer.dart';

class DeveloperState extends ScreenState {
  static const skeleton = Developer(
    name: 'Loading name',
    githubId: '',
    pfp: '',
    banner: '',
    uri: '',
    role: 'Loading role',
    contributions: 99,
  );

  late final future = loadDevelopers();
  late final wide =
      (PrefManager.getCustomVal<bool>('followWide') ?? false).live;

  List<Developer> itemsFor({required bool loading, List<Developer>? list}) =>
      loading ? List.filled(8, skeleton) : (list ?? const []);

  void toggleWide() {
    wide.value = !wide.value;
    PrefManager.setCustomVal<bool>('followWide', wide.value);
  }
}
