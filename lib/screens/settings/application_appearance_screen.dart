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
  List<String> appearances = [];

  late int selectedIndex;

  @override
  void initState() {
    selectedIndex = widget.appearance;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final l10n = AppLocalizations.of(context)!;
    appearances = [l10n.system, l10n.lightMode, l10n.darkMode];

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appearance),
      ),
      body: RadioGroup<int>(
        groupValue: selectedIndex,
        onChanged: (index) {
          if (index == null) return;
          setState(() {
            selectedIndex = index;
          });

          Preferences.setAppearance(selectedIndex);

          context
              .read<ApplicationCubit>()
              .changeTheme(ThemeMode.values[selectedIndex]);
        },
        child: ListView.separated(
          itemCount: appearances.length,
          itemBuilder: (context, index) {
            return RadioListTile<int>(
              value: index,
              title: Text(appearances[index]),
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
}
