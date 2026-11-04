import 'dart:async';

import 'package:dbus/dbus.dart';

import '../../../Logger.dart';

const _root = 'org.mpris.MediaPlayer2';
const _player = 'org.mpris.MediaPlayer2.Player';

abstract class MprisHost {
  String get status;
  double get rate;
  Duration get position;
  Duration get length;
  String get title;
  String? get album;
  String? get art;
  int get trackIndex;
  bool get hasNext;
  bool get hasPrevious;

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> next();
  Future<void> previous();
  Future<void> seekBy(Duration by);
  Future<void> seekTo(Duration to);
  Future<void> setRate(double value);
}

class MprisService extends DBusObject {
  final MprisHost host;
  final String busName;
  DBusClient? _bus;
  bool _active = false;

  MprisService(this.host, {this.busName = 'org.mpris.MediaPlayer2.dartotsu'})
    : super(DBusObjectPath('/org/mpris/MediaPlayer2'));

  bool get active => _active;

  Future<void> start({DBusClient? bus}) async {
    if (_active) return;
    try {
      final client = _bus = bus ?? DBusClient.session();
      await client.registerObject(this);
      await client.requestName(
        busName,
        flags: {
          DBusRequestNameFlag.doNotQueue,
          DBusRequestNameFlag.allowReplacement,
        },
      );
      _active = true;
    } catch (e, st) {
      logError('MPRIS', e, st, 'start failed');
      await dispose();
    }
  }

  void refresh({
    bool status = false,
    bool metadata = false,
    bool rate = false,
    Duration? seeked,
  }) {
    if (!_active) return;
    final changed = <String, DBusValue>{
      if (status) ...{
        'PlaybackStatus': DBusString(host.status),
        'CanPlay': const DBusBoolean(true),
        'CanPause': const DBusBoolean(true),
      },
      if (metadata) ...{
        'Metadata': _metadata(),
        'CanGoNext': DBusBoolean(host.hasNext),
        'CanGoPrevious': DBusBoolean(host.hasPrevious),
      },
      if (rate) 'Rate': DBusDouble(host.rate),
    };
    if (changed.isNotEmpty) {
      unawaited(emitPropertiesChanged(_player, changedProperties: changed));
    }
    if (seeked != null) {
      unawaited(
        emitSignal(_player, 'Seeked', [DBusInt64(seeked.inMicroseconds)]),
      );
    }
  }

  DBusValue _metadata() {
    final art = host.art;
    final length = host.length.inMicroseconds;
    final album = host.album;
    return DBusDict.stringVariant({
      'mpris:trackid': DBusObjectPath('/org/dartotsu/track/${host.trackIndex}'),
      if (length > 0) 'mpris:length': DBusInt64(length),
      if (art != null && art.isNotEmpty) 'mpris:artUrl': DBusString(art),
      'xesam:title': DBusString(host.title),
      if (album != null && album.isNotEmpty) ...{
        'xesam:album': DBusString(album),
        'xesam:artist': DBusArray.string([album]),
      },
    });
  }

  Map<String, DBusValue> _rootProperties() => {
    'CanQuit': const DBusBoolean(false),
    'CanRaise': const DBusBoolean(false),
    'HasTrackList': const DBusBoolean(false),
    'Identity': const DBusString('Dartotsu'),
    'DesktopEntry': const DBusString('dartotsu'),
    'SupportedUriSchemes': DBusArray.string(['http', 'https', 'file']),
    'SupportedMimeTypes': DBusArray.string([]),
  };

  Map<String, DBusValue> _playerProperties() => {
    'PlaybackStatus': DBusString(host.status),
    'LoopStatus': const DBusString('None'),
    'Rate': DBusDouble(host.rate),
    'Shuffle': const DBusBoolean(false),
    'Metadata': _metadata(),
    'Volume': const DBusDouble(1),
    'Position': DBusInt64(host.position.inMicroseconds),
    'MinimumRate': const DBusDouble(0.25),
    'MaximumRate': const DBusDouble(4),
    'CanGoNext': DBusBoolean(host.hasNext),
    'CanGoPrevious': DBusBoolean(host.hasPrevious),
    'CanPlay': const DBusBoolean(true),
    'CanPause': const DBusBoolean(true),
    'CanSeek': const DBusBoolean(true),
    'CanControl': const DBusBoolean(true),
  };

