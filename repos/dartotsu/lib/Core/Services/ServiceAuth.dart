import '../../Logger.dart';
import 'ScoreFormat.dart';
import '../State/State.dart';

abstract class ServiceUser {
  int get id;
  String get name;
  String? get avatar;
  String? get banner;
  int get episodesWatched;
  int get chaptersRead;
  int get unreadNotifications;

  ScoreFormat? get scoreFormat => null;
}

/// Account layer. `MediaService.auth == null` means the service needs no login
/// (e.g. the on-device extension aggregator).
abstract class ServiceAuth {
  /// Holds the signed-in user (`null` when logged out). Stored as
  /// `Live<ServiceUser?>` so concrete services can upcast their own user type
  /// into it.
  Live<ServiceUser?> get user;

  bool get isLoggedIn;

  /// Interactive OAuth / web-auth flow. Returns whether it succeeded.
  Future<bool> login();

  /// Page that shows the user a token to paste, opened in the browser before
  /// the token dialog. Null = the service has no token login.
  String? get tokenLoginUrl => null;

  bool get supportsTokenLogin => tokenLoginUrl != null;

  Future<bool> loginWithToken(String token) async => false;

  void logout();

  Future<void> refreshUser();
}

/// Shares one in-flight [run] between concurrent callers holding the same
/// [key] (the token), so a burst of `refreshUser()` calls (launch, opening
/// notifications, a feed refresh) costs a single request.
mixin SharedRefresh {
  Future<void>? _inflight;
  String? _inflightKey;

  Future<void> shareRefresh(Future<void> Function() run, {String key = ''}) {
    final current = _inflight;
    if (current != null && _inflightKey == key) return current;
    _inflightKey = key;
    late final Future<void> next;
    next = () async {
      try {
        await run();
      } catch (e, st) {
        logError('Auth', e, st);
      } finally {
        if (identical(_inflight, next)) _inflight = null;
      }
    }();
    return _inflight = next;
  }
}
