import 'package:flutter/material.dart';

import '../../../../Utils/Function.dart';
import '../../../../Widgets/Components/AniHtml.dart';
import '../../../../Widgets/Components/Clickable.dart';
import '../CommentMarkup.dart';

class CommentText extends StatelessWidget {
  final String text;
  final VoidCallback? onLongPress;

  const CommentText({super.key, required this.text, this.onLongPress});

  @override
  Widget build(BuildContext context) => Clickable(
    press: false,
    behavior: HitTestBehavior.deferToChild,
    onLongPress: onLongPress,
    child: AniHtml(
      html: commentHtml(text),
      onLink: (url) => openLinkInBrowser(url),
    ),
  );
}
