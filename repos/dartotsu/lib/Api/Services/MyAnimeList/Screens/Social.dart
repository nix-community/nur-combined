import '../../../../Core/Services/MediaService.dart';
import '../Auth.dart';
import '../Client.dart';

const _pageSize = 25;

class MalSocialView extends SocialScreenView {
  MalSocialView(super.service);

  MalClient get _client => malAuth.client;

  List<SocialGroup>? _boards;

  @override
  String? profileUrl(String name) => 'https://myanimelist.net/profile/$name';

  @override
  Future<SocialUser?> profile({String? id, String? name}) async {
    final me = service.auth?.user.value;
    if (me == null || (id != '${me.id}' && name != me.name)) return null;
    return SocialUser(
      id: '${me.id}',
      name: me.name,
      avatar: me.avatar,
      banner: me.banner,
      siteUrl: profileUrl(me.name),
      episodesWatched: me.episodesWatched,
      chaptersRead: me.chaptersRead,
    );
  }

  @override
  bool get hasActivity => false;

  @override
  bool get hasFollows => false;

  @override
  bool get hasGlobalFeed => false;

  @override
  bool get canInteract => false;

  @override
  bool get hasGroups => true;

  @override
  bool get hasGroupMembers => false;

  @override
  List<GroupScope> get groupScopes => const [GroupScope.popular];

  Future<List<SocialGroup>> _loadBoards() async {
    final cached = _boards;
    if (cached != null) return cached;
    final body = await _client.get('/forum/boards');
    final out = <SocialGroup>[];
    for (final c in (body['categories'] as List? ?? const [])) {
      if (c is! Map) continue;
      final category = c['title'] as String?;
      for (final b in (c['boards'] as List? ?? const [])) {
        if (b is! Map) continue;
        out.add(_board(b, category));
        for (final sub in (b['subboards'] as List? ?? const [])) {
          if (sub is Map) out.add(_board(sub, b['title'] as String?));
        }
      }
    }
    return _boards = out;
  }

  SocialGroup _board(Map b, String? category) => SocialGroup(
    id: '${b['id']}',
    name: b['title'] as String? ?? '',
    about: b['description'] as String?,
    category: category,
    members: -1,
    siteUrl: 'https://myanimelist.net/forum/?board=${b['id']}',
  );

  @override
  Future<GroupPage> groups(
    GroupScope scope, {
    String? query,
    String? categoryId,
    int page = 1,
  }) async {
    if (page > 1) return const GroupPage([]);
    final text = query?.trim().toLowerCase() ?? '';
    final boards = await _loadBoards();
    return GroupPage([
      for (final b in boards)
        if (text.isEmpty ||
            b.name.toLowerCase().contains(text) ||
            (b.category?.toLowerCase().contains(text) ?? false))
          b,
    ]);
  }

  @override
  Future<SocialGroup?> group(String idOrSlug) async {
    final boards = await _loadBoards();
    for (final b in boards) {
      if (b.id == idOrSlug) return b;
    }
    return null;
  }

  UserBrief _user(Object? node) {
    final m = node is Map ? node : const {};
    return UserBrief(
      id: '${m['id'] ?? 0}',
      name: m['name'] as String? ?? '',
      avatar: m['forum_avator'] as String?,
    );
  }

  static int _epoch(Object? iso) => iso is String
      ? (DateTime.tryParse(iso)?.millisecondsSinceEpoch ?? 0) ~/ 1000
      : 0;

  @override
  Future<ActivityPage> groupPosts(String groupId, {int page = 1}) async {
    final body = await _client.get(
      '/forum/topics',
      query: {
        'board_id': groupId,
        'limit': '$_pageSize',
        'offset': '${(page - 1) * _pageSize}',
      },
    );
    final data = body['data'] as List? ?? const [];
    return ActivityPage([
      for (final t in data)
        if (t is Map)
          Activity(
            id: '${t['id']}',
            kind: ActivityKind.text,
            user: _user(t['created_by']),
            text: t['title'] as String?,
            replyCount: (((t['number_of_posts'] as num?)?.toInt() ?? 1) - 1)
                .clamp(0, 1 << 30),
            isLocked: t['is_locked'] == true,
            createdAt: _epoch(t['created_at']),
            siteUrl: 'https://myanimelist.net/forum/?topicid=${t['id']}',
          ),
    ], hasNext: (body['paging'] as Map?)?['next'] != null);
  }

  @override
  Future<ReplyPage> replies(String activityId, {int page = 1}) async {
    final body = await _client.get(
      '/forum/topic/$activityId',
      query: {'limit': '$_pageSize', 'offset': '${(page - 1) * _pageSize}'},
    );
    final posts = ((body['data'] as Map?)?['posts'] as List?) ?? const [];
    return ReplyPage([
      for (final p in posts)
        if (p is Map)
          ActivityReply(
            id: '${p['id']}',
            activityId: activityId,
            user: _user(p['created_by']),
            text: _markup(p['body'] as String? ?? ''),
            createdAt: _epoch(p['created_at']),
          ),
    ], hasNext: (body['paging'] as Map?)?['next'] != null);
  }

  static String _markup(String raw) {
    var s = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll('\r', '')
        .replaceAllMapped(
          RegExp(r'\[url=([^\]]+)\](.*?)\[/url\]', dotAll: true),
          (m) => '[${m.group(2)}](${m.group(1)})',
        )
        .replaceAllMapped(
          RegExp(r'\[img[^\]]*\](.*?)\[/img\]', dotAll: true),
          (m) => 'img(${m.group(1)})',
        )
        .replaceAllMapped(
          RegExp(r'\[spoiler[^\]]*\](.*?)\[/spoiler\]', dotAll: true),
          (m) => '~!${m.group(1)}!~',
        )
        .replaceAllMapped(
          RegExp(r'\[b\](.*?)\[/b\]', dotAll: true),
          (m) => '**${m.group(1)}**',
        )
        .replaceAllMapped(
          RegExp(r'\[i\](.*?)\[/i\]', dotAll: true),
          (m) => '*${m.group(1)}*',
        )
        .replaceAllMapped(
          RegExp(r'\[quote[^\]]*\](.*?)\[/quote\]', dotAll: true),
          (m) => '> ${m.group(1)}'.replaceAll('\n', '\n> '),
        )
        .replaceAll(
          RegExp(r'\[/?[a-z]+(=[^\]]*)?\]', caseSensitive: false),
          '',
        );
    s = s
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');
    return s.trim();
  }
}
