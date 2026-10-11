import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_net/application.dart';
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:hyper_net/preferences.dart';

class ApplicationAppearanceScreen extends StatefulWidget {
  const ApplicationAppearanceScreen({super.key, required this.appearance});

  final int appearance;

  @override
  State<ApplicationAppearanceScreen> createState() =>
      _ApplicationAppearanceScreenState();
}

class _ApplicationAppearanceScreenState
    extends State<ApplicationAppearanceScreen> {
  late int selectedIndex;

  @override
  void initState() {
    selectedIndex = widget.appearance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final options = [
      (
        title: l10n.system,
        subtitle: 'Follow system setting',
        icon: Icons.brightness_auto_rounded,
      ),
      (
        title: l10n.lightMode,
        subtitle: 'Clean & bright theme',
        icon: Icons.light_mode_rounded,
      ),
      (
        title: l10n.darkMode,
        subtitle: 'Deep dark obsidian theme',
        icon: Icons.dark_mode_rounded,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appearance,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final option = options[index];

          return Card(
            margin: EdgeInsets.zero,
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.35)
                : colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                Preferences.setAppearance(selectedIndex);
                context.read<ApplicationCubit>().changeTheme(ThemeMode.values[selectedIndex]);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.15)
                            : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        option.icon,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      )
                    else
                      Icon(
                        Icons.circle_outlined,
                        color: colorScheme.outlineVariant,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
