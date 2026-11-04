import '../../../Core/Services/Model/Media.dart';
import '../../../Core/Services/Model/News.dart';
import 'Client.dart';
import 'Data/Community.dart';
import 'Data/Mapper.dart';
import 'Prefs.dart';

enum StackScope { all, featured, mine, saved, following }

class MangaBakaCommunity {
  final MangaBakaClient client;

  MangaBakaCommunity(this.client);

  static const pageSize = 20;

  bool get _hide => MangaBakaPref.hideNsfw.value;

  Future<StackPage> stacks(StackScope scope, {int page = 1}) async {
    final path = switch (scope) {
      StackScope.mine => '/v2/my/stacks',
      StackScope.saved => '/v2/my/stacks/saved',
      StackScope.following => '/v2/my/stacks/followed',
      _ => '/v2/stacks',
    };
    final body = await client.get(
      path,
      query: {
        'limit': '$pageSize',
        'page': '$page',
        if (scope == StackScope.featured) 'featured': 'true',
      },
      cache: const Duration(minutes: 2),
    );
    return _visible(parseStackPage(body));
  }

  Future<StackPage> userStacks(String username, {int page = 1}) async {
    final body = await client.get(
      '/v2/users/${Uri.encodeComponent(username)}/stacks',
      query: {'limit': '$pageSize', 'page': '$page'},
      cache: const Duration(minutes: 2),
    );
    return _visible(parseStackPage(body));
  }

  StackPage _visible(StackPage page) => StackPage([
    for (final s in page.items)
      if (!(_hide && s.adult)) s,
  ], page.hasNext);

  Future<MangaBakaStack> stack(int id) async {
    final body = await client.get(
      '/v2/stacks/$id',
      cache: const Duration(minutes: 2),
    );
    final data = body['data'];
    if (data is! Map) throw MangaBakaException('Stack not found', 404);
    final stack = parseStack(data.cast<String, dynamic>());
    if (!_hide) return stack;
    return MangaBakaStack(
      id: stack.id,
      title: stack.title,
      url: stack.url,
      kind: stack.kind,
      visibility: stack.visibility,
      contentRating: stack.contentRating,
      spoiler: stack.spoiler,
      featured: stack.featured,
      owner: stack.owner,
      entryCount: stack.entryCount,
      voteCount: stack.voteCount,
      saveCount: stack.saveCount,
      covers: stack.covers,
      description: stack.description,
      entries: [
        for (final e in stack.entries)
          if (!e.media.isAdult) e,
      ],
    );
  }

  Future<void> setSaved(int id, {required bool saved}) async {
    final path = '/v2/my/stacks/saved/$id';
    if (saved) {
      await client.write('PUT', path, const {});
    } else {
      await client.delete(path);
    }
  }

  Future<NewsPage> news({int page = 1}) async {
    final body = await client.get(
      '/news',
      query: {'limit': '$pageSize', 'page': '$page'},
      cache: const Duration(minutes: 10),
    );
    return parseNewsPage(body);
  }

  Future<List<Media>> rising({int limit = pageSize}) async {
    final body = await client.get(
      '/v2/series/discover/rising',
      query: {'limit': '${limit.clamp(1, 20)}'},
      cache: const Duration(minutes: 10),
    );
    final seen = <String>{};
    return [
      for (final s in (body['data'] as List?) ?? const [])
        if (s is Map && seen.add('${s['id']}'))
          ?_shown(mapMangaBakaSeries(s.cast<String, dynamic>())),
    ];
  }

  Media? _shown(Media media) => _hide && media.isAdult ? null : media;
}
