import 'package:flutter/material.dart';

import '../../../../Widgets/Components/CustomBottomDialog.dart';
import '../../../../Widgets/Components/AppSheet.dart';
import '../../../../Core/State/State.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Widgets/Components/ScreenState.dart';
import 'CustomListsState.dart';
import '../../../../Utils/Extensions/Responsive.dart';

class CustomListsSheet extends StatefulWidget {
  final bool anime;

  const CustomListsSheet({super.key, required this.anime});

  @override
  State<CustomListsSheet> createState() => _CustomListsSheetState();
}

class _CustomListsSheetState extends State<CustomListsSheet>
    with ScreenStateHost<CustomListsSheet, CustomListsState> {
  @override
  CustomListsState buildState() => CustomListsState(widget.anime);

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    return AppSheet(
      title: state.title,
      child: Padding(
        padding: Dimens.sheetInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (var i = 0; i < state.names.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: state.names[i],
                        decoration: InputDecoration(
                          labelText: getString.listName,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () => state.remove(i),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: state.add,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(getString.addList),
                ),
                const Spacer(),
                Watch(
                  () => FilledButton(
                    onPressed: state.busy.value ? null : state.save,
                    child: Text(getString.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCustomListsSheet(
  BuildContext context, {
  required bool anime,
}) => showCustomBottomDialog<void>(context, CustomListsSheet(anime: anime));
