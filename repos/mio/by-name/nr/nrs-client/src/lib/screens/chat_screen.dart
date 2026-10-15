import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../src/bindings/signals/signals.dart';

class RelayChatMessage {
  final String id;
  final String timestamp;
  final String sender;
  final String content;
  final bool hasGa;

  RelayChatMessage({
    required this.id,
    required this.timestamp,
    required this.sender,
    required this.content,
    required this.hasGa,
  });
}

class ChatScreen extends StatefulWidget {
  final String recipientNumber;
  final VoidCallback onCallFinished;

  const ChatScreen({
    super.key,
    required this.recipientNumber,
    required this.onCallFinished,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<RelayChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _appendGa = true;
  String _callState = 'connecting';
  String _statusMessage = 'Connecting...';
  String _roBadge = '';
  int _durationSecs = 0;
  String? _errorDetail;

  StreamSubscription? _callStateSub;
  StreamSubscription? _messageSub;
  StreamSubscription? _transcriptSub;

  @override
  void initState() {
    super.initState();

    _callStateSub = CallStateSignal.rustSignalStream.listen((pack) {
      if (!mounted) return;
      final msg = pack.message;
      setState(() {
        _callState = msg.state;
        _statusMessage = msg.statusMessage;
        _roBadge = msg.officerBadge;
        _durationSecs = msg.durationSeconds.toInt();
        _errorDetail = msg.errorDetail;
      });
    });

    _messageSub = RelayMessageSignal.rustSignalStream.listen((pack) {
      if (!mounted) return;
      final msg = pack.message;
      setState(() {
        _messages.add(RelayChatMessage(
          id: msg.id,
          timestamp: msg.timestamp,
          sender: msg.sender,
          content: msg.content,
          hasGa: msg.hasGa,
        ));
      });
      _scrollToBottom();
    });

    _transcriptSub = TranscriptExportedSignal.rustSignalStream.listen((pack) {
      if (!mounted) return;
      final msg = pack.message;
      _showExportDialog(msg.filename, msg.content);
    });
  }

  @override
  void dispose() {
    _callStateSub?.cancel();
    _messageSub?.cancel();
    _transcriptSub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    SendRelayMessageRequest(
      text: text,
      appendGa: _appendGa,
    ).sendSignalToRust();

    _textController.clear();
  }

  void _triggerQuickAction(String action) {
    QuickActionRequest(actionType: action).sendSignalToRust();
  }

  void _confirmEndCall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Call?'),
        content: const Text('Are you sure you want to hang up and terminate this relay session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              DisconnectCallRequest(reason: 'User disconnected').sendSignalToRust();
            },
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(String filename, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.description, color: Colors.teal),
            const SizedBox(width: 8),
            Text(filename),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transcript copied to clipboard!')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _getStateColor() {
    switch (_callState) {
      case 'connected':
        return Colors.green;
      case 'connecting':
      case 'queued':
      case 'officer_assigned':
      case 'dialing':
      case 'ringing':
        return Colors.blue;
      case 'on_hold':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'ended':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCallActive = _callState != 'ended' && _callState != 'error';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.recipientNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (_roBadge.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _roBadge,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                ],
              ],
            ),
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: _getStateColor()),
                const SizedBox(width: 4),
                Text(
                  _callState.toUpperCase(),
                  style: TextStyle(fontSize: 11, color: _getStateColor(), fontWeight: FontWeight.w600),
                ),
                if (isCallActive) ...[
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_durationSecs),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Export Transcript',
            icon: const Icon(Icons.download),
            onPressed: () {
              ExportTranscriptRequest(format: 'txt').sendSignalToRust();
            },
          ),
          if (isCallActive)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _confirmEndCall,
                icon: const Icon(Icons.call_end, size: 18),
                label: const Text('Hang Up'),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilledButton.tonal(
                onPressed: widget.onCallFinished,
                child: const Text('Back to Dialer'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Status Notification banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _getStateColor().withValues(alpha: 0.12),
            child: Row(
              children: [
                Icon(
                  _callState == 'error' ? Icons.error_outline : Icons.info_outline,
                  size: 16,
                  color: _getStateColor(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(fontSize: 13, color: _getStateColor(), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          if (_errorDetail != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.withValues(alpha: 0.1),
              child: Text(
                _errorDetail!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),

          // Message Transcript
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageItem(msg);
              },
            ),
          ),

          // Quick Turn-Taking & Action Bar
          if (isCallActive) ...[
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickButton('GA', 'GA', isPrimary: true),
                    _buildQuickButton('GA to SK', 'GA_TO_SK'),
                    _buildQuickButton('SK', 'SK'),
                    _buildQuickButton('Repeat', 'REPEAT'),
                    _buildQuickButton('Spell', 'SPELL'),
                    _buildQuickButton(
                      _callState == 'on_hold' ? 'Resume' : 'Hold',
                      _callState == 'on_hold' ? 'RESUME' : 'HOLD',
                    ),
                  ],
                ),
              ),
            ),

            // Text Input & Composer
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _appendGa,
                          onChanged: (val) => setState(() => _appendGa = val ?? true),
                        ),
                        const Text(
                          'Append "GA" (Go Ahead)',
                          style: TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        const Text(
                          'Relay Convention: Type "GA" when done talking',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: const InputDecoration(
                              hintText: 'Type your message to the Relay Officer...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _sendMessage,
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, String actionCode, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          backgroundColor: isPrimary ? Colors.teal.withValues(alpha: 0.15) : null,
          side: BorderSide(color: isPrimary ? Colors.teal : Colors.grey.shade400),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: () => _triggerQuickAction(actionCode),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
            color: isPrimary ? Colors.teal : null,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(RelayChatMessage msg) {
    if (msg.sender == 'officer_system' || msg.sender == 'system') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.support_agent, size: 16, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '[RO SYSTEM] ${msg.content}',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            Text(
              msg.timestamp,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final isUser = msg.sender == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUser
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUser ? 'YOU' : 'OTHER PARTY (via RO)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.teal : Colors.deepOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  msg.timestamp,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              msg.content,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
