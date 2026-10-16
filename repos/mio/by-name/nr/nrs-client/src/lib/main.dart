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

  bool _isAuthenticated = false;
  String? _userToken;
  String _registeredPhone = '';
  String _registeredName = '';
  String _nrsId = '';

  String _activeCountry = 'AU';

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

  void _startCall(
    String recipient,
    String callerName,
    String callerPhone,
    String notes,
    String state, {
    String? password,
    String? token,
    String? country,
  }) {
    final selectedCountry = country ?? 'AU';
    setState(() {
      _activeCallRecipient = recipient;
      _activeCountry = selectedCountry;
      _isCallActive = true;
    });

    ConnectCallRequest(
      callerName: callerName,
      callerPhone: callerPhone,
      recipientPhone: recipient,
      callNotes: notes,
      proxyUrl: _proxyUrl.isEmpty ? null : _proxyUrl,
      australianState: state,
      password: password,
      userToken: token ?? _userToken,
      country: selectedCountry,
    ).sendSignalToRust();
  }

  void _returnToDialer() {
    setState(() {
      _isCallActive = false;
      _activeCallRecipient = null;
    });
  }

  void _updateSettings(String proxyUrl, String country) {
    setState(() {
      _proxyUrl = proxyUrl;
      _activeCountry = country;
    });
  }

  void _handleLoginSuccess(String phone, String token, String name, String nrsId) {
    setState(() {
      _isAuthenticated = true;
      _userToken = token;
      _registeredPhone = phone;
      _registeredName = name;
      _nrsId = nrsId;
    });
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _userToken = null;
      _registeredPhone = '';
      _registeredName = '';
      _nrsId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relay Client (NRS & NZ Relay)',
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
              country: _activeCountry,
              onCallFinished: _returnToDialer,
            )
          : DialScreen(
              proxyUrl: _proxyUrl,
              onUpdateSettings: _updateSettings,
              onStartCall: _startCall,
              initialIsAuthenticated: _isAuthenticated,
              initialUserToken: _userToken,
              initialPhone: _registeredPhone,
              initialName: _registeredName,
              initialNrsId: _nrsId,
              onLoginSuccess: _handleLoginSuccess,
              onLogout: _handleLogout,
            ),
    );
  }
}
