import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Utils/Extensions/Responsive.dart';
import '../../../Widgets/Components/SectionCard.dart';

class ProfileSkeleton extends StatelessWidget {
  final int blocks;
  final bool chart;

  const ProfileSkeleton({super.key, this.blocks = 3, this.chart = false});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: Dimens.gapSm, bottom: Dimens.gapXl),
      children: [
        for (var i = 0; i < blocks; i++)
          SectionCard(
            title: 'Section title',
            margin: EdgeInsets.symmetric(
              horizontal: Dimens.pagePad,
              vertical: Dimens.gapSm / 2,
            ),
            child: chart && i == 0
                ? const Bone.square(size: 120)
                : const Bone.multiText(lines: 3),
          ),
      ],
    ),
  );
}
