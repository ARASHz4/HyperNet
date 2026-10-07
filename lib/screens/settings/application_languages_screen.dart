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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
      ),
      body: RadioGroup<int>(
        groupValue: selectedIndex,
        onChanged: (index) {
          if (index == null) return;
          setState(() {
            selectedIndex = index;
          });

          selectLanguage(selectedIndex);
        },
        child: ListView.separated(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            var language = languages[index];
            return RadioListTile<int>(
              value: index,
              title: Text(language.name == "system" ? l10n.system : language.name),
              subtitle: language.nativeName.isNotEmpty
                  ? Text(language.nativeName)
                  : null,
            );
          },
          separatorBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(64, 0, 16, 0),
              child: Divider(height: 1),
            );
          },
        ),
      ),
    );
  }

  void selectLanguage(int index) {
    Preferences.setApplicationLanguage(index);

    context.read<ApplicationCubit>().changeLanguage(languages[index]);
  }
}
