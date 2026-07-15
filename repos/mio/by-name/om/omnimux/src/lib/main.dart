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

  @override
  void initState() {
    super.initState();
    GetSshHosts().sendSignalToRust();
    
    // Listen for ssh hosts
    SshHostsResult.rustSignalStream.listen((event) {
      if (mounted) {
        setState(() {
          _hosts.clear();
          _hosts.addAll(event.message.hosts);
        });
      }
    });

    // Listen for terminal exit
    TerminalExit.rustSignalStream.listen((event) {
      if (mounted) {
        setState(() {
          final idx = _sessions.indexWhere((s) => s.id == event.message.sessionId);
          if (idx != -1) {
            _sessions.removeAt(idx);
            if (_activeTabIndex >= _sessions.length) {
              _activeTabIndex = _sessions.length - 1;
            }
            if (_activeTabIndex < 0) _activeTabIndex = 0;
          }
        });
      }
    });

    // Output is handled inside TerminalSession class via stream filtering
  }

  void _addTab(String host) {
    final sessionId = _nextSessionId++;
    final session = TerminalSession(id: sessionId, host: host);
    setState(() {
      _sessions.add(session);
      _activeTabIndex = _sessions.length - 1;
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
                      
                      // Update active tab index if needed
                      if (_activeTabIndex == oldIndex) {
                        _activeTabIndex = newIndex;
                      } else if (_activeTabIndex > oldIndex && _activeTabIndex <= newIndex) {
                        _activeTabIndex--;
                      } else if (_activeTabIndex < oldIndex && _activeTabIndex >= newIndex) {
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
                        children: _hosts.map((host) => ListTile(
                          title: Text(host),
                          onTap: () {
                            Navigator.pop(context);
                            _addTab(host);
                          },
                        )).toList(),
                      ),
                    );
                  }
                );
              },
            ),
          ],
        ),
      ),
      body: _sessions.isEmpty
          ? const Center(child: Text('No active sessions. Click + to start.'))
          : _sessions[_activeTabIndex].buildWidget(),
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
          color: isActive ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(session.host),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  StopSession(sessionId: session.id).sendSignalToRust();
                  setState(() {
                    _sessions.removeAt(index);
                    if (_activeTabIndex >= _sessions.length) {
                      _activeTabIndex = _sessions.length - 1;
                    }
                    if (_activeTabIndex < 0) _activeTabIndex = 0;
                  });
                },
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
  
  TerminalSession({required this.id, required this.host})
      : terminal = Terminal(
          maxLines: 10000,
        ) {
    terminal.onOutput = (data) {
      WriteSession(
        sessionId: id,
        data: data.codeUnits,
      ).sendSignalToRust();
    };

    terminal.onResize = (w, h, pw, ph) {
      ResizeSession(
        sessionId: id,
        cols: w,
        rows: h,
      ).sendSignalToRust();
    };

    TerminalOutput.rustSignalStream.where((event) => event.message.sessionId == id).listen((event) {
      terminal.write(String.fromCharCodes(event.message.data));
    });

    StartSession(
      sessionId: id,
      host: host,
      cols: terminal.viewWidth,
      rows: terminal.viewHeight,
    ).sendSignalToRust();
  }

  Widget buildWidget() {
    return TerminalView(terminal);
  }
}
