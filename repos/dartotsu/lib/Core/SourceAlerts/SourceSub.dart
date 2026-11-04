import 'dart:math';

import '../Services/Model/Media.dart';

enum SubHealth { ok, unreachable, missing, finished }

class SourceSub {
  final String serviceId;
  final String mediaId;
  String serviceName;
  bool anime;
  String type;
  Map<String, Object?> media;
  String title;
  String? cover;
  String? banner;
  String managerId;
  String managerName;
  String sourceId;
  String sourceName;
  String? sourceLang;
  String? sourceIcon;
  bool fixed;
  String targetUrl;
  String? targetTitle;
  String? targetCover;
  String? season;
  int? progress;
  int localProgress;
  String? listStatus;
  int? total;
  int? airingAt;
  double lastValue;
  List<int> releases;
  int lastReleaseAt;
  int nextCheckAt;
  int lastChecked;
  SubHealth health;
  int failures;
  bool muted;

  SourceSub({
    required this.serviceId,
    required this.mediaId,
    required this.serviceName,
    required this.anime,
    required this.type,
    required this.media,
    required this.title,
    this.cover,
    this.banner,
    required this.managerId,
    required this.managerName,
    required this.sourceId,
    required this.sourceName,
    this.sourceLang,
    this.sourceIcon,
    this.fixed = false,
    required this.targetUrl,
    this.targetTitle,
    this.targetCover,
    this.season,
    this.progress,
    this.localProgress = 0,
    this.listStatus,
    this.total,
    this.airingAt,
    this.lastValue = 0,
    List<int>? releases,
    this.lastReleaseAt = 0,
    this.nextCheckAt = 0,
    this.lastChecked = 0,
    this.health = SubHealth.ok,
    this.failures = 0,
    this.muted = false,
  }) : releases = releases ?? [];

  String get key => '$serviceId/$mediaId';

  String get dedupe => '$managerId|$sourceId|$targetUrl';

  int? get seen => progress == null && localProgress <= 0
      ? null
      : max(progress ?? 0, localProgress);

  Media buildMedia() {
    final json = <String, dynamic>{
      for (final e in media.entries)
        if (!(e.key == 'manga' || e.key == 'anime') || e.value is Map)
          e.key: e.value,
    };
    return Media.fromJson(json);
  }

  Map<String, Object?> toJson() => {
    'service': serviceId,
    'id': mediaId,
    'serviceName': serviceName,
    'anime': anime,
    'type': type,
    'media': media,
    'title': title,
    'cover': cover,
    'banner': banner,
    'manager': managerId,
    'managerName': managerName,
    'source': sourceId,
    'sourceName': sourceName,
    'lang': sourceLang,
    'icon': sourceIcon,
    'fixed': fixed,
    'url': targetUrl,
    'targetTitle': targetTitle,
    'targetCover': targetCover,
    'season': season,
    'progress': progress,
    'local': localProgress,
    'status': listStatus,
    'total': total,
    'airingAt': airingAt,
    'last': lastValue,
    'releases': releases,
    'released': lastReleaseAt,
    'next': nextCheckAt,
    'checked': lastChecked,
    'health': health.name,
    'failures': failures,
    'muted': muted,
  };

  static SourceSub? fromJson(Object? json) {
    if (json is! Map) return null;
    final service = json['service'];
    final id = json['id'];
    final manager = json['manager'];
    final source = json['source'];
    final url = json['url'];
    if (service is! String ||
        id is! String ||
        manager is! String ||
        source is! String ||
        url is! String) {
      return null;
    }
    return SourceSub(
      serviceId: service,
      mediaId: id,
      serviceName: json['serviceName'] as String? ?? service,
      anime: json['anime'] != false,
      type: json['type'] as String? ?? 'anime',
      media: json['media'] is Map
          ? Map<String, Object?>.from(json['media'] as Map)
          : {'id': id},
      title: json['title'] as String? ?? id,
      cover: json['cover'] as String?,
      banner: json['banner'] as String?,
      managerId: manager,
      managerName: json['managerName'] as String? ?? manager,
      sourceId: source,
      sourceName: json['sourceName'] as String? ?? source,
      sourceLang: json['lang'] as String?,
      sourceIcon: json['icon'] as String?,
      fixed: json['fixed'] == true,
      targetUrl: url,
      targetTitle: json['targetTitle'] as String?,
      targetCover: json['targetCover'] as String?,
      season: json['season'] as String?,
      progress: (json['progress'] as num?)?.toInt(),
      localProgress: (json['local'] as num?)?.toInt() ?? 0,
      listStatus: json['status'] as String?,
      total: (json['total'] as num?)?.toInt(),
      airingAt: (json['airingAt'] as num?)?.toInt(),
      lastValue: (json['last'] as num?)?.toDouble() ?? 0,
      releases: [
        for (final r
            in json['releases'] is List ? json['releases'] as List : [])
          if (r is num) r.toInt(),
      ],
      lastReleaseAt: (json['released'] as num?)?.toInt() ?? 0,
      nextCheckAt: (json['next'] as num?)?.toInt() ?? 0,
      lastChecked: (json['checked'] as num?)?.toInt() ?? 0,
      health: SubHealth.values.asNameMap()[json['health']] ?? SubHealth.ok,
      failures: (json['failures'] as num?)?.toInt() ?? 0,
      muted: json['muted'] == true,
    );
  }
}

class SourceNotice {
  final String id;
  final String subKey;
  final String title;
  final String body;
  final String? cover;
  final int at;
  bool read;

  SourceNotice({
    required this.id,
    required this.subKey,
    required this.title,
    required this.body,
    this.cover,
    required this.at,
    this.read = false,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'sub': subKey,
    'title': title,
    'body': body,
    'cover': cover,
    'at': at,
    'read': read,
  };

  static SourceNotice? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final sub = json['sub'];
    if (id is! String || sub is! String) return null;
    return SourceNotice(
      id: id,
      subKey: sub,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      cover: json['cover'] as String?,
      at: (json['at'] as num?)?.toInt() ?? 0,
      read: json['read'] == true,
    );
  }
}
