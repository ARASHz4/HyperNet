import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_net/application.dart';
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:hyper_net/models/language.dart';
import 'package:hyper_net/preferences.dart';

class ApplicationLanguageScreen extends StatefulWidget {
  const ApplicationLanguageScreen({super.key, required this.language});

  final Language language;

  @override
  State<ApplicationLanguageScreen> createState() =>
      _ApplicationLanguageScreenState();
}

class _ApplicationLanguageScreenState
    extends State<ApplicationLanguageScreen> {
  late int selectedIndex;

  @override
  void initState() {
    selectedIndex = widget.language.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.language,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: languages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final language = languages[index];

          final flag = switch (language.code) {
            'en' => '🇺🇸',
            'fa' => '🇮🇷',
            _ => '🌐',
          };

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
                selectLanguage(selectedIndex);
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
                      alignment: Alignment.center,
                      child: Text(
                        flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.name == "system" ? l10n.system : language.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                          if (language.nativeName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              language.nativeName,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
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

  void selectLanguage(int index) {
    Preferences.setApplicationLanguage(index);
    context.read<ApplicationCubit>().changeLanguage(languages[index]);
  }
}
