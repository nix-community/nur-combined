import '../../../../Logger.dart';
import 'dart:async';

import '../../../../Core/Services/MediaService.dart';
import '../../../../Utils/Lru.dart';
import '../../../../Core/Services/Model/Author.dart';
import '../../../../Core/Services/Model/Character.dart';
import '../../../../Core/Services/Model/Media.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../Auth.dart';
import '../Client.dart';
import '../Data/Mapper.dart';
import '../Prefs.dart';
import 'Settings.dart';

const _pageSize = 20;

class KitsuSocialView extends SocialScreenView {
  KitsuSocialView(super.service);

  KitsuClient get _client => kitsuAuth.client;

  final Map<String, String> _cursors = {};

  @override
  AccountOptions? get accountOptions => AccountOptions(
    title: getString.kitsuAccountOptions,
    build: KitsuSettingsView.accountOptions,
  );

  @override
  bool get hasActivity => false;

  @override
  bool get hasGlobalFeed => true;

  @override
  bool get hasGroups => true;

  @override
  String? profileUrl(String name) => 'https://kitsu.app/users/$name';

  static final _link = RegExp(
    r'kitsu\.(?:app|io)/(anime|manga|users|posts|groups)/([^/?#\s]+)',
  );

  @override
  AppLink? parseLink(String url) {
    final m = _link.firstMatch(url);
    if (m == null) return null;
    final kind = switch (m.group(1)) {
      'anime' => AppLinkKind.anime,
      'manga' => AppLinkKind.manga,
      'users' => AppLinkKind.user,
      'groups' => AppLinkKind.group,
      _ => AppLinkKind.activity,
    };
    return AppLink(kind, m.group(2)!);
  }

  UserBrief _brief(Map<String, dynamic>? node) {
    if (node == null) return UserBrief(id: '0', name: '');
    final a = attrs(node);
    return UserBrief(
      id: '${node['id']}',
      name: a['name'] as String? ?? '',
      avatar: kitsuImage(a['avatar'], const ['large', 'medium', 'original']),
      banner: kitsuImage(a['coverImage'], const ['large', 'original']),
    );
  }

  Future<SocialUser?> _userNode(String? id, String? name) async {
    Map<String, dynamic> body;
    if (id != null) {
      body = await _client.get('/users/$id');
    } else if (name != null) {
      body = await _client.get(
        '/users',
        query: {'filter[name]': name, 'page[limit]': '1'},
      );
      if (JsonApi(body).data.isEmpty) {
        body = await _client.get(
          '/users',
          query: {'filter[slug]': name, 'page[limit]': '1'},
        );
      }
    } else {
      return null;
    }
    final doc = JsonApi(body);
    if (doc.data.isEmpty) return null;
    final node = doc.data.first;
    final a = attrs(node);
    final brief = _brief(node);
    final (stats, following) = await (
      _consumed(brief.id),
      _isFollowing(brief.id),
    ).wait;
    final slug = a['slug'] as String? ?? brief.name;
    return SocialUser(
      id: brief.id,
      name: brief.name,
      avatar: brief.avatar,
      banner: brief.banner,
      about: a['about'] as String?,
      siteUrl: 'https://kitsu.app/users/$slug',
      isFollowing: following,
      followers: (a['followersCount'] as num?)?.toInt() ?? 0,
      following: (a['followingCount'] as num?)?.toInt() ?? 0,
      animeCount: stats.anime.count,
      mangaCount: stats.manga.count,
      episodesWatched: stats.anime.episodesWatched,
      minutesWatched: stats.anime.minutesWatched,
      chaptersRead: stats.manga.chaptersRead,
    );
  }

  @override
  Future<SocialUser?> profile({String? id, String? name}) =>
      _userNode(id, name);

