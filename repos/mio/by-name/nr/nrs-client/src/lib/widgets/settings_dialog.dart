import 'dart:async';
import 'package:flutter/material.dart';
import '../src/bindings/signals/signals.dart';

class SettingsDialog extends StatefulWidget {
  final String initialProxyUrl;
  final String initialCountry;
  final Function(String proxyUrl, String country) onSave;

  const SettingsDialog({
    super.key,
    required this.initialProxyUrl,
    this.initialCountry = 'AU',
    required this.onSave,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late final TextEditingController _proxyController;
  late String _selectedCountry;
  StreamSubscription? _geoSub;
  String _geoStatus = 'untested';
  String _geoDetails = 'Click "Test Connection" to check relay gateway reachability';
  String _detectedIp = '';
  String _country = '';
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _proxyController = TextEditingController(text: widget.initialProxyUrl);
    _selectedCountry = widget.initialCountry;

    _geoSub = GeoStatusSignal.rustSignalStream.listen((pack) {
      if (!mounted) return;
      final msg = pack.message;
      setState(() {
        _isTesting = false;
        _geoStatus = msg.status;
        _geoDetails = msg.details;
        _detectedIp = msg.detectedIp;
        _country = msg.country;
      });
    });
  }

  @override
  void dispose() {
    _geoSub?.cancel();
    _proxyController.dispose();
    super.dispose();
  }

  void _runGeoCheck() {
    setState(() {
      _isTesting = true;
      _geoStatus = 'testing';
      _geoDetails = 'Contacting ${_selectedCountry == "NZ" ? "NZ Relay" : "NRS"} gateway and checking IP...';
    });
    final proxy = _proxyController.text.trim();
    CheckGeoStatusRequest(
      proxyUrl: proxy.isEmpty ? null : proxy,
      country: _selectedCountry,
    ).sendSignalToRust();
  }

  Color _getStatusColor() {
    switch (_geoStatus) {
      case 'direct_au':
      case 'proxy_au':
      case 'direct_nz':
      case 'proxy_nz':
        return Colors.green;
      case 'geo_blocked':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNz = _selectedCountry == 'NZ';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.tune, color: Colors.teal),
          SizedBox(width: 8),
          Text('Relay Connection & Proxy'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Relay Service Region:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'AU',
                  label: Text('Australia (NRS)'),
                  icon: Text('🇦🇺'),
                ),
                ButtonSegment<String>(
                  value: 'NZ',
                  label: Text('New Zealand (NZ Relay)'),
                  icon: Text('🇳🇿'),
                ),
              ],
              selected: {_selectedCountry},
              onSelectionChanged: (set) {
                setState(() {
                  _selectedCountry = set.first;
                });
              },
            ),
            const SizedBox(height: 14),
            Text(
              isNz ? 'NZ Relay Gateway (Auckland):' : 'NRS Gateway (Sydney):',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              isNz
                  ? 'https://www.nzrelay.co.nz\nhttps://omnicustomwebauc.concentrix.com'
                  : 'https://nrschat.nrscall.gov.au/nrs/internetrelay',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _proxyController,
              decoration: InputDecoration(
                labelText: isNz ? 'SOCKS5 / HTTP Proxy (Optional)' : 'Australian SOCKS5 / HTTP Proxy (Optional)',
                hintText: 'e.g., socks5://127.0.0.1:1080',
                helperText: isNz
                    ? 'Optional proxy for NZ Relay connection'
                    : 'Required if connecting to NRS from outside Australia',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_lock),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GeoIP & Gateway Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _isTesting ? null : _runGeoCheck,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: const Text('Test'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                border: Border.all(color: _getStatusColor()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: _getStatusColor()),
                      const SizedBox(width: 6),
                      Text(
                        _geoStatus.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                      if (_country.isNotEmpty)
                        Text(
                          ' ($countryCode: $_country)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  if (_detectedIp.isNotEmpty && _detectedIp != 'N/A')
                    Text(
                      'Detected Public IP: $_detectedIp',
                      style: const TextStyle(fontSize: 12),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _geoDetails,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave(_proxyController.text.trim(), _selectedCountry);
            Navigator.of(context).pop();
          },
          child: const Text('Save Settings'),
        ),
      ],
    );
  }

  String get countryCode => 'Country';
}
