import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyper_net/extensions.dart';
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:hyper_net/preferences.dart';
import 'package:hyper_net/screens/settings/routing_config.dart';

class RoutingScreen extends StatefulWidget {
  const RoutingScreen({super.key});

  @override
  State<RoutingScreen> createState() => _RoutingScreenState();
}

class _RoutingScreenState extends State<RoutingScreen> {
  late final TextEditingController _domainsController;
  late final TextEditingController _appsController;
  List<String> blockedDomains = [];
  List<String> blockedApps = [];

  @override
  void initState() {
    super.initState();
    _domainsController = TextEditingController();
    _appsController = TextEditingController();
    _loadRules();
  }

  Future<void> _loadRules() async {
    final domains = await Preferences.bypassDomains();
    final apps = await Preferences.bypassApps();
    if (!mounted) return;

    setState(() {
      blockedDomains = domains;
      blockedApps = apps;
      _domainsController.text = domains.join('\n');
      _appsController.text = apps.join('\n');
    });
  }

  @override
  void dispose() {
    _domainsController.dispose();
    _appsController.dispose();
    super.dispose();
  }

  void _applyRouting() {
    final domains = _domainsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final apps = _appsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    try {
      for (final domain in domains) {
        normalizeDomainEntry(domain);
      }
    } on FormatException catch (_) {
      if (!mounted) return;
      context.showSnackBar(message: AppLocalizations.of(context)!.invalidDomainEntry);
      return;
    }

    setState(() {
      blockedDomains = domains;
      blockedApps = apps;
    });

    Preferences.setBypassDomains(domains);
    Preferences.setBypassApps(apps);

    if (!mounted) return;
    context.showSnackBar(message: AppLocalizations.of(context)!.routingRulesSaved);
  }

  void _clearRouting() {
    _domainsController.clear();
    _appsController.clear();
    setState(() {
      blockedDomains = [];
      blockedApps = [];
    });
    Preferences.setBypassDomains([]);
    Preferences.setBypassApps([]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.routingTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: colorScheme.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Traffic matching these domains or apps will bypass the VPN tunnel and connect directly. Reconnect the VPN after applying rules.',
                              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _section(
                      title: l10n.bypassDomains,
                      controller: _domainsController,
                      count: blockedDomains.length,
                      hint: 'example.com\n*.google.com\ngeosite:ir\nregexp:^.*\\.local\$',
                      icon: Icons.language_rounded,
                    ),
                    if (Platform.isAndroid) ...[
                      const SizedBox(height: 16),
                      _section(
                        title: l10n.bypassApps,
                        controller: _appsController,
                        count: blockedApps.length,
                        hint: 'com.example.bank\ncom.google.android.youtube',
                        icon: Icons.apps_rounded,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _applyRouting,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(l10n.applyRules),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearRouting,
                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                    label: Text(l10n.clear),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required TextEditingController controller,
    required int count,
    required String hint,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
