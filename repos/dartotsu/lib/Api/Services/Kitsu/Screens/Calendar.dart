import '../../../../Core/Services/MediaService.dart';
import '../Auth.dart';

class KitsuCalendarView implements CalendarScreenView {
  @override
  Stream<List<CalendarEntry>> schedule() => kitsuAuth.queries.schedule();
}
