import 'dart:async';

import 'SyncplayClient.dart';

class TogetherTag {
  final bool host;
  final String id;

  const TogetherTag({required this.host, required this.id});

  static final _pattern = RegExp(r'\s*\[dt\|([hg])\|([0-9a-f]{8})\]\s*$');

  String get text => ' [dt|${host ? 'h' : 'g'}|$id]';

  static (String, TogetherTag?) split(String name) {
    final match = _pattern.firstMatch(name);
    if (match == null) return (name, null);
    return (
      name.substring(0, match.start),
      TogetherTag(host: match.group(1) == 'h', id: match.group(2)!),
    );
  }
}

class TogetherFile {
  final String? name;
  final double? duration;
  final int? size;
  final TogetherTag? tag;

  const TogetherFile({this.name, this.duration, this.size, this.tag});

  factory TogetherFile.fromJson(Object? json) {
    if (json is! Map) return const TogetherFile();
    final raw = json['name'] as String?;
    final parts = raw == null ? null : TogetherTag.split(raw);
    return TogetherFile(
      name: parts?.$1,
      duration: (json['duration'] as num?)?.toDouble(),
      size: (json['size'] as num?)?.toInt(),
      tag: parts?.$2,
    );
  }

  bool get isEmpty => name == null;
}

class TogetherUser {
  final String name;
  TogetherFile file;
  bool ready;
  bool controller;

  TogetherUser(
    this.name, {
    this.file = const TogetherFile(),
    this.ready = false,
    this.controller = false,
  });

  bool get isHost => file.tag?.host ?? false;
}

sealed class TogetherEvent {
  const TogetherEvent();
}

class TogetherConnected extends TogetherEvent {
  final String? motd;
  const TogetherConnected(this.motd);
}

class TogetherDisconnected extends TogetherEvent {
  final String? reason;
  const TogetherDisconnected(this.reason);
}

class TogetherPlaystate extends TogetherEvent {
  final double position;
  final bool paused;
  final bool doSeek;
  final String? setBy;
  const TogetherPlaystate(this.position, this.paused, this.doSeek, this.setBy);
}

class TogetherUsers extends TogetherEvent {
  final List<TogetherUser> users;
  const TogetherUsers(this.users);
}

class TogetherUserEvent extends TogetherEvent {
  final String name;
  final bool joined;
  final bool left;
  final TogetherFile? file;
  const TogetherUserEvent(
    this.name, {
    this.joined = false,
    this.left = false,
    this.file,
  });
}

class TogetherReady extends TogetherEvent {
  final String name;
  final bool ready;
  const TogetherReady(this.name, this.ready);
}

class TogetherChat extends TogetherEvent {
  final String user;
  final String message;
  const TogetherChat(this.user, this.message);
}

class TogetherData extends TogetherEvent {
  final String user;
  final String payload;
  const TogetherData(this.user, this.payload);
}

class TogetherError extends TogetherEvent {
  final String message;
  const TogetherError(this.message);
}

abstract class TogetherBackend {
  String get id;
  String get label;
  String get defaultServer;

  Stream<TogetherEvent> get events;
  double get rtt;
  String get username;
  bool get awaitingEcho;

  Future<void> connect({
    required String server,
    required String room,
    required String name,
    String password = '',
  });

  Future<void> close();

  void sendState(
    double position,
    bool paused, {
    bool seek = false,
    bool local = false,
  });

  void sendKeepAlive();
  void setFile(String name, double duration, {TogetherTag? tag});
  void sendData(String payload);
  void setReady(bool ready);
  void chat(String message);
}

class TogetherBackends {
  TogetherBackends._();

  static final factories = <String, TogetherBackend Function()>{
    'syncplay': SyncplayClient.new,
  };

  static TogetherBackend create(String id) =>
      (factories[id] ?? factories.values.first)();
}
