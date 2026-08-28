import 'package:flutter_test/flutter_test.dart';
import 'package:openscore/models/score.dart';
import 'package:openscore/services/musescore_api.dart';

void main() {
  test('normalize and detect score URLs', () {
    final api = MuseScoreApi();
    expect(
      api.isScoreUrl('https://musescore.com/user/1/scores/2'),
      isTrue,
    );
    expect(api.isScoreUrl('twinkle little star'), isFalse);
    expect(
      api.normalizeScoreUrl('musescore.com/user/1/scores/2'),
      'https://musescore.com/user/1/scores/2',
    );
    api.dispose();
  });

  test('fileName escapes unsafe characters', () {
    const score = ScoreInfo(
      id: 1,
      title: 'Foo / Bar: Baz?',
      url: 'https://musescore.com/x/scores/1',
    );
    expect(score.fileName, 'Foo_Bar_Baz_');
  });

  test('download format extensions', () {
    expect(DownloadFormat.midi.fileExtension, 'mid');
    expect(DownloadFormat.mp3.fileExtension, 'mp3');
    expect(DownloadFormat.pdf.fileExtension, 'pdf');
  });
}
