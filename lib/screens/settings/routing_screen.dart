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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.routingTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _section(l10n.bypassDomains, _domainsController),
                    const SizedBox(height: 12),
                    if (Platform.isAndroid)
                      _section(l10n.bypassApps, _appsController),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _applyRouting,
                    child: Text(l10n.applyRules),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _clearRouting,
                  child: Text(l10n.clear),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, TextEditingController controller) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
