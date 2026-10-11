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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _settingsTile(
                    context,
                    icon: Icons.palette_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    title: l10n.appearance,
                    subtitle: _appearanceLabel(localeTheme.$2, l10n),
                    onTap: () => context.navigatorPush(
                      screen: ApplicationAppearanceScreen(
                        appearance: ThemeMode.values.indexOf(localeTheme.$2),
                      ),
                    ),
                  ),
                  _divider(context),
                  _settingsTile(
                    context,
                    icon: Icons.language_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    title: l10n.language,
                    subtitle: _languageLabel(localeTheme.$1, l10n),
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
                  _divider(context),
                  _settingsTile(
                    context,
                    icon: Icons.alt_route_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: l10n.routing,
                    subtitle: l10n.routingSubtitle,
                    onTap: () => context.navigatorPush(screen: const RoutingScreen()),
                  ),
                  _divider(context),
                  _settingsTile(
                    context,
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: l10n.about,
                    subtitle: l10n.aboutDescription,
                    onTap: () => context.navigatorPush(screen: const AboutScreen()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${l10n.appTitle} • Xray Core',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 22,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
      onTap: onTap,
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 68,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
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
    if (locale == null) {
      return l10n.system;
    }

    final language = languages.firstWhere(
      (element) => element.code == locale.languageCode,
      orElse: () => languages[0],
    );

    return language.name == 'system' ? l10n.system : language.nativeName;
  }
}
