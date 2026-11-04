part of '../Mutations.dart';

extension AnilistFavourite on AnilistMutations {
  Future<bool?> _toggleFavourite(Media media) async {
    final id = int.tryParse(media.id);
    if (id == null) return null;
    final (arg, field) = media.isAnime
        ? ('animeId', 'anime')
        : ('mangaId', 'manga');
    try {
      final data = await client.query(
        'mutation (\$id: Int) { ToggleFavourite($arg: \$id) { $field(page: 1, perPage: 1) { pageInfo { total } } } }',
        variables: {'id': id},
      );
      return data['ToggleFavourite'] == null ? null : !media.isFav;
    } on AnilistException catch (e) {
      snackString(e.message);
      return null;
    }
  }
}
