import 'dart:async';
import 'package:flutter/material.dart';
import '../src/bindings/signals/signals.dart';
import '../widgets/settings_dialog.dart';

class DialScreen extends StatefulWidget {
  final String proxyUrl;
  final Function(String proxyUrl) onUpdateSettings;
  final Function(
    String recipient,
    String callerName,
    String callerPhone,
    String notes,
    String state, {
    String? password,
    String? token,
  }) onStartCall;
  final bool initialIsAuthenticated;
  final String? initialUserToken;
  final String? initialPhone;
  final String? initialName;
  final String? initialNrsId;
  final Function(String phone, String token, String name, String nrsId)? onLoginSuccess;
  final VoidCallback? onLogout;

  const DialScreen({
    super.key,
    required this.proxyUrl,
    required this.onUpdateSettings,
    required this.onStartCall,
    this.initialIsAuthenticated = false,
    this.initialUserToken,
    this.initialPhone,
    this.initialName,
    this.initialNrsId,
    this.onLoginSuccess,
    this.onLogout,
  });

  @override
  State<DialScreen> createState() => _DialScreenState();
}

class _DialScreenState extends State<DialScreen> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedState = 'NSW';
  bool _obscurePassword = true;
  bool _isLoggingIn = false;
  String? _loginError;

  bool _isAuthenticated = false;
  String? _userToken;
  String _displayName = '';
  String _nrsId = '';

  StreamSubscription? _authSub;

  final List<String> _states = const ['NSW', 'VIC', 'QLD', 'WA', 'SA', 'TAS', 'ACT', 'NT'];

  @override
  void initState() {
    super.initState();
    _isAuthenticated = widget.initialIsAuthenticated;
    _userToken = widget.initialUserToken;
    _displayName = widget.initialName ?? '';
    _nrsId = widget.initialNrsId ?? '';
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      _phoneController.text = widget.initialPhone!;
    }

    _authSub = AuthStatusSignal.rustSignalStream.listen((pack) {
      if (!mounted) return;
      final msg = pack.message;
      setState(() {
        _isLoggingIn = false;
        if (msg.isAuthenticated) {
          _isAuthenticated = true;
          _userToken = msg.userToken;
          _displayName = '${msg.firstName} ${msg.lastName}'.trim();
          _nrsId = msg.nrsId;
          _phoneController.text = msg.username;
          _loginError = null;
          widget.onLoginSuccess?.call(msg.username, msg.userToken, _displayName, _nrsId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.teal.shade800,
              content: Text('Logged in successfully as ${_displayName.isNotEmpty ? _displayName : msg.username}'),
            ),
          );
        } else {
          _loginError = msg.errorMessage ?? 'Login failed. Please check your credentials.';
        }
      });
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _numberController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _performLogin() {
    final phone = _phoneController.text.trim();
    final pwd = _passwordController.text;

    if (phone.isEmpty) {
      setState(() => _loginError = 'Please enter your registered NRS phone number');
      return;
    }
    if (pwd.isEmpty) {
      setState(() => _loginError = 'Please enter your account password');
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    LoginRequest(
      username: phone,
      password: pwd,
      proxyUrl: widget.proxyUrl.isEmpty ? null : widget.proxyUrl,
    ).sendSignalToRust();
  }

  void _performLogout() {
    setState(() {
      _isAuthenticated = false;
      _userToken = null;
      _passwordController.clear();
      _displayName = '';
      _nrsId = '';
      _loginError = null;
    });
    widget.onLogout?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out of NRS')),
    );
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
          'Emergency calls do NOT require an NRS login or registration.\n\n'
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
                _displayName.isNotEmpty ? _displayName : _nameController.text.trim(),
                _phoneController.text.trim(),
                'EMERGENCY TRIPLE ZERO',
                _selectedState,
                password: null,
                token: null,
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

    if (number == '000' || number == '112' || number == '911') {
      _confirmEmergencyCall();
      return;
    }

    // Standard call requires login or credentials
    if (!_isAuthenticated && (_userToken == null || _userToken!.isEmpty)) {
      final phone = _phoneController.text.trim();
      final pwd = _passwordController.text;

      if (phone.isEmpty || pwd.isEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.lock_clock, color: Colors.amber, size: 40),
            title: const Text('NRS Login Required'),
            content: const Text(
              'Australian Government regulations (since April 2021) require all users to be logged in '
              'with their registered NRS account to make standard calls.\n\n'
              'Please enter your registered phone number and password in the Account section above, '
              'or call Triple Zero (000) if this is an emergency.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    widget.onStartCall(
      number,
      _displayName.isNotEmpty ? _displayName : _nameController.text.trim(),
      _phoneController.text.trim(),
      _notesController.text.trim(),
      _selectedState,
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      token: _userToken,
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
    final colorScheme = Theme.of(context).colorScheme;

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
            // Emergency 000 Fast Access Card (Exempt from login)
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
                            'Police • Fire • Ambulance (No login required)',
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
            const SizedBox(height: 16),

            // NRS Account / Authentication Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _isAuthenticated ? Colors.teal.shade300 : colorScheme.outlineVariant,
                  width: _isAuthenticated ? 1.5 : 1.0,
                ),
              ),
              color: _isAuthenticated ? Colors.teal.shade50.withValues(alpha: 0.3) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isAuthenticated ? Icons.verified_user : Icons.account_circle,
                          color: _isAuthenticated ? Colors.teal : colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isAuthenticated ? 'NRS Registered Account' : 'NRS Account Login',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Spacer(),
                        if (_isAuthenticated)
                          Chip(
                            avatar: const Icon(Icons.check, size: 14, color: Colors.white),
                            label: const Text('Logged In', style: TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: Colors.teal.shade700,
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isAuthenticated) ...[
                      Text(
                        'Name: ${_displayName.isNotEmpty ? _displayName : "NRS User"}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('Registered Number: ${_phoneController.text}'),
                      if (_nrsId.isNotEmpty) Text('NRS ID: $_nrsId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Log Out'),
                        onPressed: _performLogout,
                      ),
                    ] else ...[
                      const Text(
                        'Mandatory for standard relay calls since April 2021. Enter your registered NRS phone number and password.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Registered NRS Phone Number',
                          hintText: 'e.g. 0412 345 678',
                          prefixIcon: Icon(Icons.phone_android),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      if (_loginError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _loginError!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: _isLoggingIn ? null : _performLogin,
                        icon: _isLoggingIn
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.login),
                        label: Text(_isLoggingIn ? 'Logging in...' : 'Log In to NRS'),
                      ),
                    ],
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
            const SizedBox(height: 20),

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
            const SizedBox(height: 24),

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
