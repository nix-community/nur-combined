import 'package:flutter/material.dart';

import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../../../Widgets/Components/AppSheet.dart';
import '../../../Widgets/Components/CustomBottomDialog.dart';

Future<String?> showReactionComposer(BuildContext context, int limit) =>
    showCustomBottomDialog<String>(context, _ReactionComposer(limit: limit));

class _ReactionComposer extends StatefulWidget {
  final int limit;

  const _ReactionComposer({required this.limit});

  @override
  State<_ReactionComposer> createState() => _ReactionComposerState();
}

class _ReactionComposerState extends State<_ReactionComposer> {
  final _controller = TextEditingController();
  final _empty = true.live;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => _empty.value = _controller.text.trim().isEmpty,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppSheet(
    title: getString.reactionsAdd,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        Dimens.pagePad,
        0,
        Dimens.pagePad,
        Dimens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: widget.limit,
            maxLines: 3,
            minLines: 2,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(hintText: getString.reactionsHint),
          ),
          SizedBox(height: Dimens.gapSm),
          Watch(
            () => FilledButton(
              onPressed: _empty.value
                  ? null
                  : () => popPage(context, _controller.text.trim()),
              child: Text(getString.reactionsPost),
            ),
          ),
        ],
      ),
    ),
  );
}