  @override
  List<DBusIntrospectInterface> introspect() => [
    DBusIntrospectInterface(
      _root,
      methods: [DBusIntrospectMethod('Raise'), DBusIntrospectMethod('Quit')],
      properties: [
        for (final name in _rootProperties().keys)
          DBusIntrospectProperty(
            name,
            _rootProperties()[name]!.signature,
            access: DBusPropertyAccess.read,
          ),
      ],
    ),
    DBusIntrospectInterface(
      _player,
      methods: [
        for (final m in [
          'Next',
          'Previous',
          'Pause',
          'PlayPause',
          'Stop',
          'Play',
        ])
          DBusIntrospectMethod(m),
        DBusIntrospectMethod(
          'Seek',
          args: [
            DBusIntrospectArgument(
              DBusSignature('x'),
              DBusArgumentDirection.in_,
              name: 'Offset',
            ),
          ],
        ),
        DBusIntrospectMethod(
          'SetPosition',
          args: [
            DBusIntrospectArgument(
              DBusSignature('o'),
              DBusArgumentDirection.in_,
              name: 'TrackId',
            ),
            DBusIntrospectArgument(
              DBusSignature('x'),
              DBusArgumentDirection.in_,
              name: 'Position',
            ),
          ],
        ),
        DBusIntrospectMethod(
          'OpenUri',
          args: [
            DBusIntrospectArgument(
              DBusSignature('s'),
              DBusArgumentDirection.in_,
              name: 'Uri',
            ),
          ],
        ),
      ],
      signals: [
        DBusIntrospectSignal(
          'Seeked',
          args: [
            DBusIntrospectArgument(
              DBusSignature('x'),
              DBusArgumentDirection.out,
              name: 'Position',
            ),
          ],
        ),
      ],
      properties: [
        for (final entry in _playerProperties().entries)
          DBusIntrospectProperty(
            entry.key,
            entry.value.signature,
            access: entry.key == 'Rate' || entry.key == 'Volume'
                ? DBusPropertyAccess.readwrite
                : DBusPropertyAccess.read,
          ),
      ],
    ),
  ];

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    final map = interface == _root
        ? _rootProperties()
        : interface == _player
        ? _playerProperties()
        : null;
    if (map == null) return DBusMethodErrorResponse.unknownInterface();
    final value = map[name];
    return value == null
        ? DBusMethodErrorResponse.unknownProperty()
        : DBusGetPropertyResponse(value);
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    if (interface == _root) {
      return DBusGetAllPropertiesResponse(_rootProperties());
    }
    if (interface == _player) {
      return DBusGetAllPropertiesResponse(_playerProperties());
    }
    return DBusMethodErrorResponse.unknownInterface();
  }

  @override
  Future<DBusMethodResponse> setProperty(
    String interface,
    String name,
    DBusValue value,
  ) async {
    if (interface != _player) return DBusMethodErrorResponse.unknownProperty();
    final v = value is DBusDouble ? value.value : null;
    if (name == 'Rate' && v != null) {
      await host.setRate(v.clamp(0.25, 4.0).toDouble());
      return DBusMethodSuccessResponse();
    }
    if (name == 'Volume') return DBusMethodSuccessResponse();
    return DBusMethodErrorResponse.propertyReadOnly();
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    final call = methodCall;
    try {
      if (call.interface == _root) {
        return switch (call.name) {
          'Raise' || 'Quit' => DBusMethodSuccessResponse(),
          _ => DBusMethodErrorResponse.unknownMethod(),
        };
      }
      if (call.interface != _player) {
        return DBusMethodErrorResponse.unknownInterface();
      }
      switch (call.name) {
        case 'Play':
          await host.play();
        case 'Pause':
          await host.pause();
        case 'PlayPause':
          host.status == 'Playing' ? await host.pause() : await host.play();
        case 'Stop':
          await host.stop();
        case 'Next':
          await host.next();
        case 'Previous':
          await host.previous();
        case 'Seek':
          await host.seekBy(
            Duration(microseconds: call.values.first.asInt64()),
          );
        case 'SetPosition':
          await host.seekTo(Duration(microseconds: call.values[1].asInt64()));
        case 'OpenUri':
          return DBusMethodSuccessResponse();
        default:
          return DBusMethodErrorResponse.unknownMethod();
      }
      return DBusMethodSuccessResponse();
    } catch (e, st) {
      logError('MPRIS', e, st, '${call.name} failed');
      return DBusMethodErrorResponse.failed('$e');
    }
  }

  Future<void> dispose() async {
    _active = false;
    final bus = _bus;
    _bus = null;
    if (bus == null) return;
    try {
      await bus.releaseName(busName);
      await bus.close();
    } catch (e, st) {
      logError('MPRIS', e, st, 'close failed');
    }
  }
}
