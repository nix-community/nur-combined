class ScoreInfo {
  const ScoreInfo({
    required this.id,
    required this.title,
    required this.url,
    this.thumbnailUrl = '',
    this.pageCount = 0,
    this.imageWidth = 0,
    this.imageHeight = 0,
  });

  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;
  final int pageCount;
  final int imageWidth;
  final int imageHeight;

  String get fileName {
    final escaped = title.replaceAll(RegExp(r'[\s<>:{}"/\\|?*~.\0]+'), '_');
    return escaped.isEmpty ? 'score_$id' : escaped;
  }

  String get imgType {
    final m = RegExp(r'score_0\.(\w+)').firstMatch(thumbnailUrl);
    return m?.group(1) ?? 'png';
  }

  ScoreInfo copyWith({
    int? id,
    String? title,
    String? url,
    String? thumbnailUrl,
    int? pageCount,
    int? imageWidth,
    int? imageHeight,
  }) {
    return ScoreInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      pageCount: pageCount ?? this.pageCount,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }
}

class SearchHit {
  const SearchHit({
    required this.id,
    required this.title,
    required this.url,
    this.snippet = '',
  });

  final int id;
  final String title;
  final String url;
  final String snippet;
}

enum DownloadFormat { midi, mp3, pdf }

extension DownloadFormatX on DownloadFormat {
  String get apiType => switch (this) {
    DownloadFormat.midi => 'midi',
    DownloadFormat.mp3 => 'mp3',
    DownloadFormat.pdf => 'img',
  };

  String get fileExtension => switch (this) {
    DownloadFormat.midi => 'mid',
    DownloadFormat.mp3 => 'mp3',
    DownloadFormat.pdf => 'pdf',
  };

  String get label => switch (this) {
    DownloadFormat.midi => 'MIDI',
    DownloadFormat.mp3 => 'MP3',
    DownloadFormat.pdf => 'PDF',
  };
}

class DownloadedItem {
  const DownloadedItem({
    required this.path,
    required this.title,
    required this.format,
    required this.scoreId,
    required this.savedAt,
  });

  final String path;
  final String title;
  final DownloadFormat format;
  final int scoreId;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
    'path': path,
    'title': title,
    'format': format.name,
    'scoreId': scoreId,
    'savedAt': savedAt.toIso8601String(),
  };

  static DownloadedItem fromJson(Map<String, dynamic> json) {
    return DownloadedItem(
      path: json['path'] as String,
      title: json['title'] as String,
      format: DownloadFormat.values.byName(json['format'] as String),
      scoreId: json['scoreId'] as int,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}
