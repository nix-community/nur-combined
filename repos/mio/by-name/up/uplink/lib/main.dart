import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'src/bindings/bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeRust();
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

  void _uploadText() {
    UploadTextRequest(text: _textController.text).sendSignalToRust();
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      UploadFileRequest(path: result.files.single.path!).sendSignalToRust();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uplink Pastebin')),
      body: Column(
        children: [
          TextField(controller: _textController),
          ElevatedButton(onPressed: _uploadText, child: const Text('Upload Text')),
          Text(_status),
        ],
      ),
    );
  }
}
