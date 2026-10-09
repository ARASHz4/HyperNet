import 'package:flutter/material.dart';
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;

    setState(() {
      _version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Image.asset('assets/icon.png', height: 96),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (_version.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('${l10n.versionLabel} $_version'),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n.aboutDescription,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: Text(l10n.aboutCore),
            subtitle: const Text('Xray'),
          ),
        ],
      ),
    );
  }
}
