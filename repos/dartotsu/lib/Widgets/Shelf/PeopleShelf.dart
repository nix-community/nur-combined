import 'package:flutter/material.dart';

import '../../Core/Services/Model/Author.dart';
import '../../Core/Services/Model/Character.dart';
import '../../Core/ThemeManager/CardStyleController.dart';
import '../../Model/CardStyle.dart';
import 'CardShelf.dart';
import 'CardShelfState.dart';
import '../../Core/State/State.dart';

class ShelfPerson {
  final String? image;
  final String name;
  final String? role;
  final Object? tag;

  const ShelfPerson({required this.name, this.image, this.role, this.tag});
}

class PeopleShelf extends StatelessWidget {
  final String title;
  final List<ShelfPerson> people;
  final void Function(ShelfPerson person)? onTap;

  const PeopleShelf({
    super.key,
    required this.title,
    required this.people,
    this.onTap,
  });

  static String? heroTagOf(Object? tag) => switch (tag) {
    Character c when c.id.isNotEmpty => 'person:character:${c.id}',
    Author a when a.id.isNotEmpty => 'person:staff:${a.id}',
    _ => null,
  };

  ShelfCardItem _toItem(ShelfPerson p, Set<String> seen) {
    final hero = heroTagOf(p.tag);
    return ShelfCardItem(
      id: '${p.tag ?? ''}${p.name}',
      heroTag: hero != null && seen.add(hero) ? hero : null,
      imageUrl: p.image,
      title: p.name,
      subtitle: p.role,
      onTap: onTap == null ? null : () => onTap!(p),
      focusable: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final seen = <String>{};
    final style = (tryFind<CardStyleController>()?.current ?? CardStyle.cozy)
        .copyWith(preset: 'people');
    return CardShelf(
      title: title,
      items: [for (final p in people) _toItem(p, seen)],
      dataKey: people,
      styleOverride: style,
    );
  }
}
