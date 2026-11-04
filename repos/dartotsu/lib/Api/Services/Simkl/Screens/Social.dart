import '../../../../Logger.dart';
import '../../../../Core/Services/MediaService.dart';
import '../Auth.dart';

class SimklSocialView extends SocialScreenView {
  SimklSocialView(super.service);

  @override
  bool get hasActivity => false;

  @override
  bool get hasGlobalFeed => false;

  @override
  bool get hasFollows => false;

  @override
  String? profileUrl(String name) => 'https://simkl.com/';

  Future<Map<String, dynamic>> _stats(String id) async {
    final data = await simklAuth.client.get('/users/$id/stats');
    return data is Map ? data.cast<String, dynamic>() : const {};
  }

  Future<Map?> _settingsUser() async {
    try {
      final settings = await simklAuth.client.get('/users/settings');
      return settings is Map ? settings['user'] as Map? : null;
    } catch (e, st) {
      logError('Social', e, st);
      return null;
    }
  }

  int _int(Object? v) => (v as num?)?.toInt() ?? 0;

  Map<String, dynamic> _bucket(Map<String, dynamic> stats, String kind) =>
      (stats[kind] as Map?)?.cast<String, dynamic>() ?? const {};

  int _sum(Map<String, dynamic> bucket, String key) {
    var total = 0;
    for (final v in bucket.values) {
      if (v is Map) total += _int(v[key]);
    }
    return total;
  }

  @override
  Future<SocialUser?> profile({String? id, String? name}) async {
    final me = currentUserId;
    final target = id ?? me;
    if (target == null) return null;
    final (stats, user) = await (
      _stats(target),
      target == me ? _settingsUser() : Future<Map?>.value(),
    ).wait;
    final anime = _bucket(stats, 'anime');
    final userName = user?['name'] as String? ?? name ?? '';
    final avatar = user?['avatar'] as String?;
    final bio = user?['bio'] as String?;
    final about = bio == null || bio.isEmpty ? null : bio;
    return SocialUser(
      id: target,
      name: userName,
      avatar: avatar,
      about: about,
      siteUrl: 'https://simkl.com/',
      animeCount: _sum(anime, 'count'),
      episodesWatched: _sum(anime, 'watched_episodes_count'),
      minutesWatched: _int(anime['total_mins']),
    );
  }

  UserStatSet _set(Map<String, dynamic> bucket, {required bool episodes}) {
    const labels = {
      'watching': 'Watching',
      'plantowatch': 'Plan to watch',
      'hold': 'On hold',
      'completed': 'Completed',
      'dropped': 'Dropped',
    };
    final entries = [
      for (final e in labels.entries)
        if (bucket[e.key] case final Map m when _int(m['count']) > 0)
          StatEntry(label: e.value, count: _int(m['count'])),
    ];
    return UserStatSet(
      count: _sum(bucket, 'count'),
      minutesWatched: _int(bucket['total_mins']),
      episodesWatched: episodes ? _sum(bucket, 'watched_episodes_count') : 0,
      categories: entries.isEmpty
          ? const []
          : [StatCategory('statuses', 'Status', entries)],
    );
  }

  @override
  Future<UserStats?> stats(String userId) async {
    final stats = await _stats(userId);
    return UserStats(
      anime: _set(_bucket(stats, 'anime'), episodes: true),
      manga: const UserStatSet(),
    );
  }
}
