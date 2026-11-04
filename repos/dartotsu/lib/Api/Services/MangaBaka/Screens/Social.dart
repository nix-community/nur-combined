import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../Core/Services/MediaService.dart';
import '../../../../Core/Services/Model/Media.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Model/Setting.dart';
import '../../../../Utils/Function.dart';
import '../../../../Utils/Functions/SnackBar.dart';
import '../../../../Screen/MangaBaka/StacksScreen.dart';
import '../../../../Utils/Functions/NavigateToScreen.dart';
import '../Auth.dart';
import '../Data/User.dart';

class MangaBakaSocialView extends SocialScreenView {
  MangaBakaSocialView(super.service);

  @override
  bool get hasActivity => false;

  @override
  bool get hasGlobalFeed => false;

  @override
  bool get hasFollows => false;

  @override
  String? profileUrl(String name) {
    final user = mangaBakaAuth.user.value;
    return user is MangaBakaUser ? user.profileUrl : 'https://mangabaka.org/';
  }

  @override
  AccountOptions? get accountOptions =>
      AccountOptions(title: getString.mangaBakaAccountOptions, build: _options);

  bool _mine(String? id) {
    final me = currentUserId;
    return me != null && (id == null || id == me);
  }

  String? _text(Map<String, dynamic> raw, List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  @override
  Future<SocialUser?> profile({String? id, String? name}) async {
    final user = mangaBakaAuth.user.value;
    if (user is! MangaBakaUser || !_mine(id)) return null;
    if (mangaBakaAuth.rawProfile.value.isEmpty) {
      await mangaBakaAuth.refreshUser();
    }
    final raw = mangaBakaAuth.rawProfile.value;
    final library = await mangaBakaAuth.queries.library();
    final scored = [
      for (final m in library)
        if ((m.userScore ?? 0) > 0) m.userScore!,
    ];
    return SocialUser(
      id: user.id.toString(),
      name: user.name,
      avatar: user.avatar,
      banner: _text(raw, ['banner', 'banner_url', 'cover']),
      about: _text(raw, ['bio', 'about', 'description', 'biography']),
      siteUrl: user.profileUrl,
      mangaCount: library.length,
      chaptersRead: _chapters(library),
      mangaMeanScore: scored.isEmpty
          ? 0
          : scored.reduce((a, b) => a + b) / scored.length,
    );
  }

  int _chapters(List<Media> library) =>
      library.fold(0, (sum, m) => sum + (m.userProgress ?? 0));

  @override
  Future<UserStats?> stats(String userId) async {
    if (!_mine(userId)) return null;
    final library = await mangaBakaAuth.queries.library();
    final scored = [
      for (final m in library)
        if ((m.userScore ?? 0) > 0) m.userScore!,
    ];
    final labels = {
      'CURRENT': getString.reading,
      'PLANNING': getString.planning,
      'COMPLETED': getString.completed,
      'PAUSED': getString.paused,
      'DROPPED': getString.dropped,
      'REPEATING': getString.rereading,
    };
    final entries = [
      for (final e in labels.entries)
        if (library.where((m) => m.userStatus == e.key).isNotEmpty)
          StatEntry(
            label: e.value,
            count: library.where((m) => m.userStatus == e.key).length,
            chaptersRead: library
                .where((m) => m.userStatus == e.key)
                .fold(0, (sum, m) => sum + (m.userProgress ?? 0)),
          ),
    ];
    return UserStats(
      anime: const UserStatSet(),
      manga: UserStatSet(
        count: library.length,
        chaptersRead: _chapters(library),
        meanScore: scored.isEmpty
            ? 0
            : scored.reduce((a, b) => a + b) / scored.length,
        categories: entries.isEmpty
            ? const []
            : [StatCategory('statuses', getString.status, entries)],
      ),
    );
  }

  List<Setting> _options(BuildContext context) {
    final user = mangaBakaAuth.user.value;
    final raw = mangaBakaAuth.rawProfile.value;
    if (user is! MangaBakaUser) return const [];
    if (raw.isEmpty) unawaited(mangaBakaAuth.refreshUser());
    final shown = raw.entries.where(
      (e) => e.value is String || e.value is num || e.value is bool,
    );
    return [
      Setting.header(getString.account),
      Setting.normal(
        name: getString.mangaBakaProfile,
        description: user.name,
        icon: Icons.person_outline_rounded,
        onClick: () => openLinkInBrowser(user.profileUrl),
      ),
      Setting.normal(
        name: getString.stacks,
        icon: Icons.collections_bookmark_rounded,
        isActivity: true,
        onClick: () => navigateToPage(context, const StacksScreen()),
      ),
      Setting.normal(
        name: getString.ratingSteps,
        description: '${user.ratingSteps}',
        icon: Icons.star_rounded,
      ),
      if (shown.isNotEmpty) Setting.header(getString.accountDetails),
      for (final e in shown)
        if (!const {'id', 'rating_steps', 'nickname'}.contains(e.key))
          Setting.normal(
            name: _label(e.key),
            description: '${e.value}',
            icon: Icons.info_outline_rounded,
          ),
      Setting.normal(
        name: getString.refreshFromMangaBaka,
        description: getString.repullProfileCounts,
        icon: Icons.refresh_rounded,
        onClick: () async {
          mangaBakaAuth.queries.resyncLibrary();
          await mangaBakaAuth.refreshUser();
          snackString(getString.refreshed);
        },
      ),
    ];
  }

  String _label(String key) {
    final words = key.replaceAll('_', ' ').trim();
    return words.isEmpty ? key : words[0].toUpperCase() + words.substring(1);
  }
}
