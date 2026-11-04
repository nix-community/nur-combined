import '../../Utils/Animation/WidgetAnimations.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/Services/MediaService.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Core/ThemeManager/ThemeController.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../Feed/FeedNavigation.dart';
import '../Social/SocialNavigation.dart';
import 'Components/EntityHeader.dart';

class EntityState extends ScreenState {
  final EntityScreenView view;
  final EntityKind kind;
  final String id;
  final String? name;
  final String? image;

  EntityState({
    required this.view,
    required this.kind,
    required this.id,
    this.name,
    this.image,
  });

  late final EntityHost host;
  final widgets = <ScreenWidget>[].liveList;
  final ready = false.live;
  final error = Live<String?>(null);
  final toggling = false.live;
  final spoilerNames = false.live;
  final scroll = ScrollController();
  Timer? _snapTimer;

  MediaService get service => view.service;

  String? get glassImage => host.profile.value.image;

  DiscordPresence get presence =>
      DiscordPresence.browsing('Viewing a ${kind.name}', state: name);

  @override
  void onInit() {
    host = EntityHost(
      kind: kind,
      profile: EntityProfile(id: id, name: name ?? '', image: image),
      loading: true.live,
      openMedia: (m) => openDetail(context, service, m),
      openCharacter: (id, {name, image}) => openEntity(
        context,
        service,
        EntityKind.character,
        id,
        name: name,
        image: image,
      ),
      openStaff: (id, {name, image}) => openEntity(
        context,
        service,
        EntityKind.staff,
        id,
        name: name,
        image: image,
      ),
      search: (q) => openSearch(context, service, query: q),
    );
    scroll.addListener(_scheduleSnap);
    find<ThemeController>().cover
      ..set(this, host.profile.value.image)
      ..track(this, context);
    unawaited(load());
  }

  @override
  void onClose() {
    _snapTimer?.cancel();
    scroll.dispose();
    find<ThemeController>().cover.clear(this);
  }

  void _scheduleSnap() {
    _snapTimer?.cancel();
    _snapTimer = Timer(const Duration(milliseconds: 140), _snapHeader);
  }

  void _snapHeader() {
    if (!mounted || !scroll.hasClients) return;
    final position = scroll.position;
    if (position.isScrollingNotifier.value) return _scheduleSnap();
    const range = EntityHeaderDelegate.collapseRange;
    final pixels = position.pixels;
    if (pixels <= 0 || pixels >= range) return;
    unawaited(
      scroll.animateTo(
        pixels < range / 2 ? 0 : range,
        duration: animDuration(180),
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> load() async {
    host.loading.value = true;
    error.value = null;
    try {
      await for (final list in view.screenStream(host)) {
        widgets.value = list;
        final image = host.profile.value.image;
        if (image != null) find<ThemeController>().cover.set(this, image);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      host.loading.value = false;
      ready.value = true;
    }
  }

  Future<void> toggleFavourite() async {
    toggling.value = true;
    try {
      final next = await view.toggleFavourite(
        kind,
        id,
        host.profile.value.isFavourite,
      );
      if (next == null) {
        snackString(getString.logInToFavourite);
        return;
      }
      final profile = host.profile.value;
      final count = profile.favourites;
      host.update(
        profile.copyWith(
          isFavourite: next,
          favourites: count == null ? null : count + (next ? 1 : -1),
        ),
      );
    } catch (e) {
      snackString('$e');
    } finally {
      toggling.value = false;
    }
  }

  void toggleSpoilerNames() => spoilerNames.value = !spoilerNames.value;

  void openLink(String url) => openAppLink(context, service, url);
}
