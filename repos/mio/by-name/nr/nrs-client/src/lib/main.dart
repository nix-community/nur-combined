import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rinf/rinf.dart';
import 'src/bindings/signals/signals.dart';
import 'screens/dial_screen.dart';
import 'screens/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeRust(assignRustSignal);
  runApp(const NrsClientApp());
}

class NrsClientApp extends StatefulWidget {
  const NrsClientApp({super.key});

  @override
  State<NrsClientApp> createState() => _NrsClientAppState();
}

class _NrsClientAppState extends State<NrsClientApp> {
  late final AppLifecycleListener _listener;
  String _proxyUrl = '';
  String? _activeCallRecipient;
  bool _isCallActive = false;

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

  void _startCall(String recipient, String callerName, String callerPhone, String notes, String state) {
    setState(() {
      _activeCallRecipient = recipient;
      _isCallActive = true;
    });

    ConnectCallRequest(
      callerName: callerName,
      callerPhone: callerPhone,
      recipientPhone: recipient,
      callNotes: notes,
      proxyUrl: _proxyUrl.isEmpty ? null : _proxyUrl,
      australianState: state,
    ).sendSignalToRust();
  }

  void _returnToDialer() {
    setState(() {
      _isCallActive = false;
      _activeCallRecipient = null;
    });
  }

  void _updateSettings(String proxyUrl) {
    setState(() {
      _proxyUrl = proxyUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NRS Internet Relay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: _isCallActive && _activeCallRecipient != null
          ? ChatScreen(
              recipientNumber: _activeCallRecipient!,
              onCallFinished: _returnToDialer,
            )
          : DialScreen(
              proxyUrl: _proxyUrl,
              onUpdateSettings: _updateSettings,
              onStartCall: _startCall,
            ),
    );
  }
}
