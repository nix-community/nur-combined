import 'package:flutter/material.dart';

import '../../../../Core/Preferences/PrefManager.dart';
import '../../../../Core/Services/MediaService.dart';
import '../../../../Model/Setting.dart';
import '../../../../Core/Services/Screens/NotificationAlertSettings.dart';
import '../Auth.dart';
import '../Client.dart';
import '../Data/Mapper.dart';
import '../Prefs.dart';

const _pageSize = 30;

class KitsuNotificationView extends NotificationScreenView {
  final Map<int, String> _cursors = {};

  @override
  List<NotificationKind> get kinds => const [
    NotificationKind.reply,
    NotificationKind.mention,
    NotificationKind.like,
    NotificationKind.follow,
  ];

  @override
  List<Setting> settings(BuildContext context) =>
      notificationAlertSettings(this, serviceName: 'Kitsu');

  @override
  Pref<bool> get alertsPref => KitsuPref.alerts;

  @override
  Pref<int> get pollPref => KitsuPref.pollMinutes;

  @override
  Pref<String> get mutedPref => KitsuPref.mutedKinds;

  @override
  Future<List<ServiceNotification>> unread() async {
    final all = await notifications();
    return [
      for (final n in all)
        if (n.unread) n,
    ];
  }

  @override
  Future<List<ServiceNotification>> notifications({int page = 1}) async {
    final me = kitsuAuth.user.value?.id;
    if (me == null) return const [];
    if (page == 1) _cursors.clear();
    final cursor = page > 1 ? _cursors[page] : null;
    JsonApi doc;
    try {
      doc = JsonApi(
        await kitsuAuth.client.get(
          '/feeds/notifications/$me',
          query: {
            'page[limit]': '$_pageSize',
            'page[cursor]': ?cursor,
            'include': 'activities,activities.actor',
          },
        ),
      );
    } on KitsuException catch (e) {
      if (e.status != 400) rethrow;
      doc = JsonApi(
        await kitsuAuth.client.get(
          '/feeds/notifications/$me',
          query: {
            'page[limit]': '$_pageSize',
            'page[cursor]': ?cursor,
            'include': 'activities',
          },
        ),
      );
    }
    final next = doc.next == null
        ? null
        : Uri.tryParse(doc.next!)?.queryParameters['page[cursor]'];
    if (next != null) _cursors[page + 1] = next;
    return [for (final group in doc.data) ?_group(group, doc)];
  }

  ServiceNotification? _group(Map<String, dynamic> group, JsonApi doc) {
    final activities = doc.many(group, 'activities');
    if (activities.isEmpty) return null;
    final first = activities.first;
    final a = attrs(first);
    final verb = '${a['verb'] ?? ''}';
    final actor = doc.one(first, 'actor');
    final name = actor == null ? null : attrs(actor)['name'] as String?;
    final count =
        ((attrs(group)['activitiesCount'] as num?)?.toInt() ??
        activities.length);
    final who = name == null
        ? 'Someone'
        : count > 1
        ? '$name and ${count - 1} other${count > 2 ? 's' : ''}'
        : name;
    final (text, kind) = switch (verb) {
      'follow' => ('$who followed you', NotificationKind.follow),
      'post_like' => ('$who liked your post', NotificationKind.like),
      'comment_like' => ('$who liked your comment', NotificationKind.like),
      'review_like' => ('$who liked your review', NotificationKind.like),
      'comment' ||
      'post_comment' => ('$who commented on your post', NotificationKind.reply),
      'reply_to_comment' ||
      'reply' => ('$who replied to your comment', NotificationKind.reply),
      'mention' => ('$who mentioned you', NotificationKind.mention),
      '' => ('$who sent you a notification', NotificationKind.other),
      _ => ('$who: ${verb.replaceAll('_', ' ')}', NotificationKind.other),
    };
    final seen = attrs(group)['isSeen'] == true;
    return ServiceNotification(
      id: '${group['id']}',
      text: text,
      imageUrl: actor == null
          ? null
          : kitsuImage(attrs(actor)['avatar'], const [
              'large',
              'medium',
              'original',
            ]),
      createdAt:
          DateTime.tryParse(
            '${a['time'] ?? attrs(group)['updatedAt'] ?? ''}',
          )?.toLocal() ??
          DateTime.now(),
      userId: actor == null ? null : '${actor['id']}',
      kind: kind,
      unread: !seen,
      title: name,
      detail: text.startsWith('$who ') ? text.substring(who.length + 1) : text,
    );
  }
}
