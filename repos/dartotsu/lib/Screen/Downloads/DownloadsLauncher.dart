import '../../Core/NotificationManager/NotificationManager.dart';
import '../../Core/State/State.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import 'DownloadsScreen.dart';

void installDownloadLinks() {
  onChange(find<NotificationManager>().tapped, (payload) {
    final context = appContext;
    if (payload != 'downloads' || context == null) return;
    navigateToPage(context, const DownloadsScreen());
  });
}
