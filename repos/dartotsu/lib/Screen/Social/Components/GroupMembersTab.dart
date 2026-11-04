import '../../../Utils/Animation/WidgetAnimations.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Core/Services/MediaService.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Widgets/Components/EmptyState.dart';
import '../../../Widgets/Components/ScreenState.dart';
import '../../../Widgets/Components/ScrollConfig.dart';
import 'GroupMembersState.dart';
import 'UserCard.dart';

class GroupMembersTab extends StatefulWidget {
  final MediaService service;
  final String groupId;

  const GroupMembersTab({
    super.key,
    required this.service,
    required this.groupId,
  });

  @override
  State<GroupMembersTab> createState() => _GroupMembersTabState();
}

class _GroupMembersTabState extends State<GroupMembersTab>
    with
        AutomaticKeepAliveClientMixin,
        ScreenStateHost<GroupMembersTab, GroupMembersState> {
  @override
  GroupMembersState buildState() =>
      GroupMembersState(service: widget.service, groupId: widget.groupId);

  @override
  bool get wantKeepAlive => true;

  static final _placeholder = UserBrief(id: '0', name: 'Loading user name');

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Watch(() => _build(context));
  }

  Widget _build(BuildContext context) {
    final skeleton = state.first.value && state.loading.value;
    final users = state.users.toList();
    if (state.failed.value && users.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        failed: true,
        title: getString.groupsCouldntLoad,
        actionLabel: getString.retry,
        onAction: () => state.load(reset: true),
      );
    }
    if (!skeleton && users.isEmpty && !state.loading.value) {
      return EmptyState(
        icon: Icons.groups_rounded,
        title: getString.groupsEmpty,
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: state.onScroll,
      child: ScrollConfig(
        context,
        child: Skeletonizer(
          enabled: skeleton,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              Dimens.pagePad,
              Dimens.gapSm,
              Dimens.pagePad,
              120,
            ),
            itemCount: skeleton
                ? 6
                : users.length + (state.loading.value ? 1 : 0),
            separatorBuilder: (_, _) => SizedBox(height: Dimens.gapSm),
            itemBuilder: (context, i) {
              if (skeleton) {
                return UserCard(
                  service: widget.service,
                  user: _placeholder,
                  skeleton: true,
                  wide: true,
                );
              }
              if (i >= users.length) {
                return Padding(
                  padding: EdgeInsets.all(Dimens.pagePad),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final card = UserCard(
                key: ValueKey(users[i].id),
                service: widget.service,
                user: users[i],
                wide: true,
              );
              return i < 10 ? card.animateStagger(i) : card;
            },
          ),
        ),
      ),
    );
  }
}
