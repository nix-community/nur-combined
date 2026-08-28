import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const version = '0.1.0';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('About', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('OpenScore'),
            subtitle: Text('Version $version'),
          ),
          const Text(
            'Open-source MuseScore sheet music downloader. '
            'Download logic is based on the MIT-licensed dl-librescore project.\n\n'
            'Not affiliated with MuseScore, Ultimate Guitar, or LibreScore.',
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.code),
            title: const Text('dl-librescore (upstream logic)'),
            onTap: () => launchUrl(
              Uri.parse('https://github.com/LibreScore/dl-librescore'),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.gavel),
            title: const Text('License'),
            subtitle: const Text('MIT'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'OpenScore',
                applicationVersion: version,
              );
            },
          ),
        ],
      ),
    );
  }
}
