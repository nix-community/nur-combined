import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'src/bindings/bindings.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:rinf/rinf.dart';
import 'package:share_plus/share_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeRust(assignRustSignal);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uplink Pastebin',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  String _status = '';
  bool _isUploading = false;
  /// Null = indeterminate; 0.0–1.0 when Rust reports a known total.
  double? _uploadProgress;
  final List<StreamSubscription<dynamic>> _signalSubs = [];

  @override
  void initState() {
    super.initState();
    _signalSubs.add(
      UploadTextResponse.rustSignalStream.listen((event) {
        setState(() {
          _status = event.message.url ?? event.message.error ?? '';
          _isUploading = false;
          _uploadProgress = null;
        });
      }),
    );

    _signalSubs.add(
      UploadFileResponse.rustSignalStream.listen((event) {
        setState(() {
          _status = event.message.url ?? event.message.error ?? '';
          _isUploading = false;
          _uploadProgress = null;
        });
      }),
    );

    _signalSubs.add(
      UploadProgress.rustSignalStream.listen((event) {
        final total = event.message.bytesTotal.toInt();
        final sent = event.message.bytesSent.toInt();
        if (!mounted || !_isUploading) return;
        setState(() {
          _uploadProgress = total > 0 ? (sent / total).clamp(0.0, 1.0) : null;
        });
      }),
    );

    if (_isDesktop) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    }

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLinuxTheme();
    });
  }

  @override
  void didChangePlatformBrightness() {
    _updateLinuxTheme();
  }

  void _updateLinuxTheme() {
    if (!kIsWeb && Platform.isLinux) {
      final brightness = PlatformDispatcher.instance.platformBrightness;
      const MethodChannel(
        'app.uplink/theme',
      ).invokeMethod('setTheme', {'dark': brightness == Brightness.dark});
    }
  }

  @override
  void dispose() {
    for (final sub in _signalSubs) {
      sub.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    if (_isDesktop) {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }
    _textController.dispose();
    super.dispose();
  }

  bool get _isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  bool get _usesMetaForPaste => defaultTargetPlatform == TargetPlatform.macOS;

  String get _pasteShortcutLabel => _usesMetaForPaste ? 'Cmd+V' : 'Ctrl+V';

  bool get _isImagePasteShortcutPressed {
    if (!_isDesktop) return false;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isAltPressed || keyboard.isShiftPressed) return false;
    if (_usesMetaForPaste) {
      return keyboard.isMetaPressed && !keyboard.isControlPressed;
    }
    return keyboard.isControlPressed && !keyboard.isMetaPressed;
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.keyV) return false;
    if (!_isImagePasteShortcutPressed) return false;
    _handlePaste(fromShortcut: true);
    return false;
  }

  Future<void> _handlePaste({bool fromShortcut = false}) async {
    if (_isUploading) return;
    if (!fromShortcut) {
      setState(() {
        _isUploading = true;
        _uploadProgress = null;
        _status = 'Reading clipboard...';
      });
    }
    try {
      final imageBytes = await Pasteboard.image;
      if (!mounted) return;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        setState(() {
          _isUploading = true;
          _uploadProgress = null;
          _status = 'Uploading pasted image...';
        });
        UploadFileRequest(
          filename: 'pasted_image.png',
        ).sendSignalToRust(imageBytes);
      } else if (!fromShortcut) {
        setState(() {
          _status = 'No image found on clipboard!';
          _isUploading = false;
          _uploadProgress = null;
        });
      }
    } catch (e) {
      if (fromShortcut) return;
      setState(() {
        _status = 'Clipboard error: $e';
        _isUploading = false;
        _uploadProgress = null;
      });
    }
  }

  void _uploadText() {
    if (_isUploading) return;
    if (_textController.text.trim().isEmpty) {
      setState(() {
        _status = 'Please enter some text first.';
      });
      return;
    }
    setState(() {
      _isUploading = true;
      _uploadProgress = null;
      _status = 'Uploading text...';
    });
    UploadTextRequest(text: _textController.text).sendSignalToRust();
  }

  Future<void> _uploadFile({bool imageOnly = false}) async {
    if (_isUploading) return;
    FilePickerResult? result = await FilePicker.pickFiles(
      type: imageOnly ? FileType.image : FileType.any,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _isUploading = true;
        _uploadProgress = null;
        _status = 'Uploading file...';
      });
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final filename = result.files.single.name;
      UploadFileRequest(filename: filename).sendSignalToRust(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Uplink Pastebin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 64,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Type or paste text here...',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        maxLines: 5,
                        minLines: 3,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _uploadText,
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Upload Text'),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _uploadFile(imageOnly: false),
                            icon: const Icon(Icons.insert_drive_file),
                            label: const Text('Select File to Upload'),
                          ),
                        ],
                      ),
                      if (_isUploading || _status.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_isUploading) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _uploadProgress,
                                    minHeight: 8,
                                  ),
                                ),
                                if (_uploadProgress != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(100 * _uploadProgress!).round()}%',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      _status,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (!_isUploading &&
                                      _status.startsWith('http')) ...[
                                    IconButton(
                                      icon: const Icon(
                                        Icons.copy,
                                        color: Colors.blue,
                                      ),
                                      tooltip: 'Copy link',
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: _status),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Link copied to clipboard!',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (!kIsWeb &&
                                        (Platform.isAndroid || Platform.isIOS))
                                      IconButton(
                                        icon: const Icon(
                                          Icons.share,
                                          color: Colors.blue,
                                        ),
                                        tooltip: 'Share link',
                                        onPressed: () {
                                          Share.share(_status);
                                        },
                                      ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: _handlePaste,
                        icon: const Icon(
                          Icons.paste,
                          size: 16,
                          color: Colors.grey,
                        ),
                        label: const Text(
                          'Paste Image from Clipboard',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      if (_isDesktop)
                        Text(
                          'Tip: You can press $_pasteShortcutLabel anywhere!',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
