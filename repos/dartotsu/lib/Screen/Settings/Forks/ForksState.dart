import '../../../Widgets/Components/ScreenState.dart';
import 'Forks.dart';

class ForksState extends ScreenState {
  static const skeleton = AppFork(
    ownerName: 'owner',
    ownerAvatar: '',
    repoName: 'Dartotsu',
    uri: '',
  );

  late final future = loadForks();

  List<AppFork> itemsFor({required bool loading, List<AppFork>? forks}) =>
      loading ? List.filled(8, skeleton) : (forks ?? const []);
}
