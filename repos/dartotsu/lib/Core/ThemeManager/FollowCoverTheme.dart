import '../../Logger.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../Preferences/PrefManager.dart';
import '../Services/MediaServiceController.dart';
import 'GlassBackgroundSource.dart';
import 'Themes/DynamicThemes.dart';
import '../../Utils/Functions/RefreshController.dart' show routeObserver;
import '../State/State.dart';

class FollowCoverTheme {
  final enabled = PrefName.followCover.rx;
  final mediaOnly = PrefName.followCoverMediaOnly.rx;
  final tick = 0.live;

  final _glassBackgroundUrl = PrefName.glassBackgroundUrl.rx;
  final _coverUrl = Live<String?>(null);
  final _subs = <Disposer>[];
  String? _imageUrl;
  ColorScheme? _light;
  ColorScheme? _dark;
  StreamSubscription<void>? _userSub;

  ColorScheme? schemeFor(Brightness brightness) =>
      enabled.value ? (brightness == Brightness.dark ? _dark : _light) : null;

  void init() {
    _subs.add(
      onAnyChange([enabled, mediaOnly, _glassBackgroundUrl, _coverUrl], _sync),
    );
    final services = tryFind<MediaServiceController>();
    if (services != null) {
      _subs.add(onChange(services.currentService, (_) => _bindUser()));
      _bindUser();
    }
    unawaited(_sync());
  }

  void dispose() {
    for (final worker in _subs) {
      worker.dispose();
    }
    _userSub?.cancel();
    _settle?.cancel();
  }

  Timer? _settle;
  final _owners = <(Object, String?)>[];
  final _routes = <Object, _CoverRoute>{};

  void _apply(String? url, {bool now = false}) {
    _settle?.cancel();
    if (_coverUrl.value == url) return;
    if (now) {
      _coverUrl.value = url;
      return;
    }
    _settle = Timer(const Duration(milliseconds: 450), () {
      _coverUrl.value = url;
    });
  }

  void set(Object owner, String? url) {
    final i = _owners.indexWhere((e) => identical(e.$1, owner));
    final top = i == -1 || i == _owners.length - 1;
    if (i == -1) {
      _owners.add((owner, url));
    } else {
      _owners[i] = (owner, url);
    }
    if (top) _apply(url);
  }

  void clear(Object owner) {
    _routes.remove(owner)?.dispose();
    final i = _owners.indexWhere((e) => identical(e.$1, owner));
    if (i == -1) return;
    final wasTop = i == _owners.length - 1;
    _owners.removeAt(i);
    if (wasTop) _apply(_owners.lastOrNull?.$2, now: true);
  }

  void track(Object owner, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted || _routes.containsKey(owner)) return;
      if (!_owners.any((e) => identical(e.$1, owner))) return;
      final route = ModalRoute.of(context);
      if (route == null) return;
      _routes[owner] = _CoverRoute(route, () => clear(owner));
    });
  }

  void _bindUser() {
    _userSub?.cancel();
    _userSub = tryFind<MediaServiceController>()
        ?.currentService
        .value
        .auth
        ?.user
        .stream
        .listen((_) => _sync());
    unawaited(_sync());
  }

  Future<void> _sync() async {
    final cover = _coverUrl.value;
    if (!enabled.value || (mediaOnly.value && cover == null)) {
      if (_imageUrl != null) {
        _imageUrl = null;
        _light = null;
        _dark = null;
        tick.value++;
      }
      return;
    }
    final url = cover ?? resolveGlassBackground();
    if (url == _imageUrl) return;
    _imageUrl = url;
    final schemes =
        await _schemesFor(url) ??
        (url == kFallbackGlassBackground
            ? null
            : await _schemesFor(kFallbackGlassBackground));
    if (_imageUrl != url || schemes == null) return;
    _light = schemes.$1;
    _dark = schemes.$2;
    tick.value++;
  }

  Future<(ColorScheme, ColorScheme)?> _schemesFor(String url) async {
    try {
      final light = await getImageMainColor(url, Brightness.light);
      final dark = await getImageMainColor(url, Brightness.dark);
      return (light, dark);
    } catch (e, st) {
      logError('FollowCoverTheme', e, st);
      return null;
    }
  }
}

class _CoverRoute with RouteAware {
  final VoidCallback _onPop;

  _CoverRoute(ModalRoute<void> route, this._onPop) {
    routeObserver.subscribe(this, route);
  }

  @override
  void didPop() => _onPop();

  void dispose() => routeObserver.unsubscribe(this);
}
