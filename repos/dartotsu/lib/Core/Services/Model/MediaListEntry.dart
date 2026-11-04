import 'Media.dart';

extension MediaListEntry on Media {
  void takeListEntry(Media from) {
    userStatus = from.userStatus;
    userProgress = from.userProgress;
    userScore = from.userScore;
    userUpdatedAt = from.userUpdatedAt;
    userListId = from.userListId;
  }
}
