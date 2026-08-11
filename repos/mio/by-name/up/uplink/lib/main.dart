import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
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

  @override
  void initState() {
    super.initState();
    UploadTextResponse.rustSignalStream.listen((event) {
      setState(() {
        _status = event.message.url ?? event.message.error ?? '';
        _isUploading = false;
      });
    });

    UploadFileResponse.rustSignalStream.listen((event) {
      setState(() {
        _status = event.message.url ?? event.message.error ?? '';
        _isUploading = false;
      });
    });
    
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    
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
      const MethodChannel('app.uplink/theme').invokeMethod('setTheme', {'dark': brightness == Brightness.dark});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _textController.dispose();
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyV) {
      final isControlPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
                               HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight) ||
                               HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaLeft) ||
                               HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaRight);
      if (isControlPressed) {
        _handlePaste();
        return false; // let it propagate just in case
      }
    }
    return false;
  }

  Future<void> _handlePaste() async {
    if (_isUploading) return;
    setState(() {
      _isUploading = true;
      _status = 'Reading clipboard...';
    });
    try {
      final imageBytes = await Pasteboard.image;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        setState(() {
          _status = 'Uploading pasted image...';
        });
        UploadFileRequest(filename: 'pasted_image.png').sendSignalToRust(imageBytes);
      } else {
        setState(() {
          _status = 'No image found on clipboard!';
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Clipboard error: $e';
        _isUploading = false;
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
        title: const Text('Uplink Pastebin', style: TextStyle(fontWeight: FontWeight.bold)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.blueAccent),
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
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _uploadText, 
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Upload Text'),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _uploadFile(imageOnly: false), 
                            icon: const Icon(Icons.insert_drive_file),
                            label: const Text('Select File to Upload'),
                          ),
                        ],
                      ),
                      if (_status.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  _status, 
                                  style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (_status.startsWith('http')) ...[
                                IconButton(
                                  icon: const Icon(Icons.copy, color: Colors.blue),
                                  tooltip: 'Copy link',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _status));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Link copied to clipboard!')),
                                    );
                                  },
                                ),
                                if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.blue),
                                    tooltip: 'Share link',
                                    onPressed: () {
                                      Share.share(_status);
                                    },
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: _handlePaste,
                        icon: const Icon(Icons.paste, size: 16, color: Colors.grey),
                        label: const Text('Paste Image from Clipboard', style: TextStyle(color: Colors.grey)),
                      ),
                      const Text(
                        "Tip: Desktop users can press Ctrl+V anywhere!",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
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
