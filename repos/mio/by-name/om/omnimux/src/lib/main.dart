import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
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
          seedColor: const Color(0xFF3DAEE9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3DAEE9),
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
  final List<TerminalSession> _sessions = [];
  int _activeTabIndex = 0;
  int _nextSessionId = 1;
  List<String> _hosts = ['localhost'];
  StreamSubscription<RustSignalPack<SshHostsResult>>? _hostsSub;
  StreamSubscription<RustSignalPack<TerminalExit>>? _exitSub;
  bool _enableTmuxMouse = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _hostsSub = SshHostsResult.rustSignalStream.listen((event) {
      if (mounted) {
        setState(() {
          _hosts = event.message.hosts;
        });
      }
    });
    GetSshHosts().sendSignalToRust();

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

  File get _settingsFile {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    return File('$home/.config/omnimux/settings.json');
  }

  Future<void> _loadSettings() async {
    try {
      final file = _settingsFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        setState(() {
          _enableTmuxMouse = json['enableTmuxMouse'] ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveSettings(bool val) async {
    try {
      final file = _settingsFile;
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsString(jsonEncode({'enableTmuxMouse': val}));
    } catch (_) {}
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
    final session = TerminalSession(
      id: sessionId, 
      host: host, 
      enableTmuxMouse: _enableTmuxMouse,
    );
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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                showDialog(
                  context: context,
                  builder: (context) {
                    String inputText = '';
                    return StatefulBuilder(
                      builder: (context, setStateDialog) {
                        final hostQuery = inputText.contains('@') ? inputText.split('@').last : inputText;
                        final prefix = inputText.contains('@') ? '${inputText.split('@').first}@' : '';
                        final visibleHosts = _hosts.where((h) => h.toLowerCase().contains(hostQuery.toLowerCase())).toList();

                        return AlertDialog(
                          title: const Text('New Session'),
                          content: SizedBox(
                            width: 300,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Target (e.g. user@host or just host)',
                                    hintText: 'Enter custom target or filter below',
                                  ),
                                  onChanged: (val) => setStateDialog(() => inputText = val.trim()),
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                      Navigator.pop(context);
                                      _addTab(val.trim());
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                Flexible(
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: visibleHosts.map((host) {
                                      return ListTile(
                                        title: Text(host),
                                        onTap: () {
                                          Navigator.pop(context);
                                          final finalHost = (prefix.isNotEmpty && host != 'localhost')
                                              ? '$prefix$host'
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
                      }
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return AlertDialog(
                          title: const Text('Settings'),
                          content: SwitchListTile(
                            title: const Text('Enable tmux mouse mode'),
                            subtitle: const Text('Automatically sets "mouse on" in new sessions so you can scroll with the mouse wheel. Requires restarting active sessions to take effect.'),
                            value: _enableTmuxMouse,
                            onChanged: (val) async {
                              await _saveSettings(val);
                              setStateDialog(() {
                                _enableTmuxMouse = val;
                              });
                              setState(() {
                                _enableTmuxMouse = val;
                              });
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      }
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
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.surface
                : Colors.transparent,
            border: isActive
                ? Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.0,
                    ),
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.0,
                    ),
                  )
                : Border(
                    top: const BorderSide(
                      color: Colors.transparent,
                      width: 2.0,
                    ),
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.0,
                    ),
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(session.host),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  _closeTab(index);
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
  final bool enableTmuxMouse;
  final Terminal terminal;
  final TerminalController terminalController = TerminalController();
  final FocusNode focusNode = FocusNode();
  StreamSubscription<RustSignalPack<TerminalOutput>>? _outputSub;
  StreamSubscription<String>? _decodedSub;
  StreamController<List<int>>? _ptyBytes;
  bool _disposed = false;
  bool _started = false;

  static final _darkTheme = TerminalTheme(
    cursor: const Color(0xFFFFFFFF),
    selection: Color.fromARGB((0.5 * 255).round(), 0x4C, 0x5B, 0x5C),
    foreground: const Color(0xFFCCCCCC),
    background: const Color(0xFF000000),
    black: const Color(0xFF000000),
    red: const Color(0xFFC91B00),
    green: const Color(0xFF00C200),
    yellow: const Color(0xFFC7C400),
    blue: const Color(0xFF0225C7),
    magenta: const Color(0xFFC930C7),
    cyan: const Color(0xFF00C5C7),
    white: const Color(0xFFC7C7C7),
    brightBlack: const Color(0xFF676767),
    brightRed: const Color(0xFFFF6D67),
    brightGreen: const Color(0xFF5FF967),
    brightYellow: const Color(0xFFFEFA65),
    brightBlue: const Color(0xFF6871FF),
    brightMagenta: const Color(0xFFFF76FF),
    brightCyan: const Color(0xFF5FFDFF),
    brightWhite: const Color(0xFFFEFFFF),
    searchHitBackground: Colors.yellow,
    searchHitBackgroundCurrent: Colors.orange,
    searchHitForeground: Colors.black,
  );

  static final _lightTheme = TerminalTheme(
    cursor: const Color(0xFF000000),
    selection: Color.fromARGB((0.5 * 255).round(), 0xC1, 0xDE, 0xFF),
    foreground: const Color(0xFF000000),
    background: const Color(0xFFFFFFFF),
    black: const Color(0xFF000000),
    red: const Color(0xFFC91B00),
    green: const Color(0xFF00C200),
    yellow: const Color(0xFFC7C400),
    blue: const Color(0xFF0225C7),
    magenta: const Color(0xFFC930C7),
    cyan: const Color(0xFF00C5C7),
    white: const Color(0xFFC7C7C7),
    brightBlack: const Color(0xFF676767),
    brightRed: const Color(0xFFFF6D67),
    brightGreen: const Color(0xFF5FF967),
    brightYellow: const Color(0xFFFEFA65),
    brightBlue: const Color(0xFF6871FF),
    brightMagenta: const Color(0xFFFF76FF),
    brightCyan: const Color(0xFF5FFDFF),
    brightWhite: const Color(0xFFFEFFFF),
    searchHitBackground: Colors.yellow,
    searchHitBackgroundCurrent: Colors.orange,
    searchHitForeground: Colors.black,
  );

  TerminalSession({required this.id, required this.host, required this.enableTmuxMouse})
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
      enableTmuxMouse: enableTmuxMouse,
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

  final ValueNotifier<int> fontSize = ValueNotifier(14);

  Widget buildWidget(BuildContext context, {required bool autofocus}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return KeyedSubtree(
      key: ValueKey(id),
      child: ValueListenableBuilder<int>(
        valueListenable: fontSize,
        builder: (context, size, child) {
          return Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent || event is KeyRepeatEvent) {
                final isCtrlOrCmd = HardwareKeyboard.instance.isControlPressed ||
                                    HardwareKeyboard.instance.isMetaPressed;
                final isShift = HardwareKeyboard.instance.isShiftPressed;

                if (isCtrlOrCmd) {
                  if (event.logicalKey == LogicalKeyboardKey.equal ||
                      event.logicalKey == LogicalKeyboardKey.numpadAdd) {
                    fontSize.value = (fontSize.value + 1).clamp(6, 72);
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.minus ||
                             event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
                    fontSize.value = (fontSize.value - 1).clamp(6, 72);
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.digit0 ||
                             event.logicalKey == LogicalKeyboardKey.numpad0) {
                    fontSize.value = 14;
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.keyC && (isShift || Platform.isMacOS)) {
                    final selection = terminalController.selection;
                    if (selection != null) {
                      final text = terminal.buffer.getText(selection);
                      Clipboard.setData(ClipboardData(text: text));
                      terminalController.clearSelection();
                    }
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.keyV && (isShift || Platform.isMacOS)) {
                    Clipboard.getData(Clipboard.kTextPlain).then((data) {
                      if (data?.text != null && !_disposed) {
                        terminal.paste(data!.text!);
                      }
                    });
                    return KeyEventResult.handled;
                  }
                }
              }
              return KeyEventResult.ignored;
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Listener(
                  onPointerHover: (event) {
                    _lastPointerPosition = event.localPosition;
                  },
                  onPointerMove: (event) {
                    _lastPointerPosition = event.localPosition;
                  },
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      _handlePointerScroll(event, constraints);
                    }
                  },
                  onPointerPanZoomUpdate: (event) {
                    _handlePanZoomScroll(event, constraints);
                  },
                  child: TerminalView(
                    terminal,
                    controller: terminalController,
                    theme: isDark ? _darkTheme : _lightTheme,
                    textStyle: TerminalStyle(
                      fontFamily: 'Menlo',
                      fontFamilyFallback: ['Consolas', 'Ubuntu Mono', 'DejaVu Sans Mono', 'monospace'],
                      fontSize: size.toDouble(),
                    ),
                    focusNode: focusNode,
                    autofocus: autofocus,
                  ),
                );
              }
            ),
          );
        },
      ),
    );
  }

  Offset _lastPointerPosition = Offset.zero;
  double _scrollAccumulator = 0.0;
  double _wheelAccumulator = 0.0;

  void _handlePointerScroll(PointerScrollEvent event, BoxConstraints constraints) {
    if (!terminal.isUsingAltBuffer) return;

    final cellWidth = constraints.maxWidth / terminal.viewWidth;
    final cellHeight = constraints.maxHeight / terminal.viewHeight;
    
    // Multiply by 3 for faster, more responsive scrolling
    _wheelAccumulator += event.scrollDelta.dy * 3.0;
    
    final lines = (_wheelAccumulator / cellHeight).truncate();
    if (lines != 0) {
      _wheelAccumulator -= lines * cellHeight;
      
      final col = (event.localPosition.dx / cellWidth).floor().clamp(0, terminal.viewWidth - 1);
      final row = (event.localPosition.dy / cellHeight).floor().clamp(0, terminal.viewHeight - 1);
      
      for (var i = 0; i < lines.abs(); i++) {
        final up = lines < 0; 
        final handled = terminal.mouseInput(
          up ? TerminalMouseButton.wheelUp : TerminalMouseButton.wheelDown,
          TerminalMouseButtonState.down,
          CellOffset(col, row),
        );
        
        if (!handled) {
          terminal.keyInput(up ? TerminalKey.arrowUp : TerminalKey.arrowDown);
        }
      }
    }
  }

  void _handlePanZoomScroll(PointerPanZoomUpdateEvent event, BoxConstraints constraints) {
    if (!terminal.isUsingAltBuffer) return;

    final cellWidth = constraints.maxWidth / terminal.viewWidth;
    final cellHeight = constraints.maxHeight / terminal.viewHeight;
    
    // Multiply by 3 for faster trackpad scrolling on macOS/Wayland
    _scrollAccumulator -= event.panDelta.dy * 3.0;
    
    final lines = (_scrollAccumulator / cellHeight).truncate();
    if (lines != 0) {
      _scrollAccumulator -= lines * cellHeight;
      
      final col = (_lastPointerPosition.dx / cellWidth).floor().clamp(0, terminal.viewWidth - 1);
      final row = (_lastPointerPosition.dy / cellHeight).floor().clamp(0, terminal.viewHeight - 1);
      
      for (var i = 0; i < lines.abs(); i++) {
        final up = lines < 0; 
        final handled = terminal.mouseInput(
          up ? TerminalMouseButton.wheelUp : TerminalMouseButton.wheelDown,
          TerminalMouseButtonState.down,
          CellOffset(col, row),
        );
        
        if (!handled) {
          terminal.keyInput(up ? TerminalKey.arrowUp : TerminalKey.arrowDown);
        }
      }
    }
  }
}
