import '../../../../Core/Services/ScoreFormat.dart';
import '../../../../Core/Services/ServiceAuth.dart';

class SimklUser implements ServiceUser {
  @override
  final int id;
  @override
  final String name;
  @override
  final String? avatar;
  @override
  final int episodesWatched;
  final String? joinedAt;
  final String? location;
  final String? timeZone;
  final String? accountType;

  const SimklUser({
    required this.id,
    required this.name,
    this.avatar,
    this.episodesWatched = 0,
    this.joinedAt,
    this.location,
    this.timeZone,
    this.accountType,
  });

  @override
  String? get banner => null;

  @override
  int get chaptersRead => 0;

  @override
  int get unreadNotifications => 0;

  @override
  ScoreFormat get scoreFormat => ScoreFormat.point10;

  String get profileUrl => 'https://simkl.com/$id';

  SimklUser copyWith({int? episodesWatched}) => SimklUser(
    id: id,
    name: name,
    avatar: avatar,
    episodesWatched: episodesWatched ?? this.episodesWatched,
    joinedAt: joinedAt,
    location: location,
    timeZone: timeZone,
    accountType: accountType,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'episodes': episodesWatched,
    'joinedAt': joinedAt,
    'location': location,
    'timeZone': timeZone,
    'accountType': accountType,
  };

  factory SimklUser.fromJson(Map<String, dynamic> j) => SimklUser(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String,
    avatar: j['avatar'] as String?,
    episodesWatched: (j['episodes'] as num?)?.toInt() ?? 0,
    joinedAt: j['joinedAt'] as String?,
    location: j['location'] as String?,
    timeZone: j['timeZone'] as String?,
    accountType: j['accountType'] as String?,
  );
}
