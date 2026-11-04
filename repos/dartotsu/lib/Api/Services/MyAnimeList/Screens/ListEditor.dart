import '../../../../Core/Services/MediaService.dart';
import '../../../../Core/Services/Model/Media.dart';
import '../../../../Widgets/Components/ListEditorFields.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';

class MalListEditorView extends ListEditorScreenView {
  MalListEditorView(super.service);

  @override
  Map<String, String> statuses({required bool anime}) => {
    'CURRENT': anime ? getString.watching : getString.reading,
    'PLANNING': anime ? getString.planToWatch : getString.planToRead,
    'COMPLETED': getString.completed,
    'PAUSED': getString.onHold,
    'DROPPED': getString.dropped,
    'REPEATING': anime ? getString.rewatching : getString.rereading,
  };

  @override
  List<ScreenWidget> build(Media media, ListEditorDraft draft) => [
    ScreenWidget.extra(
      ListStatusField(
        draft: draft,
        statuses: statuses(anime: media.isAnime),
      ),
    ),
    ScreenWidget.extra(
      ListProgressField(draft: draft, total: media.totalUnits),
    ),
    ScreenWidget.extra(ListScoreField(draft: draft)),
    ScreenWidget.extra(ListDatesField(draft: draft)),
    ScreenWidget.extra(
      ListRepeatField(
        draft: draft,
        label: media.isAnime ? getString.timesRewatched : getString.timesReread,
      ),
    ),
    ScreenWidget.extra(ListNotesField(draft: draft, label: getString.comments)),
  ];
}