  Future<bool> _isFollowing(String userId) async {
    final me = currentUserId;
    if (me == null || me == userId || !service.isLoggedIn) return false;
    try {
      final res = await _client.get(
        '/follows',
        query: {
          'filter[follower]': me,
          'filter[followed]': userId,
          'page[limit]': '1',
          'fields[follows]': 'createdAt',
        },
      );
      return JsonApi(res).data.isNotEmpty;
    } catch (e, st) {
      logError('Social', e, st);
      return false;
    }
  }

  final _statsCache =
      Lru<String, (DateTime, Future<Map<String, Map<String, dynamic>>>)>(8);

  Future<Map<String, Map<String, dynamic>>> _statsByKind(String userId) {
    final hit = _statsCache[userId];
    if (hit != null &&
        DateTime.now().difference(hit.$1) < const Duration(minutes: 2)) {
      return hit.$2;
    }
    final future = _loadStats(userId);
    _statsCache[userId] = (DateTime.now(), future);
    unawaited(
      future.then<void>((_) {}, onError: (_) => _statsCache.remove(userId)),
    );
    return future;
  }

  Future<Map<String, Map<String, dynamic>>> _loadStats(String userId) async {
    final res = await _client.get(
      '/stats',
      query: {'filter[userId]': userId, 'page[limit]': '20'},
    );
    return {
      for (final n in JsonApi(res).data)
        if (attrs(n)['kind'] is String)
          attrs(n)['kind'] as String:
              (attrs(n)['statsData'] as Map?)?.cast<String, dynamic>() ??
              const {},
    };
  }

  UserStatSet _set(
    Map<String, dynamic>? consumed,
    Map<String, dynamic>? breakdown, {
    required bool anime,
  }) {
    final units = (consumed?['units'] as num?)?.toInt() ?? 0;
    final categories = <StatEntry>[
      for (final e
          in ((breakdown?['categories'] as Map?) ?? const {}).entries.toList()
            ..sort(
              (a, b) =>
                  ((b.value as num?) ?? 0).compareTo((a.value as num?) ?? 0),
            ))
        StatEntry(label: '${e.key}', count: (e.value as num?)?.toInt() ?? 0),
    ];
    return UserStatSet(
      count: (consumed?['media'] as num?)?.toInt() ?? 0,
      minutesWatched: anime
          ? ((consumed?['time'] as num?)?.toInt() ?? 0) ~/ 60
          : 0,
      episodesWatched: anime ? units : 0,
      chaptersRead: anime ? 0 : units,
      categories: categories.isEmpty
          ? const []
          : [StatCategory('genres', 'Genres', categories)],
    );
  }

  Future<UserStats> _consumed(String userId) async {
    try {
      final s = await _statsByKind(userId);
      return UserStats(
        anime: _set(
          s['anime-amount-consumed'],
          s['anime-category-breakdown'],
          anime: true,
        ),
        manga: _set(
          s['manga-amount-consumed'],
          s['manga-category-breakdown'],
          anime: false,
        ),
      );
    } catch (e, st) {
      logError('Social', e, st);
      return const UserStats(anime: UserStatSet(), manga: UserStatSet());
    }
  }

  @override
  Future<UserStats?> stats(String userId) => _consumed(userId);

