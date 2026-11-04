import '../../../../Core/Services/ScoreFormat.dart';
import '../../../../Core/Services/ServiceAuth.dart';

class MangaBakaUser implements ServiceUser {
  @override
  final int id;
  final String sub;
  @override
  final String name;
  @override
  final String? avatar;
  @override
  final int chaptersRead;
  final int ratingSteps;

  const MangaBakaUser({
    required this.id,
    required this.sub,
    required this.name,
    this.avatar,
    this.chaptersRead = 0,
    this.ratingSteps = 1,
  });

  @override
  String? get banner => null;

  @override
  int get episodesWatched => 0;

  @override
  int get unreadNotifications => 0;

  @override
  ScoreFormat get scoreFormat =>
      ratingSteps > 1 ? ScoreFormat.point100 : ScoreFormat.point10;

  String get profileUrl => 'https://mangabaka.org/user/$sub';

  MangaBakaUser copyWith({int? chaptersRead}) => MangaBakaUser(
    id: id,
    sub: sub,
    name: name,
    avatar: avatar,
    chaptersRead: chaptersRead ?? this.chaptersRead,
    ratingSteps: ratingSteps,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sub': sub,
    'name': name,
    'avatar': avatar,
    'chapters': chaptersRead,
    'ratingSteps': ratingSteps,
  };

  factory MangaBakaUser.fromJson(Map<String, dynamic> j) => MangaBakaUser(
    id: (j['id'] as num?)?.toInt() ?? 0,
    sub: j['sub'] as String? ?? '',
    name: j['name'] as String? ?? 'MangaBaka',
    avatar: j['avatar'] as String?,
    chaptersRead: (j['chapters'] as num?)?.toInt() ?? 0,
    ratingSteps: (j['ratingSteps'] as num?)?.toInt() ?? 1,
  );
}
