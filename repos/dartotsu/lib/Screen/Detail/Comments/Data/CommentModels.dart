bool _flag(Object? v) => v == true || v == 1 || v == '1';

int? _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v');

class Comment {
  final int id;
  final String userId;
  final int mediaId;
  final int? parentId;
  String content;
  String timestamp;
  final bool deleted;
  final int? tag;
  int upvotes;
  int downvotes;
  int vote;
  final String username;
  final String? avatar;
  final bool isMod;
  final bool isAdmin;
  int replyCount;
  final int totalVotes;

  Comment({
    required this.id,
    required this.userId,
    required this.mediaId,
    this.parentId,
    required this.content,
    required this.timestamp,
    this.deleted = false,
    this.tag,
    this.upvotes = 0,
    this.downvotes = 0,
    this.vote = 0,
    required this.username,
    this.avatar,
    this.isMod = false,
    this.isAdmin = false,
    this.replyCount = 0,
    this.totalVotes = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
    id: _int(j['comment_id'] ?? j['id']) ?? 0,
    userId: '${j['user_id']}',
    mediaId: _int(j['media_id']) ?? 0,
    parentId: _int(j['parent_comment_id']),
    content: '${j['content'] ?? ''}',
    timestamp: '${j['timestamp'] ?? ''}',
    deleted: _flag(j['deleted']),
    tag: _int(j['tag']),
    upvotes: _int(j['upvotes']) ?? 0,
    downvotes: _int(j['downvotes']) ?? 0,
    vote: _int(j['user_vote_type']) ?? 0,
    username: '${j['username'] ?? ''}',
    avatar: j['profile_picture_url'] as String?,
    isMod: _flag(j['is_mod']),
    isAdmin: _flag(j['is_admin']),
    replyCount: _int(j['reply_count']) ?? 0,
    totalVotes: _int(j['total_votes']) ?? 0,
  );

  int get score => upvotes - downvotes;

  DateTime? get time => DateTime.tryParse(timestamp)?.toLocal();
}

class CommentPage {
  final List<Comment> comments;
  final int totalPages;

  const CommentPage(this.comments, this.totalPages);

  factory CommentPage.fromJson(Map<String, dynamic> j) => CommentPage([
    for (final c in (j['comments'] as List? ?? const []))
      if (c is Map) Comment.fromJson(Map<String, dynamic>.from(c)),
  ], _int(j['totalPages']) ?? 1);
}

class CommentNotice {
  final int id;
  final int? type;
  final int mediaId;
  final int commentId;
  final String username;
  final String? content;
  final int receivedAt;
  final String? mediaTitle;
  final String? cover;

  const CommentNotice({
    required this.id,
    required this.type,
    required this.mediaId,
    required this.commentId,
    required this.username,
    this.content,
    this.receivedAt = 0,
    this.mediaTitle,
    this.cover,
  });

  factory CommentNotice.fromJson(Map<String, dynamic> j) => CommentNotice(
    id: _int(j['notification_id']) ?? 0,
    type: _int(j['type']),
    mediaId: _int(j['media_id']) ?? 0,
    commentId: _int(j['comment_id']) ?? 0,
    username: '${j['username'] ?? ''}',
    content: j['content'] as String?,
    receivedAt: _int(j['received_at']) ?? 0,
    mediaTitle: j['media_title'] as String?,
    cover: j['cover'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'notification_id': id,
    'type': type,
    'media_id': mediaId,
    'comment_id': commentId,
    'username': username,
    'content': content,
    'received_at': receivedAt,
    'media_title': mediaTitle,
    'cover': cover,
  };

  CommentNotice copyWith({
    int? receivedAt,
    String? mediaTitle,
    String? cover,
  }) => CommentNotice(
    id: id,
    type: type,
    mediaId: mediaId,
    commentId: commentId,
    username: username,
    content: content,
    receivedAt: receivedAt ?? this.receivedAt,
    mediaTitle: mediaTitle ?? this.mediaTitle,
    cover: cover ?? this.cover,
  );

  bool get isReply => type == null || type == 1;

  bool get isWarning => type == 2;

  bool get isAnnouncement => type == 3;

  bool get isSilent => type == 420;

  bool get isGlobal => type == 3 || type == 420;

  String get key => '$id/${type ?? 1}';
}

class CommentSession {
  final String token;
  final String userId;
  final String username;
  final String? avatar;
  final bool isBanned;
  final bool isMod;
  final bool isAdmin;
  final int totalVotes;
  final int issuedAt;
  final String forToken;

  const CommentSession({
    required this.token,
    required this.userId,
    required this.username,
    this.avatar,
    this.isBanned = false,
    this.isMod = false,
    this.isAdmin = false,
    this.totalVotes = 0,
    required this.issuedAt,
    required this.forToken,
  });

  factory CommentSession.fromApi(
    Map<String, dynamic> j,
    String token, {
    required String forToken,
    CommentSession? previous,
  }) {
    final u = Map<String, dynamic>.from(j['user'] as Map);
    return CommentSession(
      token: token,
      userId: '${u['user_id']}',
      username: '${u['username'] ?? ''}',
      avatar: u['profile_picture_url'] as String?,
      isBanned: _flag(u['is_banned']),
      isMod: _flag(u['is_mod']),
      isAdmin: _flag(u['is_admin']),
      totalVotes: _int(u['total_votes']) ?? 0,
      issuedAt: previous?.issuedAt ?? DateTime.now().millisecondsSinceEpoch,
      forToken: forToken,
    );
  }

  CommentSession refreshed(Map<String, dynamic> j) {
    final u = Map<String, dynamic>.from(j['user'] as Map);
    return CommentSession(
      token: token,
      userId: userId,
      username: username,
      avatar: u['profile_picture_url'] as String? ?? avatar,
      isBanned: _flag(u['is_banned']),
      isMod: _flag(u['is_mod']),
      isAdmin: _flag(u['is_admin']),
      totalVotes: _int(u['total_votes']) ?? totalVotes,
      issuedAt: issuedAt,
      forToken: forToken,
    );
  }

  factory CommentSession.fromJson(Map<String, dynamic> j) => CommentSession(
    token: j['token'] as String,
    userId: j['userId'] as String,
    username: j['username'] as String? ?? '',
    avatar: j['avatar'] as String?,
    isBanned: j['banned'] == true,
    isMod: j['mod'] == true,
    isAdmin: j['admin'] == true,
    totalVotes: _int(j['votes']) ?? 0,
    issuedAt: _int(j['at']) ?? 0,
    forToken: j['for'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'token': token,
    'userId': userId,
    'username': username,
    'avatar': ?avatar,
    'banned': isBanned,
    'mod': isMod,
    'admin': isAdmin,
    'votes': totalVotes,
    'at': issuedAt,
    'for': forToken,
  };
}

class CommentsException implements Exception {
  final int status;
  final String message;

  const CommentsException(this.status, this.message);

  bool get rateLimited => status == 429;

  @override
  String toString() => message;
}
