import 'package:flutter/material.dart';

import '../../../Core/Services/MediaService.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Widgets/Components/ProfileCard.dart';

String groupRoleLabel(SocialGroup group) => switch (group.rank) {
  'admin' => getString.groupsRoleAdmin,
  'mod' => getString.groupsRoleMod,
  _ => getString.groupsJoined,
};

String groupPrivacyLabel(String privacy) => switch (privacy) {
  'restricted' => getString.groupsPrivacyRestricted,
  'closed' => getString.groupsPrivacyClosed,
  _ => getString.groupsPrivacyOpen,
};

class GroupCard extends StatelessWidget {
  final SocialGroup group;
  final VoidCallback? onTap;
  final bool skeleton;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
    this.skeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return ProfileCard(
      name: group.name,
      avatar: group.avatar,
      banner: group.cover ?? group.avatar,
      skeleton: skeleton,
      wide: true,
      onTap: onTap,
      chip: group.isMember
          ? ProfilePill(groupRoleLabel(group), color: scheme.primary)
          : group.nsfw
          ? ProfilePill(getString.groupsAdult, color: scheme.error)
          : null,
      meta: Text(
        [
          if (group.members >= 0) getString.groupsMembersCount(group.members),
          if (group.category != null) group.category!,
          if (!group.isOpen) groupPrivacyLabel(group.privacy),
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
