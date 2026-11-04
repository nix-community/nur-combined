import '../../Core/Services/MediaService.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../Detail/Watch/Data/Media/ResumeStore.dart';

class ResumeState extends ScreenState {
  final MediaService service;

  ResumeState({required this.service});

  List<ResumeEntry> get entries {
    ResumeStore.entries.length;
    return ResumeStore.visible(service);
  }
}
