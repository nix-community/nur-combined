import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/score.dart';

class AppSettings {
  AppSettings({
    this.downloadFolder,
    this.themeMode = 'system',
    this.proxyUrl = '',
  });

  String? downloadFolder;
  String themeMode; // system | light | dark
  String proxyUrl;

  static const _kFolder = 'download_folder';
  static const _kTheme = 'theme_mode';
  static const _kProxy = 'proxy_url';
  static const _kDownloads = 'downloads_json';

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      downloadFolder: prefs.getString(_kFolder),
      themeMode: prefs.getString(_kTheme) ?? 'system',
      proxyUrl: prefs.getString(_kProxy) ?? '',
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    if (downloadFolder == null) {
      await prefs.remove(_kFolder);
    } else {
      await prefs.setString(_kFolder, downloadFolder!);
    }
    await prefs.setString(_kTheme, themeMode);
    await prefs.setString(_kProxy, proxyUrl);
  }

  Future<Directory> resolveDownloadDir() async {
    if (downloadFolder != null && downloadFolder!.isNotEmpty) {
      final dir = Directory(downloadFolder!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'OpenScore'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}

class DownloadStore {
  DownloadStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<DownloadStore> open() async {
    return DownloadStore(await SharedPreferences.getInstance());
  }

  List<DownloadedItem> list() {
    final raw = _prefs.getString(AppSettings._kDownloads);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(DownloadedItem.fromJson)
        .toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  Future<void> add(DownloadedItem item) async {
    final items = list();
    items.removeWhere((e) => e.path == item.path);
    items.insert(0, item);
    await _prefs.setString(
      AppSettings._kDownloads,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> remove(String path) async {
    final items = list().where((e) => e.path != path).toList();
    await _prefs.setString(
      AppSettings._kDownloads,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
