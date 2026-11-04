import '../../../../Core/Services/MediaService.dart';
import '../../../../Core/Services/Model/Media.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../Auth.dart';
import '../Data/Mapper.dart';

class KitsuEntityView extends EntityScreenView {
  KitsuEntityView(super.service);

  @override
  Stream<List<ScreenWidget>> screenStream(EntityHost host) async* {
    final id = int.tryParse(host.profile.value.id);
    if (id == null) return;
    final queries = kitsuAuth.queries;
    switch (host.kind) {
      case EntityKind.character:
        final doc = await queries.entity('/characters/$id', {
          'include': 'mediaCharacters.media',
        });
        final node = doc?.data.firstOrNull;
        if (doc == null || node == null) return;
        host.update(_character(node));
        yield _characterWidgets(doc, node);
      case EntityKind.staff:
        final doc = await queries.entity('/people/$id', {
          'include':
              'voices.mediaCharacter.media,voices.mediaCharacter.character,'
              'staff.media',
        });
        final node = doc?.data.firstOrNull;
        if (doc == null || node == null) return;
        host.update(_person(node));
        yield _personWidgets(doc, node);
      case EntityKind.studio:
        final doc = await queries.entity('/producers/$id');
        final node = doc?.data.firstOrNull;
        if (node == null) return;
        host.update(_studio(node));
        final first = await _productions(id, 1);
        yield [
          if (first.isNotEmpty)
            ScreenWidget.media(
              getString.anime,
              first,
              onLoadMore: (page) => _productions(id, page),
            ),
        ];
    }
  }

  Future<List<Media>> _productions(int id, int page) async {
    final doc = await kitsuAuth.queries.entity(
      '/producers/$id/anime-productions',
      {
        'include': 'anime',
        'page[limit]': '20',
        'page[offset]': '${(page - 1) * 20}',
      },
    );
    if (doc == null) return const [];
    final seen = <String>{};
    return [
      for (final p in doc.data)
        if (doc.one(p, 'anime') case final anime?)
          if (seen.add('${anime['id']}')) mapKitsuMedia(anime),
    ];
  }

  EntityProfile _character(Map<String, dynamic> node) {
    final a = attrs(node);
    final names = (a['names'] as Map?)?.cast<String, dynamic>() ?? const {};
    final slug = a['slug'] as String? ?? '${node['id']}';
    return EntityProfile(
      id: '${node['id']}',
      name: (a['canonicalName'] ?? a['name'] ?? '') as String,
      nativeName: names['ja_jp'] as String?,
      alternatives: [
        for (final n in (a['otherNames'] as List?) ?? const [])
          if (n is String && n.isNotEmpty) n,
      ],
      image: kitsuImage(a['image']),
      url: 'https://kitsu.io/characters/$slug',
      description: kitsuHtml(a['description'] as String?),
    );
  }

  List<ScreenWidget> _characterWidgets(JsonApi doc, Map<String, dynamic> node) {
    final anime = <Media>[];
    final manga = <Media>[];
    final seen = <String>{};
    for (final mc in doc.many(node, 'mediaCharacters')) {
      final media = doc.one(mc, 'media');
      if (media == null || !seen.add('${media['type']}:${media['id']}')) {
        continue;
      }
      final m = mapKitsuMedia(media)..relation = _role(attrs(mc)['role']);
      (m.isAnime ? anime : manga).add(m);
    }
    return [
      if (anime.isNotEmpty)
        ScreenWidget.media(getString.animeAppearances, anime),
      if (manga.isNotEmpty)
        ScreenWidget.media(getString.mangaAppearances, manga),
    ];
  }

  EntityProfile _person(Map<String, dynamic> node) {
    final a = attrs(node);
    return EntityProfile(
      id: '${node['id']}',
      name: a['name'] as String? ?? '',
      image: kitsuImage(a['image']),
      url: 'https://kitsu.io/people/${a['slug'] ?? node['id']}',
      facts: [
        if ((a['birthday'] as String?)?.isNotEmpty ?? false)
          (getString.born, a['birthday'] as String),
        if ((a['website'] as String?)?.isNotEmpty ?? false)
          (getString.website, a['website'] as String),
      ],
      description: kitsuHtml(a['description'] as String?),
    );
  }

  List<ScreenWidget> _personWidgets(JsonApi doc, Map<String, dynamic> node) {
    final roles = <Media>[];
    final seenRoles = <String>{};
    for (final voice in doc.many(node, 'voices')) {
      final mc = doc.one(voice, 'mediaCharacter');
      final media = mc == null ? null : doc.one(mc, 'media');
      if (mc == null ||
          media == null ||
          !seenRoles.add('${media['type']}:${media['id']}')) {
        continue;
      }
      final character = doc.one(mc, 'character');
      final name = character == null
          ? null
          : (attrs(character)['canonicalName'] ?? attrs(character)['name']);
      roles.add(
        mapKitsuMedia(media)
          ..relation = [?name, ?_role(attrs(mc)['role'])].join(' · '),
      );
    }
    final anime = <Media>[];
    final manga = <Media>[];
    final seen = <String>{};
    for (final staff in doc.many(node, 'staff')) {
      final media = doc.one(staff, 'media');
      if (media == null || !seen.add('${media['type']}:${media['id']}')) {
        continue;
      }
      final m = mapKitsuMedia(media)
        ..relation = attrs(staff)['role'] as String?;
      (m.isAnime ? anime : manga).add(m);
    }
    return [
      if (roles.isNotEmpty) ScreenWidget.media(getString.voiceRoles, roles),
      if (anime.isNotEmpty) ScreenWidget.media(getString.staffPositions, anime),
      if (manga.isNotEmpty) ScreenWidget.media(getString.mangaWorks, manga),
    ];
  }

  EntityProfile _studio(Map<String, dynamic> node) {
    final a = attrs(node);
    return EntityProfile(
      id: '${node['id']}',
      name: a['name'] as String? ?? '',
      url: 'https://kitsu.io/anime/producer/${a['slug'] ?? node['id']}',
    );
  }

  String? _role(Object? role) {
    if (role is! String || role.isEmpty) return null;
    return '${role[0].toUpperCase()}${role.substring(1)}';
  }
}
