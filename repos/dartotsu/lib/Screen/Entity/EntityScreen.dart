import 'dart:async';

import 'package:flutter/material.dart';

import '../Share/ShareCard.dart';
import '../Share/ShareCardSheet.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/ThemeManager/ThemeController.dart';
import '../../Utils/Animation/WidgetAnimations.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../../Widgets/Components/AniHtml.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import '../../Widgets/Shelf/MediaSection.dart';
import '../Social/Components/AniMediaCard.dart';
import '../Widgets/Components/DataSection.dart';
import '../Widgets/ScreenWidgetView.dart';
import 'Components/EntityHeader.dart';
import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'EntityState.dart';

class EntityScreen extends StatefulWidget {
  final EntityScreenView view;
  final EntityKind kind;
  final String id;
  final String? name;
  final String? image;

  const EntityScreen({
    super.key,
    required this.view,
    required this.kind,
    required this.id,
    this.name,
    this.image,
  });

  @override
  State<EntityScreen> createState() => _EntityScreenState();
}

class _EntityScreenState extends BaseScreen<EntityScreen>
    with ScreenStateHost<EntityScreen, EntityState> {
  @override
  bool get safeArea => false;

  @override
  EntityState buildState() => EntityState(
    view: widget.view,
    kind: widget.kind,
    id: widget.id,
    name: widget.name,
    image: widget.image,
  );

  @override
  String? get glassBackgroundUrl =>
      state.glassImage ?? super.glassBackgroundUrl;

  @override
  DiscordPresence? get presence => state.presence;

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: state.load,
        child: ScrollConfig(
          context,
          child: Watch(
            () => CustomScrollView(
              controller: state.scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: EntityHeaderDelegate(
                    host: state.host,
                    top: MediaQuery.paddingOf(context).top,
                    glass: find<ThemeController>().useGlassMode.value,
                    canFavourite: state.view.canFavourite(state.kind),
                    togglingFavourite: state.toggling,
                    onToggleFavourite: state.toggleFavourite,
                    onShareCard: () {
                      final profile = state.host.profile.value;
                      unawaited(
                        showShareWidget(
                          context,
                          state.view.service,
                          card: EntityShareCard(
                            profile: profile,
                            service: state.view.service.name,
                          ),
                          fileName: profile.name,
                          link: profile.url,
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(child: Watch(() => _body(context))),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final profile = state.host.profile.value;
    final widgets = state.widgets.toList();
    final loadingFirst = !state.ready.value && widgets.isEmpty;
    final failed =
        state.error.value != null && widgets.isEmpty && !loadingFirst;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Dimens.gapLg),
        if (profile.tags.isNotEmpty)
          _section(
            'tags',
            0,
            DataSection(data: ScreenData(chips: profile.tags)),
          ),
        if (profile.facts.isNotEmpty)
          _section(
            'facts',
            1,
            DataSection(
              title: getString.details,
              data: ScreenData(rows: profile.facts),
            ),
          ),
        if (profile.alternatives.isNotEmpty ||
            profile.spoilerAlternatives.isNotEmpty)
          _section('names', 2, _names(context, profile)),
        if (profile.description?.trim().isNotEmpty ?? false)
          _section('about', 3, _about(context, profile.description!)),
        if (loadingFirst)
          for (var i = 0; i < 2; i++)
            const MediaSection(data: MediaSectionData.loading()),
        for (var i = 0; i < widgets.length; i++) ..._item(widgets[i], i),
        if (failed)
          SizedBox(
            height: 340,
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              failed: true,
              title: getString.couldntLoadPage,
              message: state.error.value,
              onAction: state.load,
            ),
          ),
      ],
    );
  }

  List<Widget> _item(ScreenWidget item, int index) => [
    SizedBox(height: Dimens.gapLg),
    _slide(
      'item-${item.title ?? index}',
      index + 4,
      ScreenWidgetView(
        item,
        heroPrefix: 'entity:${widget.id}',
        onMediaTap: (media, _) => state.host.openMedia(media),
        onCharacterTap: (c) =>
            state.host.openCharacter(c.id, name: c.name, image: c.image),
        onStaffTap: (s) =>
            state.host.openStaff(s.id, name: s.name, image: s.image),
      ),
    ),
  ];

  Widget _slide(String key, int index, Widget child) => KeyedSubtree(
    key: ValueKey(key),
    child: child.animateFadeUp(
      begin: 0.06,
      delay: Duration(milliseconds: 40 * index),
      duration: 350,
    ),
  );

  Widget _section(String key, int index, Widget child) => _slide(
    key,
    index,
    Padding(
      padding: EdgeInsets.only(bottom: Dimens.gapLg),
      child: child,
    ),
  );

  Widget _about(BuildContext context, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.pagePad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getString.about,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: Dimens.gapSm),
          SelectionArea(
            child: AniHtml(
              html: description,
              collapsedHeight: 240,
              onLink: state.openLink,
              linkCard: aniLinkCards(state.service),
            ),
          ),
        ],
      ),
    );
  }

  Widget _names(BuildContext context, EntityProfile profile) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profile.alternatives.isNotEmpty)
          DataSection(
            title: getString.alsoKnownAs,
            data: ScreenData(chips: profile.alternatives),
          ),
        if (profile.spoilerAlternatives.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.pagePad),
            child: Watch(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      foregroundColor: scheme.onSurfaceVariant,
                    ),
                    onPressed: state.toggleSpoilerNames,
                    icon: Icon(
                      state.spoilerNames.value
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 18,
                    ),
                    label: Text(
                      state.spoilerNames.value
                          ? getString.hideSpoilerNames
                          : getString.showSpoilerNames,
                    ),
                  ),
                  if (state.spoilerNames.value)
                    DataSection(
                      data: ScreenData(chips: profile.spoilerAlternatives),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
