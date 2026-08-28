import 'package:flutter/material.dart';

import 'services/download_store.dart';
import 'services/musescore_api.dart';
import 'screens/home_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';

class OpenScoreApp extends StatefulWidget {
  const OpenScoreApp({
    super.key,
    required this.settings,
    required this.store,
  });

  final AppSettings settings;
  final DownloadStore store;

  @override
  State<OpenScoreApp> createState() => _OpenScoreAppState();
}

class _OpenScoreAppState extends State<OpenScoreApp> {
  late AppSettings _settings = widget.settings;
  late MuseScoreApi _api = MuseScoreApi(
    proxyBaseUrl: _settings.proxyUrl.isEmpty ? null : _settings.proxyUrl,
  );
  int _index = 0;

  ThemeMode get _themeMode => switch (_settings.themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> _updateSettings(AppSettings next) async {
    await next.save();
    _api.dispose();
    setState(() {
      _settings = next;
      _api = MuseScoreApi(
        proxyBaseUrl: next.proxyUrl.isEmpty ? null : next.proxyUrl,
      );
    });
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(api: _api, settings: _settings, store: widget.store),
      DownloadsScreen(store: widget.store),
      SettingsScreen(settings: _settings, onChanged: _updateSettings),
      AboutScreen(),
    ];

    return MaterialApp(
      title: 'OpenScore',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B6B4A)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B6B4A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.download),
              label: 'Downloads',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load();
  final store = await DownloadStore.open();
  runApp(OpenScoreApp(settings: settings, store: store));
}
