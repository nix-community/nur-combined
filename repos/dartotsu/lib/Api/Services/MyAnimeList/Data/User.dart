import '../../../../Core/Services/ScoreFormat.dart';
import '../../../../Core/Services/ServiceAuth.dart';

class MalUser implements ServiceUser {
  @override
  final int id;
  @override
  final String name;
  @override
  final String? avatar;
  @override
  final int episodesWatched;
  @override
  final int chaptersRead;
  final String? joinedAt;
  final String? timeZone;
  final String? location;
  final bool supporter;
  final double meanScore;
  final double daysWatched;

  const MalUser({
    required this.id,
    required this.name,
    this.avatar,
    this.episodesWatched = 0,
    this.chaptersRead = 0,
    this.joinedAt,
    this.timeZone,
    this.location,
    this.supporter = false,
    this.meanScore = 0,
    this.daysWatched = 0,
  });

  @override
  String? get banner => null;

  @override
  int get unreadNotifications => 0;

  @override
  ScoreFormat get scoreFormat => ScoreFormat.point10;

  String get profileUrl => 'https://myanimelist.net/profile/$name';

  MalUser copyWith({int? chaptersRead}) => MalUser(
    id: id,
    name: name,
    avatar: avatar,
    episodesWatched: episodesWatched,
    chaptersRead: chaptersRead ?? this.chaptersRead,
    joinedAt: joinedAt,
    timeZone: timeZone,
    location: location,
    supporter: supporter,
    meanScore: meanScore,
    daysWatched: daysWatched,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'episodes': episodesWatched,
    'chapters': chaptersRead,
    'joinedAt': joinedAt,
    'timeZone': timeZone,
    'location': location,
    'supporter': supporter,
    'meanScore': meanScore,
    'daysWatched': daysWatched,
  };

  factory MalUser.fromJson(Map<String, dynamic> j) => MalUser(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String,
    avatar: j['avatar'] as String?,
    episodesWatched: (j['episodes'] as num?)?.toInt() ?? 0,
    chaptersRead: (j['chapters'] as num?)?.toInt() ?? 0,
    joinedAt: j['joinedAt'] as String?,
    timeZone: j['timeZone'] as String?,
    location: j['location'] as String?,
    supporter: j['supporter'] as bool? ?? false,
    meanScore: (j['meanScore'] as num?)?.toDouble() ?? 0,
    daysWatched: (j['daysWatched'] as num?)?.toDouble() ?? 0,
  );
}
