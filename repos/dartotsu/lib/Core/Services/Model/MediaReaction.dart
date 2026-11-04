import 'User.dart';

class MediaReaction {
  final String id;
  final String text;
  int votes;
  bool voted;
  bool mine;
  final int? createdAt;
  final User? user;

  MediaReaction({
    required this.id,
    required this.text,
    this.votes = 0,
    this.voted = false,
    this.mine = false,
    this.createdAt,
    this.user,
  });
}
