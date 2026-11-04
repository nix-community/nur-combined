import 'package:flutter/widgets.dart';
import '../../Core/State/State.dart';

class RefreshController extends AppController {
  var activity = <String, Live<bool>>{};

  void all() => activity.forEach((k, v) => v.value = true);

  void refreshService(RefreshIds group) {
    for (var id in group.allIds) {
      activity[id]?.value = true;
    }
  }

  void allButNot(String k) {
    activity.forEach((key, v) {
      if (key != k) v.value = true;
    });
  }

  Live<bool> getOrPut(String key, bool initialValue) {
    return activity.putIfAbsent(key, () => Live<bool>(initialValue));
  }
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

abstract class RefreshIds {
  String get animePage;
  String get mangaPage;
  String get homePage;
  String get listPage;

  List<String> get allIds => [animePage, mangaPage, homePage, listPage];
}
