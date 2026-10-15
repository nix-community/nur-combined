import 'package:flutter/material.dart';
import '../widgets/settings_dialog.dart';

class DialScreen extends StatefulWidget {
  final String proxyUrl;
  final Function(String proxyUrl) onUpdateSettings;
  final Function(String recipient, String callerName, String callerPhone, String notes, String state) onStartCall;

  const DialScreen({
    super.key,
    required this.proxyUrl,
    required this.onUpdateSettings,
    required this.onStartCall,
  });

  @override
  State<DialScreen> createState() => _DialScreenState();
}

class _DialScreenState extends State<DialScreen> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedState = 'NSW';

  final List<String> _states = const ['NSW', 'VIC', 'QLD', 'WA', 'SA', 'TAS', 'ACT', 'NT'];

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setPreset(String number, [String? notes]) {
    setState(() {
      _numberController.text = number;
      if (notes != null) {
        _notesController.text = notes;
      }
    });
  }

  void _confirmEmergencyCall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning, color: Colors.red, size: 48),
        title: const Text(
          'EMERGENCY CALL: TRIPLE ZERO (000)',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You are about to initiate an emergency call to Triple Zero (000).\n\n'
          'The Relay Officer will immediately connect you with Police, Fire, or Ambulance.\n\n'
          'Do you wish to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              _setPreset('000', 'EMERGENCY TRIPLE ZERO');
              widget.onStartCall(
                '000',
                _nameController.text.trim(),
                _phoneController.text.trim(),
                'EMERGENCY TRIPLE ZERO',
                _selectedState,
              );
            },
            child: const Text('Connect to 000 Now'),
          ),
        ],
      ),
    );
  }

  void _submitCall() {
    final number = _numberController.text.trim();
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number to call')),
      );
      return;
    }

    if (number == '000') {
      _confirmEmergencyCall();
      return;
    }

    widget.onStartCall(
      number,
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _notesController.text.trim(),
      _selectedState,
    );
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (ctx) => SettingsDialog(
        initialProxyUrl: widget.proxyUrl,
        onSave: widget.onUpdateSettings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.record_voice_over, color: Colors.teal),
            SizedBox(width: 8),
            Text('NRS Internet Relay'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Connection Settings',
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Emergency 000 Fast Access Card
            Card(
              color: Colors.red.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade300, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.emergency, color: Colors.red, size: 36),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency: Triple Zero (000)',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          Text(
                            'Police • Fire • Ambulance priority relay',
                            style: TextStyle(fontSize: 12, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _confirmEmergencyCall,
                      child: const Text('Call 000'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recipient Number Input
            const Text(
              'Who would you like to call?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 20, letterSpacing: 1.2),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g. 0412 345 678, (02) 9876 5432, 1800...',
                prefixIcon: const Icon(Icons.phone),
                suffixIcon: _numberController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _numberController.clear()),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Australian State selection
            DropdownButtonFormField<String>(
              initialValue: _selectedState,
              decoration: const InputDecoration(

                labelText: 'State / Territory',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedState = val);
                }
              },
            ),
            const SizedBox(height: 16),

            // Australian Presets
            const Text(
              'Common Australian Numbers:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.headset_mic, size: 16),
                  label: const Text('NRS Helpdesk (1800 555 660)'),
                  onPressed: () => _setPreset('1800 555 660', 'Calling NRS Helpdesk for support'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.local_police, size: 16),
                  label: const Text('Police Assistance (131 444)'),
                  onPressed: () => _setPreset('131 444', 'Police Non-Emergency assistance'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.medical_services, size: 16),
                  label: const Text('healthdirect (1800 022 222)'),
                  onPressed: () => _setPreset('1800 022 222', 'Health helpline'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Relay Officer Notes / Instructions
            const Text(
              'Instructions for the Relay Officer (Optional):',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g. "Ask for the Accounts Dept", "I am d/Deaf, please tell them I am typing"',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Optional Caller Profile
            ExpansionTile(
              title: const Text('Caller Details (Optional)', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Your name and registered NRS profile number', style: TextStyle(fontSize: 12)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name / Nickname',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Your Registered Number (if applicable)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Start Call Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal.shade700,
              ),
              onPressed: _submitCall,
              icon: const Icon(Icons.phone_forwarded, size: 22),
              label: const Text(
                'Start NRS Internet Relay Call',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
