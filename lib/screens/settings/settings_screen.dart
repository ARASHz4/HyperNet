import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_net/application.dart';
import 'package:hyper_net/extensions.dart';
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:hyper_net/screens/settings/about_screen.dart';
import 'package:hyper_net/screens/settings/application_appearance_screen.dart';
import 'package:hyper_net/screens/settings/application_languages_screen.dart';
import 'package:hyper_net/screens/settings/routing_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeTheme = context.watch<ApplicationCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.appearance),
            subtitle: Text(_appearanceLabel(localeTheme.$2, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.navigatorPush(
              screen: ApplicationAppearanceScreen(
                appearance: ThemeMode.values.indexOf(localeTheme.$2),
              ),
            ),
          ),
          const Divider(height: 1, indent: 64),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(_languageLabel(localeTheme.$1, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.navigatorPush(
              screen: ApplicationLanguageScreen(
                language: localeTheme.$1 == null
                    ? languages[0]
                    : languages.firstWhere(
                        (element) => element.code == localeTheme.$1!.languageCode,
                        orElse: () => languages[0],
                      ),
              ),
            ),
          ),
          const Divider(height: 1, indent: 64),
          ListTile(
            leading: const Icon(Icons.alt_route),
            title: Text(l10n.routing),
            subtitle: Text(l10n.routingSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.navigatorPush(screen: const RoutingScreen()),
          ),
          const Divider(height: 1, indent: 64),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.navigatorPush(screen: const AboutScreen()),
          ),
        ],
      ),
    );
  }

  String _appearanceLabel(ThemeMode mode, AppLocalizations l10n) {
    return switch (mode) {
      ThemeMode.light => l10n.lightMode,
      ThemeMode.dark => l10n.darkMode,
      _ => l10n.system,
    };
  }

  String _languageLabel(Locale? locale, AppLocalizations l10n) {
    if (locale == null) return l10n.system;

    final language = languages.firstWhere(
      (element) => element.code == locale.languageCode,
      orElse: () => languages[0],
    );
    return language.name == 'system' ? l10n.system : language.name;
  }
}