  @override
  Future<List<ActivityDay>> activityHistory(String userId) async {
    final s = await _statsByKind(userId);
    final days = <String, int>{};
    for (final kind in const [
      'anime-activity-history',
      'manga-activity-history',
    ]) {
      final map = (s[kind]?['days'] as Map?) ?? const {};
      for (final e in map.entries) {
        final units = ((e.value as Map?)?['units'] as num?)?.toInt() ?? 0;
        days['${e.key}'] = (days['${e.key}'] ?? 0) + units;
      }
    }
    int level(int n) => n <= 0
        ? 0
        : n <= 1
        ? 1
        : n <= 3
        ? 2
        : n <= 6
        ? 3
        : 4;
    return [
      for (final e in days.entries)
        if (DateTime.tryParse(e.key) case final d?)
          ActivityDay(d, e.value, level(e.value)),
    ]..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<SocialFavourites> favourites(String userId) async {
    final res = await _client.get(
      '/favorites',
      query: {
        'filter[userId]': userId,
        'include': 'item',
        'sort': 'favRank',
        'page[limit]': '20',
      },
    );
    final doc = JsonApi(res);
    final anime = <Media>[];
    final manga = <Media>[];
    final characters = <Character>[];
    final staff = <Author>[];
    for (final fav in doc.data) {
      final item = doc.one(fav, 'item');
      if (item == null) continue;
      final a = attrs(item);
      switch (item['type']) {
        case 'anime':
          anime.add(mapKitsuMedia(item, doc: doc));
        case 'manga':
          manga.add(mapKitsuMedia(item, doc: doc));
        case 'characters':
          characters.add(
            Character(
              id: '${item['id']}',
              name: a['name'] as String? ?? a['canonicalName'] as String?,
              image: kitsuImage(a['image'], const ['original', 'large']),
            ),
          );
        case 'people':
          staff.add(
            Author(
              id: '${item['id']}',
              name: a['name'] as String?,
              image: kitsuImage(a['image'], const ['original', 'large']),
            ),
          );
      }
    }
    return SocialFavourites(
      anime: anime,
      manga: manga,
      characters: characters,
      staff: staff,
    );
  }

  @override
  Future<List<Media>> favouriteMedia(
    String userId, {
    required bool anime,
    int page = 1,
  }) async {
    final res = await _client.get(
      '/favorites',
      query: {
        'filter[userId]': userId,
        'filter[itemType]': anime ? 'Anime' : 'Manga',
        'include': 'item',
        'sort': 'favRank',
        'page[limit]': '$_pageSize',
        'page[offset]': '${(page - 1) * _pageSize}',
      },
    );
    final doc = JsonApi(res);
    return [
      for (final fav in doc.data)
        if (doc.one(fav, 'item') case final item?)
          mapKitsuMedia(item, doc: doc),
    ];
  }

  @override
  Future<UserPage> follows(
    String userId, {
    required bool followers,
    int page = 1,
  }) async {
    final res = await _client.get(
      '/follows',
      query: {
        'filter[${followers ? 'followed' : 'follower'}]': userId,
        'include': followers ? 'follower' : 'followed',
        'page[limit]': '$_pageSize',
        'page[offset]': '${(page - 1) * _pageSize}',
      },
    );
    final doc = JsonApi(res);
    return UserPage([
      for (final f in doc.data)
        if (doc.one(f, followers ? 'follower' : 'followed') case final u?)
          _brief(u),
    ], hasNext: doc.next != null);
  }

  @override
  Future<bool?> toggleFollow(String userId) async {
    final me = currentUserId;
    if (me == null) return null;
    try {
      final res = await _client.get(
        '/follows',
        query: {
          'filter[follower]': me,
          'filter[followed]': userId,
          'page[limit]': '1',
        },
      );
      final existing = JsonApi(res).data;
      if (existing.isNotEmpty) {
        await _client.delete('/follows/${existing.first['id']}');
        return false;
      }
      await _client.post('/follows', {
        'data': {
          'type': 'follows',
          'relationships': {
            'follower': {
              'data': {'type': 'users', 'id': me},
            },
            'followed': {
              'data': {'type': 'users', 'id': userId},
            },
          },
        },
      });
      return true;
    } catch (e, st) {
      logError('Social', e, st);
      return null;
    }
  }

  Activity? _post(Map<String, dynamic> node, JsonApi doc, Set<String> liked) {
    final a = attrs(node);
    if (a['deletedAt'] != null) return null;
    if (a['nsfw'] == true && KitsuPref.hideNsfw.value) return null;
    final mediaNode = doc.one(node, 'media');
    final id = '${node['id']}';
    return Activity(
      id: id,
      kind: ActivityKind.text,
      user: _brief(doc.one(node, 'user')),
      text: a['content'] as String?,
      html: a['contentFormatted'] as String?,
      media: mediaNode == null ? null : mapKitsuMedia(mediaNode, doc: doc),
      mediaType: mediaNode?['type'] == 'manga' ? 'MANGA' : 'ANIME',
      replyCount: (a['commentsCount'] as num?)?.toInt() ?? 0,
      likeCount: (a['postLikesCount'] as num?)?.toInt() ?? 0,
      isLiked: liked.contains(id),
      isLocked: a['lockedAt'] != null,
      createdAt: kitsuEpoch(a['createdAt']) ?? 0,
      siteUrl: 'https://kitsu.app/posts/$id',
    );
  }

  Future<Set<String>> _likedPosts(List<String> ids) async {
    final me = currentUserId;
    if (me == null || ids.isEmpty) return {};
    try {
      final res = await _client.get(
        '/post-likes',
        query: {
          'filter[postId]': ids.join(','),
          'filter[userId]': me,
          'include': 'post',
          'fields[posts]': 'id',
          'page[limit]': '$_pageSize',
        },
      );
      final doc = JsonApi(res);
      return {
        for (final l in doc.data)
          if (doc.one(l, 'post') case final p?) '${p['id']}',
      };
    } catch (e, st) {
      logError('Social', e, st);
      return {};
    }
  }

  Future<List<Activity>> _postsById(List<String> ids) async {
    if (ids.isEmpty) return [];
    final (res, liked) = await (
      _client.get(
        '/posts',
        query: {
          'filter[id]': ids.join(','),
          'include': 'user,media',
          'page[limit]': '$_pageSize',
        },
      ),
      _likedPosts(ids),
    ).wait;
    final doc = JsonApi(res);
    final posts = [for (final n in doc.data) ?_post(n, doc, liked)];
    final byId = {for (final a in posts) a.id: a};
    return [for (final id in ids) ?byId[id]];
  }

  Future<ActivityPage> _feed(String feed, String key, int page) async {
    if (page == 1) _cursors.removeWhere((k, _) => k.startsWith('$key|'));
    final cursor = page > 1 ? _cursors['$key|$page'] : null;
    final res = await _client.get(
      '/feeds/$feed',
      query: {
        'page[limit]': '$_pageSize',
        'page[cursor]': ?cursor,
        'include': 'activities',
      },
    );
    final doc = JsonApi(res);
    final next = doc.next == null
        ? null
        : Uri.tryParse(doc.next!)?.queryParameters['page[cursor]'];
    if (next != null) _cursors['$key|${page + 1}'] = next;
    final ids = <String>[
      for (final group in doc.data)
        for (final act in doc.many(group, 'activities'))
          if ('${attrs(act)['foreignId']}'.startsWith('Post:'))
            '${attrs(act)['foreignId']}'.substring(5),
    ];
    return ActivityPage(await _postsById(ids), hasNext: next != null);
  }

  @override
  Future<ActivityPage> activities(
    ActivityScope scope, {
    String? userId,
    String? activityId,
    int page = 1,
  }) async {
    switch (scope) {
      case ActivityScope.single:
        if (activityId == null) return const ActivityPage([]);
        return ActivityPage(await _postsById([activityId]));
      case ActivityScope.user:
        if (userId == null) return const ActivityPage([]);
        return _feed('user/$userId', 'user$userId', page);
      case ActivityScope.following:
        final me = currentUserId;
        if (me == null) return const ActivityPage([]);
        return _feed('timeline/$me', 'timeline', page);
      case ActivityScope.global:
        final res = await _client.get(
          '/posts',
          query: {
            'sort': '-createdAt',
            'include': 'user,media',
            'page[limit]': '$_pageSize',
            'page[offset]': '${(page - 1) * _pageSize}',
          },
        );
        final doc = JsonApi(res);
        final liked = await _likedPosts([
          for (final n in doc.data) '${n['id']}',
        ]);
        return ActivityPage([
          for (final n in doc.data) ?_post(n, doc, liked),
        ], hasNext: doc.next != null);
      case ActivityScope.inbox:
      case ActivityScope.sent:
        return const ActivityPage([]);
    }
  }

  @override
  Future<ReplyPage> replies(String activityId, {int page = 1}) async {
    final res = await _client.get(
      '/comments',
      query: {
        'filter[postId]': activityId,
        'include': 'user',
        'sort': 'createdAt',
        'page[limit]': '$_pageSize',
        'page[offset]': '${(page - 1) * _pageSize}',
      },
    );
    final doc = JsonApi(res);
    return ReplyPage([
      for (final c in doc.data)
        if (attrs(c)['deletedAt'] == null)
          ActivityReply(
            id: '${c['id']}',
            activityId: activityId,
            user: _brief(doc.one(c, 'user')),
            text: attrs(c)['content'] as String? ?? '',
            html: attrs(c)['contentFormatted'] as String?,
            likeCount: (attrs(c)['likesCount'] as num?)?.toInt() ?? 0,
            createdAt: kitsuEpoch(attrs(c)['createdAt']) ?? 0,
          ),
    ], hasNext: doc.next != null);
  }

  @override
  Future<bool> toggleLike(String id, {bool reply = false}) async {
    final me = currentUserId;
    if (me == null) return false;
    final collection = reply ? 'comment-likes' : 'post-likes';
    final target = reply ? 'comment' : 'post';
    try {
      final res = await _client.get(
        '/$collection',
        query: {
          'filter[${target}Id]': id,
          'filter[userId]': me,
          'page[limit]': '1',
        },
      );
      final existing = JsonApi(res).data;
      if (existing.isNotEmpty) {
        await _client.delete('/$collection/${existing.first['id']}');
        return true;
      }
      await _client.post('/$collection', {
        'data': {
          'type': reply ? 'commentLikes' : 'postLikes',
          'relationships': {
            'user': {
              'data': {'type': 'users', 'id': me},
            },
            target: {
              'data': {'type': reply ? 'comments' : 'posts', 'id': id},
            },
          },
        },
      });
      return true;
    } catch (e, st) {
      logError('Social', e, st);
      return false;
    }
  }

  @override
  Future<bool> postActivity(String text, {String? edit}) async {
    final me = currentUserId;
    if (me == null) return false;
    try {
      if (edit != null) {
        await _client.patch('/posts/$edit', {
          'data': {
            'type': 'posts',
            'id': edit,
            'attributes': {'content': text},
          },
        });
      } else {
        await _client.post('/posts', {
          'data': {
            'type': 'posts',
            'attributes': {'content': text},
            'relationships': {
              'user': {
                'data': {'type': 'users', 'id': me},
              },
            },
          },
        });
      }
      return true;
    } catch (e, st) {
      logError('Social', e, st);
      return false;
    }
  }

  @override
  Future<bool> postReply(String activityId, String text, {String? edit}) async {
    final me = currentUserId;
    if (me == null) return false;
    try {
      if (edit != null) {
        await _client.patch('/comments/$edit', {
          'data': {
            'type': 'comments',
            'id': edit,
            'attributes': {'content': text},
          },
        });
      } else {
        await _client.post('/comments', {
          'data': {
            'type': 'comments',
            'attributes': {'content': text},
            'relationships': {
              'user': {
                'data': {'type': 'users', 'id': me},
              },
              'post': {
                'data': {'type': 'posts', 'id': activityId},
              },
            },
          },
        });
      }
      return true;
    } catch (e, st) {
      logError('Social', e, st);
      return false;
    }
  }

  @override
  Future<bool> deleteActivity(String id) async {
    try {
      await _client.delete('/posts/$id');
      return true;
    } catch (e, st) {
      logError('Social', e, st);
      return false;
    }
  }

  @override
  Future<bool> deleteReply(String id) async {
    try {
      await _client.delete('/comments/$id');
      return true;
    } catch (e, st) {
      logError('Social', e, st);
      return false;
    }
  }

  SocialGroup _group(Map<String, dynamic> node, JsonApi doc) {
    final a = attrs(node);
    final category = doc.one(node, 'category');
    final slug = a['slug'] as String?;
    return SocialGroup(
      id: '${node['id']}',
      name: a['name'] as String? ?? '',
      slug: slug,
      tagline: a['tagline'] as String?,
      about: a['about'] as String?,
      rules: a['rules'] as String?,
      avatar: kitsuImage(a['avatar'], const ['large', 'medium', 'original']),
      cover: kitsuImage(a['coverImage'], const ['large', 'original']),
      category: category == null ? null : attrs(category)['name'] as String?,
      locale: a['locale'] as String?,
      privacy: a['privacy'] as String? ?? 'open',
      members: (a['membersCount'] as num?)?.toInt() ?? 0,
      leaders: (a['leadersCount'] as num?)?.toInt() ?? 0,
      createdAt: kitsuEpoch(a['createdAt']) ?? 0,
      nsfw: a['nsfw'] == true,
      siteUrl: 'https://kitsu.app/groups/${slug ?? node['id']}',
    );
  }

  Future<Map<String, String>> _ranks(List<String> groupIds) async {
    final me = currentUserId;
    if (me == null || groupIds.isEmpty) return {};
    try {
      final res = await _client.get(
        '/group-members',
        query: {
          'filter[group]': groupIds.join(','),
          'filter[user]': me,
          'include': 'group',
          'fields[groups]': 'name',
          'page[limit]': '${groupIds.length}',
        },
      );
      final doc = JsonApi(res);
      return {
        for (final m in doc.data)
          if (doc.one(m, 'group') case final g?)
            '${g['id']}': attrs(m)['rank'] as String? ?? 'pleb',
      };
    } catch (e, st) {
      logError('Social', e, st);
      return {};
    }
  }

  List<SocialGroup> _visible(Iterable<SocialGroup> groups) => [
    for (final g in groups)
      if (!(g.nsfw && KitsuPref.hideNsfw.value)) g,
  ];

  @override
  Future<GroupPage> groups(
    GroupScope scope, {
    String? query,
    String? categoryId,
    int page = 1,
  }) async {
    final offset = '${(page - 1) * _pageSize}';
    if (scope == GroupScope.joined) {
      final me = currentUserId;
      if (me == null) return const GroupPage([]);
      final res = await _client.get(
        '/group-members',
        query: {
          'filter[user]': me,
          'include': 'group,group.category',
          'page[limit]': '$_pageSize',
          'page[offset]': offset,
        },
      );
      final doc = JsonApi(res);
      final out = <SocialGroup>[];
      for (final m in doc.data) {
        final node = doc.one(m, 'group');
        if (node == null) continue;
        out.add(
          _group(node, doc)
            ..isMember = true
            ..rank = attrs(m)['rank'] as String?,
        );
      }
      final text = query?.trim().toLowerCase() ?? '';
      return GroupPage(
        _visible(
          text.isEmpty
              ? out
              : out.where((g) => g.name.toLowerCase().contains(text)),
        ),
        hasNext: doc.next != null,
      );
    }
    final text = query?.trim() ?? '';
    final res = await _client.get(
      '/groups',
      query: {
        'include': 'category',
        'sort': scope == GroupScope.newest ? '-createdAt' : '-membersCount',
        if (scope == GroupScope.featured) 'filter[featured]': 'true',
        if (text.isNotEmpty) 'filter[query]': text,
        'filter[category]': ?categoryId,
        'page[limit]': '$_pageSize',
        'page[offset]': offset,
      },
    );
    final doc = JsonApi(res);
    final groups = [for (final n in doc.data) _group(n, doc)];
    final ranks = await _ranks([for (final g in groups) g.id]);
    for (final g in groups) {
      final rank = ranks[g.id];
      g
        ..isMember = rank != null
        ..rank = rank;
    }
    return GroupPage(_visible(groups), hasNext: doc.next != null);
  }

  List<GroupCategory>? _categories;

  @override
  Future<List<GroupCategory>> groupCategories() async {
    final cached = _categories;
    if (cached != null) return cached;
    final res = await _client.get(
      '/group-categories',
      query: {'sort': 'name', 'page[limit]': '20'},
    );
    return _categories = [
      for (final n in JsonApi(res).data)
        GroupCategory('${n['id']}', attrs(n)['name'] as String? ?? ''),
    ];
  }

  @override
  Future<SocialGroup?> group(String idOrSlug) async {
    final numeric = int.tryParse(idOrSlug) != null;
    final (res, early) = await (
      _client.get(
        numeric ? '/groups/$idOrSlug' : '/groups',
        query: {
          'include': 'category',
          if (!numeric) 'filter[slug]': idOrSlug,
          if (!numeric) 'page[limit]': '1',
        },
      ),
      numeric ? _ranks([idOrSlug]) : Future.value(const <String, String>{}),
    ).wait;
    final doc = JsonApi(res);
    if (doc.data.isEmpty) return null;
    final group = _group(doc.data.first, doc);
    final ranks = numeric ? early : await _ranks([group.id]);
    final rank = ranks[group.id];
    return group
      ..isMember = rank != null
      ..rank = rank;
  }

  @override
  Future<UserPage> groupMembers(String groupId, {int page = 1}) async {
    final res = await _client.get(
      '/group-members',
      query: {
        'filter[group]': groupId,
        'include': 'user',
        'page[limit]': '$_pageSize',
        'page[offset]': '${(page - 1) * _pageSize}',
      },
    );
    final doc = JsonApi(res);
    return UserPage([
      for (final m in doc.data)
        if (doc.one(m, 'user') case final u?) _brief(u),
    ], hasNext: doc.next != null);
  }

  @override
  Future<ActivityPage> groupPosts(String groupId, {int page = 1}) =>
      _feed('group/$groupId', 'group$groupId', page);

  Future<String?> _membershipId(String groupId) async {
    final me = currentUserId;
    if (me == null) return null;
    final res = await _client.get(
      '/group-members',
      query: {'filter[group]': groupId, 'filter[user]': me, 'page[limit]': '1'},
    );
    final data = JsonApi(res).data;
    return data.isEmpty ? null : '${data.first['id']}';
  }

  @override
  Future<bool?> toggleGroup(SocialGroup group) async {
    final me = currentUserId;
    if (me == null) return null;
    try {
      if (group.isMember) {
        final id = await _membershipId(group.id);
        if (id != null) await _client.delete('/group-members/$id');
        return false;
      }
      await _client.post('/group-members', {
        'data': {
          'type': 'groupMembers',
          'relationships': {
            'group': {
              'data': {'type': 'groups', 'id': group.id},
            },
            'user': {
              'data': {'type': 'users', 'id': me},
            },
          },
        },
      });
      return true;
    } catch (e, st) {
      logError('Social', e, st);
      return null;
    }
  }

  @override
  Future<bool> postToGroup(String groupId, String text, {String? edit}) async {
    final me = currentUserId;
    if (me == null) return false;
    try {
      if (edit != null) return await postActivity(text, edit: edit);
      await _client.post('/posts', {
        'data': {
          'type': 'posts',
          'attributes': {'content': text},
          'relationships': {
            'user': {
              'data': {'type': 'users', 'id': me},
            },
            'targetGroup': {
              'data': {'type': 'groups', 'id': groupId},
            },
          },
        },
      });
      return true;
    } catch (e, st) {
      logError('Social', e, st);
      return false;
    }
  }
}
