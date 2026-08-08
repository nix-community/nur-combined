import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';
import 'src/bindings/bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uplink Pastebin',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  String _status = '';

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_keyHandler);
    UploadTextResponse.rustSignalStream.listen((event) {
      setState(() {
        _status = event.message.url ?? event.message.error ?? '';
      });
    });

    UploadFileResponse.rustSignalStream.listen((event) {
      setState(() {
        _status = event.message.url ?? event.message.error ?? '';
      });
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyHandler);
    super.dispose();
  }

  bool _keyHandler(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyV) {
      if (HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed) {
        _handlePaste();
      }
    }
    return false;
  }

  Future<void> _handlePaste() async {
    final imageBytes = await Pasteboard.image;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      setState(() => _status = "Uploading pasted image...");
      UploadFileRequest(filename: "pasted_image.png").sendSignalToRust(imageBytes);
    }
  }

  void _uploadText() {
    UploadTextRequest(text: _textController.text).sendSignalToRust();
  }

  Future<void> _uploadFile({bool imageOnly = false}) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: imageOnly ? FileType.image : FileType.any,
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final filename = result.files.single.name;
      UploadFileRequest(filename: filename).sendSignalToRust(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uplink Pastebin')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Text to Paste',
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _uploadText, 
                        child: const Text('Upload Text')
                      ),
                      ElevatedButton(
                        onPressed: () => _uploadFile(imageOnly: true), 
                        child: const Text('Upload Image')
                      ),
                      ElevatedButton(
                        onPressed: () => _uploadFile(imageOnly: false), 
                        child: const Text('Upload File')
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SelectableText(
                    _status, 
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
