import 'dart:async';

import 'package:flutter/material.dart';

import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Reader/Engine/NovelSpeech.dart';
import '../../Reader/Engine/ReaderSettings.dart';

List<String> speechChunks(String text, {int max = 400}) {
  final out = <String>[];
  for (final paragraph in text.split(RegExp(r'\n+'))) {
    var buffer = StringBuffer();
    for (final sentence in paragraph.split(RegExp(r'(?<=[.!?。！？])\s+'))) {
      if (buffer.length + sentence.length > max && buffer.isNotEmpty) {
        out.add(buffer.toString().trim());
        buffer = StringBuffer();
      }
      buffer
        ..write(sentence)
        ..write(' ');
    }
    final rest = buffer.toString().trim();
    if (rest.isNotEmpty) out.add(rest);
  }
  return out;
}

class SpeakButton extends StatefulWidget {
  final String text;

  const SpeakButton({super.key, required this.text});

  @override
  State<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<SpeakButton> {
  final _speech = NovelSpeech();
  final _speaking = false.live;
  int _run = 0;

  @override
  void dispose() {
    _run++;
    unawaited(_speech.dispose());
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_speaking.value) {
      _run++;
      _speaking.value = false;
      await _speech.stop();
      return;
    }
    final run = ++_run;
    _speaking.value = true;
    final s = ReaderPrefs.global.value;
    for (final chunk in speechChunks(widget.text)) {
      if (run != _run) return;
      final ok = await _speech.speak(
        chunk,
        rate: s.speechRate,
        pitch: s.speechPitch,
        voice: s.speechVoice,
      );
      if (run != _run || !ok) break;
    }
    if (run == _run && mounted) _speaking.value = false;
  }

  @override
  Widget build(BuildContext context) => Watch(
    () => IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: _speaking.value
          ? getString.novelSpeakStop
          : getString.novelSpeak,
      onPressed: () => unawaited(_toggle()),
      icon: Icon(
        _speaking.value
            ? Icons.stop_circle_outlined
            : Icons.record_voice_over_rounded,
      ),
    ),
  );
}
