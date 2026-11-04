enum NotificationKind {
  airing,
  media,
  reply,
  mention,
  message,
  like,
  follow,
  other,
}

class ServiceNotification {
  final String id;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;
  final String? mediaId;
  final String? userId;
  final String? activityId;
  final NotificationKind kind;
  final bool unread;
  final String? title;
  final String? detail;
  final bool? mediaIsAnime;

  const ServiceNotification({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.createdAt,
    this.mediaId,
    this.userId,
    this.activityId,
    this.kind = NotificationKind.other,
    this.unread = false,
    this.title,
    this.detail,
    this.mediaIsAnime,
  });
}
