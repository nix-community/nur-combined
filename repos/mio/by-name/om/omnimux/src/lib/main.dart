import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rinf/rinf.dart';
import 'package:xterm/xterm.dart';
import 'src/bindings/bindings.dart';
import 'src/bindings/signals/signals.dart';

Future<void> main() async {
  await initializeRust(assignRustSignal);
  runApp(const OmnimuxApp());
}

class OmnimuxApp extends StatefulWidget {
  const OmnimuxApp({super.key});

  @override
  State<OmnimuxApp> createState() => _OmnimuxAppState();
}

class _OmnimuxAppState extends State<OmnimuxApp> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    // Matches rinf 8.x guidance: finalize Rust before app exit.
    _listener = AppLifecycleListener(
      onExitRequested: () async {
        finalizeRust();
        return AppExitResponse.exit;
      },
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omnimux',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> _hosts = ['localhost'];
  final List<TerminalSession> _sessions = [];
  int _nextSessionId = 1;
  int _activeTabIndex = 0;
  StreamSubscription<RustSignalPack<SshHostsResult>>? _hostsSub;
  StreamSubscription<RustSignalPack<TerminalExit>>? _exitSub;

  @override
  void initState() {
    super.initState();
    GetSshHosts().sendSignalToRust();

    _hostsSub = SshHostsResult.rustSignalStream.listen((event) {
      if (mounted) {
        setState(() {
          _hosts.clear();
          _hosts.addAll(event.message.hosts);
        });
      }
    });

    _exitSub = TerminalExit.rustSignalStream.listen((event) {
      if (!mounted) return;
      final idx = _sessions.indexWhere((s) => s.id == event.message.sessionId);
      if (idx != -1) {
        final session = _sessions[idx];
        final status = event.message.status;
        if (status == 0) {
          _closeTab(idx);
        } else {
          session.terminal.write('\r\n\r\n[Process exited with status $status]\r\n');
        }
      }
    });
  }

  @override
  void dispose() {
    _hostsSub?.cancel();
    _exitSub?.cancel();
    for (final session in _sessions) {
      session.dispose();
    }
    super.dispose();
  }

  void _addTab(String host) {
    final sessionId = _nextSessionId++;
    final session = TerminalSession(id: sessionId, host: host);
    setState(() {
      _sessions.add(session);
      _activeTabIndex = _sessions.length - 1;
    });
    session.requestFocus();
  }

  void _closeTab(int index) {
    final session = _sessions[index];
    StopSession(sessionId: session.id).sendSignalToRust();
    session.dispose();
    setState(() {
      _sessions.removeAt(index);
      if (index < _activeTabIndex) {
        // We closed a tab to the left of the active tab, so the active tab shifted left.
        _activeTabIndex--;
      } else if (_activeTabIndex >= _sessions.length) {
        // We closed the active tab (or one to the right, but active was the last tab).
        _activeTabIndex = _sessions.length - 1;
      }
      if (_activeTabIndex < 0) _activeTabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        titleSpacing: 0,
        leadingWidth: Platform.isMacOS ? 80 : 0,
        leading: Platform.isMacOS ? const SizedBox(width: 80) : null,
        title: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onDoubleTap: () {
            if (Platform.isMacOS) {
              const MethodChannel('omnimux/window').invokeMethod('zoom');
            }
          },
          child: Row(
            children: [
              Expanded(
              child: SizedBox(
                height: 48,
                child: ReorderableListView(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final TerminalSession item = _sessions.removeAt(oldIndex);
                      _sessions.insert(newIndex, item);

                      if (_activeTabIndex == oldIndex) {
                        _activeTabIndex = newIndex;
                      } else if (_activeTabIndex > oldIndex &&
                          _activeTabIndex <= newIndex) {
                        _activeTabIndex--;
                      } else if (_activeTabIndex < oldIndex &&
                          _activeTabIndex >= newIndex) {
                        _activeTabIndex++;
                      }
                    });
                  },
                  children: [
                    for (var i = 0; i < _sessions.length; i++)
                      _buildTab(i, _sessions[i]),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                String customUser = '';
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('New Session'),
                      content: SizedBox(
                        width: 300,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Username (optional)',
                                hintText: 'Default from ~/.ssh/config',
                              ),
                              onChanged: (val) => customUser = val.trim(),
                            ),
                            const SizedBox(height: 16),
                            Flexible(
                              child: ListView(
                                shrinkWrap: true,
                                children: _hosts.map((host) {
                                  return ListTile(
                                    title: Text(host),
                                    onTap: () {
                                      Navigator.pop(context);
                                      final finalHost = (customUser.isNotEmpty && host != 'localhost')
                                          ? '$customUser@$host'
                                          : host;
                                      _addTab(finalHost);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      ),
      body: _sessions.isEmpty
          ? const Center(child: Text('No active sessions. Click + to start.'))
          // IndexedStack keeps inactive tabs mounted so TerminalView can
          // autoResize / onResize before the tab is focused.
          : IndexedStack(
              index: _activeTabIndex,
              children: [
                for (var i = 0; i < _sessions.length; i++)
                  _sessions[i].buildWidget(context, autofocus: i == _activeTabIndex),
              ],
            ),
    );
  }

  Widget _buildTab(int index, TerminalSession session) {
    final isActive = index == _activeTabIndex;
    return ReorderableDragStartListener(
      key: ValueKey(session.id),
      index: index,
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTabIndex = index;
          });
          session.requestFocus();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(session.host),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _closeTab(index),
                child: const Icon(Icons.close, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TerminalSession {
  final int id;
  final String host;
  final Terminal terminal;
  final FocusNode focusNode = FocusNode();
  StreamSubscription<RustSignalPack<TerminalOutput>>? _outputSub;
  StreamSubscription<String>? _decodedSub;
  StreamController<List<int>>? _ptyBytes;
  bool _disposed = false;
  bool _started = false;

  static final _darkTheme = TerminalTheme(
    cursor: Colors.white,
    selection: Colors.blue.withOpacity(0.3),
    foreground: const Color(0xFFD4D4D4),
    background: const Color(0xFF1E1E1E),
    black: const Color(0xFF000000),
    red: const Color(0xFFCD3131),
    green: const Color(0xFF0DBC79),
    yellow: const Color(0xFFE5E510),
    blue: const Color(0xFF2472C8),
    magenta: const Color(0xFFBC3FBC),
    cyan: const Color(0xFF11A8CD),
    white: const Color(0xFFE5E5E5),
    brightBlack: const Color(0xFF666666),
    brightRed: const Color(0xFFF14C4C),
    brightGreen: const Color(0xFF23D18B),
    brightYellow: const Color(0xFFF5F543),
    brightBlue: const Color(0xFF3B8EEA),
    brightMagenta: const Color(0xFFD670D6),
    brightCyan: const Color(0xFF29B8DB),
    brightWhite: const Color(0xFFE5E5E5),
    searchHitBackground: Colors.yellow,
    searchHitBackgroundCurrent: Colors.orange,
    searchHitForeground: Colors.black,
  );

  static final _lightTheme = TerminalTheme(
    cursor: Colors.black,
    selection: Colors.blue.withOpacity(0.3),
    foreground: const Color(0xFF333333),
    background: const Color(0xFFFFFFFF),
    black: const Color(0xFF000000),
    red: const Color(0xFFCD3131),
    green: const Color(0xFF008000),
    yellow: const Color(0xFFB58900),
    blue: const Color(0xFF2472C8),
    magenta: const Color(0xFFBC3FBC),
    cyan: const Color(0xFF11A8CD),
    white: const Color(0xFFE5E5E5),
    brightBlack: const Color(0xFF666666),
    brightRed: const Color(0xFFF14C4C),
    brightGreen: const Color(0xFF23D18B),
    brightYellow: const Color(0xFFB58900),
    brightBlue: const Color(0xFF3B8EEA),
    brightMagenta: const Color(0xFFD670D6),
    brightCyan: const Color(0xFF29B8DB),
    brightWhite: const Color(0xFFE5E5E5),
    searchHitBackground: Colors.yellow,
    searchHitBackgroundCurrent: Colors.orange,
    searchHitForeground: Colors.black,
  );

  TerminalSession({required this.id, required this.host})
      : terminal = Terminal(
          maxLines: 10000,
        ) {
    // Match xterm.dart example: encode user input as UTF-8 bytes for the PTY.
    terminal.onOutput = (data) {
      if (_disposed) return;
      WriteSession(
        sessionId: id,
        data: utf8.encode(data),
      ).sendSignalToRust();
    };

    // Prefer the first TerminalView layout size (via autoResize → onResize).
    // Fall back after the first frame if layout never reported a size, as in
    // the upstream xterm endOfFrame start pattern.
    terminal.onResize = (w, h, pw, ph) {
      if (_disposed || w <= 0 || h <= 0) return;
      final wasStarted = _started;
      _startIfNeeded(w, h);
      // First start already includes cols/rows; later layout changes resize.
      if (wasStarted) {
        ResizeSession(
          sessionId: id,
          cols: w,
          rows: h,
        ).sendSignalToRust();
      }
    };

    WidgetsBinding.instance.endOfFrame.then((_) {
      if (_disposed || _started) return;
      _startIfNeeded(terminal.viewWidth, terminal.viewHeight);
    });

    // Stream-transform UTF-8 (dart:convert / xterm example). Do NOT use
    // StringConversionSink.withCallback — that only fires on close().
    final ptyBytes = StreamController<List<int>>();
    _ptyBytes = ptyBytes;
    _decodedSub = ptyBytes.stream
        .transform(const Utf8Decoder(allowMalformed: true))
        .listen((chunk) {
      if (!_disposed) {
        terminal.write(chunk);
      }
    });

    _outputSub = TerminalOutput.rustSignalStream
        .where((event) => event.message.sessionId == id)
        .listen((event) {
      if (_disposed || _ptyBytes == null || _ptyBytes!.isClosed) return;
      _ptyBytes!.add(event.message.data);
    });
  }

  void _startIfNeeded(int cols, int rows) {
    if (_disposed || _started || cols <= 0 || rows <= 0) return;
    _started = true;
    StartSession(
      sessionId: id,
      host: host,
      cols: cols,
      rows: rows,
    ).sendSignalToRust();
  }

  /// Request keyboard focus when this tab becomes active.
  /// (IndexedStack keeps children mounted; autofocus alone is not enough.)
  void requestFocus() {
    if (_disposed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        focusNode.requestFocus();
      }
    });
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _outputSub?.cancel();
    _outputSub = null;
    _decodedSub?.cancel();
    _decodedSub = null;
    _ptyBytes?.close();
    _ptyBytes = null;
    focusNode.dispose();
  }

  Widget buildWidget(BuildContext context, {required bool autofocus}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return KeyedSubtree(
      key: ValueKey(id),
      child: TerminalView(
        terminal,
        theme: isDark ? _darkTheme : _lightTheme,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    );
  }
}
