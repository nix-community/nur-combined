import 'package:flutter/material.dart';

import '../../../Core/Services/MediaService.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Functions/SnackBar.dart';
import '../../../Widgets/Components/ScreenState.dart';

enum ComposerKind { activity, message, reply, group }

class ComposerState extends ScreenState {
  final SocialScreenView view;
  final ComposerKind kind;
  final String? userId;
  final String? activityId;
  final String? editId;
  final String initial;
  final bool initialPrivate;

  ComposerState({
    required this.view,
    required this.kind,
    this.userId,
    this.activityId,
    this.editId,
    this.initial = '',
    this.initialPrivate = false,
  });

  late final controller = TextEditingController(text: initial);
  final preview = false.live;
  final busy = false.live;
  late final private = initialPrivate.live;

  @override
  void onClose() => controller.dispose();

  String get title {
    final editing = editId != null;
    return switch (kind) {
      ComposerKind.activity =>
        editing ? getString.editActivity : getString.newActivity,
      ComposerKind.message =>
        editing ? getString.editMessage : getString.writeMessage,
      ComposerKind.reply => editing ? getString.editReply : getString.reply,
      ComposerKind.group =>
        editing ? getString.editActivity : getString.groupsNewPost,
    };
  }

  void wrap(String before, [String? after]) {
    final value = controller.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    final text = value.text;
    final inner = text.substring(start, end);
    final closing = after ?? before;
    final next = text.replaceRange(start, end, '$before$inner$closing');
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(
        offset: start + before.length + inner.length,
      ),
    );
  }

  Future<void> submit() async {
    final text = controller.text.trim();
    if (text.isEmpty || busy.value) return;
    busy.value = true;
    final edit = editId;
    final ok = switch (kind) {
      ComposerKind.activity => await view.postActivity(text, edit: edit),
      ComposerKind.message => await view.postMessage(
        userId!,
        text,
        edit: edit,
        isPrivate: private.value,
      ),
      ComposerKind.reply => await view.postReply(activityId!, text, edit: edit),
      ComposerKind.group => await view.postToGroup(userId!, text, edit: edit),
    };
    if (!mounted) return;
    if (ok) {
      snackString(edit == null ? getString.posted : getString.saved);
      pop(true);
    } else {
      busy.value = false;
      snackString(getString.couldNotPost);
    }
  }
}
