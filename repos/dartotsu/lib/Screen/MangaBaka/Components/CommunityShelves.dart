import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Api/Services/MangaBaka/Auth.dart';
import '../../../Api/Services/MangaBaka/Community.dart';
import '../../../Api/Services/MangaBaka/Data/Community.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Logger.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../../../Widgets/Shelf/ShelfFrame.dart';
import '../StackScreen.dart';
import '../StacksScreen.dart';
import 'StackCard.dart';

class CommunityShelves extends StatefulWidget {
  const CommunityShelves({super.key});

  @override
  State<CommunityShelves> createState() => _CommunityShelvesState();
}

class _CommunityShelvesState extends State<CommunityShelves> {
  late final Future<StackPage> _stacks = _load(() async {
    final community = mangaBakaAuth.community;
    final featured = await community.stacks(StackScope.featured);
    return featured.items.isEmpty
        ? community.stacks(StackScope.all)
        : featured;
  });

  Future<T> _load<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e, st) {
      logError('CommunityShelves', e, st);
      rethrow;
    }
  }

  void _open(BuildContext context) =>
      unawaited(navigateToPage(context, const StacksScreen()));

  @override
  Widget build(BuildContext context) => Column(
    children: [
      FutureBuilder<StackPage>(
        future: _stacks,
        builder: (context, snap) {
          final items = snap.data?.items ?? const <MangaBakaStack>[];
          if (snap.hasError || (snap.hasData && items.isEmpty)) {
            return const SizedBox.shrink();
          }
          final loading = !snap.hasData;
          final shown = loading
              ? List.filled(3, MangaBakaStack.placeholder)
              : items;
          return ShelfFrame(
            title: getString.stacks,
            trailing: loading
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: () => _open(context),
                  ),
            onTitleTap: loading ? null : () => _open(context),
            onHeaderSelect: loading ? null : () => _open(context),
            child: Skeletonizer(
              enabled: loading,
              child: SizedBox(
                height: 148,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: Dimens.gap),
                  itemCount: shown.length,
                  separatorBuilder: (_, _) => SizedBox(width: Dimens.gapSm),
                  itemBuilder: (context, i) => SizedBox(
                    width: 300,
                    child: StackCard(
                      stack: shown[i],
                      onTap: loading
                          ? null
                          : () => navigateToPage(
                              context,
                              StackScreen(stack: shown[i]),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}
