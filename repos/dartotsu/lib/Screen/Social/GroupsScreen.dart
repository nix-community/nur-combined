import '../../Utils/Animation/WidgetAnimations.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/AppControls.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import 'Components/GroupCard.dart';
import 'GroupsState.dart';

class GroupsScreen extends StatefulWidget {
  final MediaService service;

  const GroupsScreen({super.key, required this.service});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends BaseScreen<GroupsScreen>
    with ScreenStateHost<GroupsScreen, GroupsState> {
  @override
  GroupsState buildState() => GroupsState(widget.service);

  @override
  Widget buildContent(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppScreenBar(title: getString.groups),
    body: Watch(() => _body(context)),
  );

  Widget _body(BuildContext context) {
    final scheme = context.colorScheme;
    final joined = state.scope.value == GroupScope.joined;
    final skeleton = state.first.value && state.loading.value;
    final items = state.items.toList();
    final signedOutJoined = joined && !widget.service.isLoggedIn;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            Dimens.pagePad,
            Dimens.gapSm,
            Dimens.pagePad,
            Dimens.gapXs,
          ),
          child: TextField(
            controller: state.controller,
            onChanged: state.onTerm,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: getString.groupsSearch,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        if (state.view.groupScopes.length > 1)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.pagePad,
              vertical: Dimens.gapXs,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppChoiceChips<GroupScope>(
                value: state.scope.value,
                onChanged: state.setScope,
                options: [
                  AppSegment(GroupScope.joined, label: getString.groupsYours),
                  AppSegment(
                    GroupScope.popular,
                    label: getString.groupsPopular,
                  ),
                  AppSegment(GroupScope.newest, label: getString.groupsNew),
                  AppSegment(
                    GroupScope.featured,
                    label: getString.groupsFeatured,
                  ),
                ],
              ),
            ),
          ),
        if (!joined && state.categories.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: Dimens.pagePad),
              children: [
                for (final c in [null, ...state.categories])
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: Dimens.gapSm),
                    child: FilterChip(
                      label: Text(c?.name ?? getString.groupsAll),
                      selected: state.category.value == c?.id,
                      showCheckmark: false,
                      onSelected: (_) => state.setCategory(c?.id),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: signedOutJoined
              ? EmptyState(
                  icon: Icons.lock_outline_rounded,
                  title: getString.groupsSignIn,
                )
              : state.failed.value && items.isEmpty
              ? EmptyState(
                  icon: Icons.cloud_off_rounded,
                  failed: true,
                  title: getString.groupsCouldntLoad,
                  actionLabel: getString.retry,
                  onAction: () => state.load(reset: true),
                )
              : !skeleton && items.isEmpty && !state.loading.value
              ? EmptyState(
                  icon: Icons.groups_rounded,
                  title: joined
                      ? getString.groupsEmptyYours
                      : getString.groupsEmpty,
                )
              : RefreshIndicator(
                  onRefresh: () => state.load(reset: true),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: state.onScroll,
                    child: ScrollConfig(
                      context,
                      child: Skeletonizer(
                        enabled: skeleton,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            Dimens.pagePad,
                            Dimens.gapSm,
                            Dimens.pagePad,
                            120,
                          ),
                          itemCount: skeleton
                              ? 6
                              : items.length + (state.loading.value ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              SizedBox(height: Dimens.gapSm),
                          itemBuilder: (context, i) {
                            if (skeleton) {
                              return GroupCard(
                                group: GroupsState.placeholder,
                                skeleton: true,
                              );
                            }
                            if (i >= items.length) {
                              return Padding(
                                padding: EdgeInsets.all(Dimens.pagePad),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: scheme.primary,
                                  ),
                                ),
                              );
                            }
                            final card = GroupCard(
                              key: ValueKey(items[i].id),
                              group: items[i],
                              onTap: () => state.open(items[i]),
                            );
                            return i < 10 ? card.animateStagger(i) : card;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
