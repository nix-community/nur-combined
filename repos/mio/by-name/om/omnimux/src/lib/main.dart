import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
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
      theme: ThemeData(
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
      setState(() {
        final idx =
            _sessions.indexWhere((s) => s.id == event.message.sessionId);
        if (idx != -1) {
          _sessions.removeAt(idx).dispose();
          if (_activeTabIndex >= _sessions.length) {
            _activeTabIndex = _sessions.length - 1;
          }
          if (_activeTabIndex < 0) _activeTabIndex = 0;
        }
      });
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
  }

  void _closeTab(int index) {
    final session = _sessions[index];
    StopSession(sessionId: session.id).sendSignalToRust();
    session.dispose();
    setState(() {
      _sessions.removeAt(index);
      if (_activeTabIndex >= _sessions.length) {
        _activeTabIndex = _sessions.length - 1;
      }
      if (_activeTabIndex < 0) _activeTabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
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
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('New Session'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _hosts
                            .map(
                              (host) => ListTile(
                                title: Text(host),
                                onTap: () {
                                  Navigator.pop(context);
                                  _addTab(host);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: _sessions.isEmpty
          ? const Center(child: Text('No active sessions. Click + to start.'))
          : IndexedStack(
              index: _activeTabIndex,
              children: [
                for (final session in _sessions) session.buildWidget(),
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
  StreamSubscription<RustSignalPack<TerminalOutput>>? _outputSub;
  bool _disposed = false;

  static final _theme = TerminalTheme(
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

  TerminalSession({required this.id, required this.host})
      : terminal = Terminal(
          maxLines: 10000,
        ) {
    terminal.onOutput = (data) {
      if (_disposed) return;
      WriteSession(
        sessionId: id,
        data: utf8.encode(data),
      ).sendSignalToRust();
    };

    terminal.onResize = (w, h, pw, ph) {
      if (_disposed) return;
      ResizeSession(
        sessionId: id,
        cols: w,
        rows: h,
      ).sendSignalToRust();
    };

    _outputSub = TerminalOutput.rustSignalStream
        .where((event) => event.message.sessionId == id)
        .listen((event) {
      if (_disposed) return;
      terminal.write(utf8.decode(event.message.data, allowMalformed: true));
    });

    StartSession(
      sessionId: id,
      host: host,
      cols: terminal.viewWidth,
      rows: terminal.viewHeight,
    ).sendSignalToRust();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _outputSub?.cancel();
    _outputSub = null;
  }

  Widget buildWidget() {
    return TerminalView(
      terminal,
      theme: _theme,
      autofocus: true,
    );
  }
}
