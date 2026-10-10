import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:hyper_net/models/language.dart';
import 'package:hyper_net/preferences.dart';
import 'package:hyper_net/screens/home/home_screen.dart';
import 'package:hyper_net/screens/home/bloc/home_bloc.dart';

final List<Language> languages = [
  Language(
    id: 0,
    name: "system",
    code: "",
    country: "",
    nativeName: "",
    isRTL: false,
    calendar: Calendar.gregorian,
  ),
  Language(
    id: 1,
    name: "English",
    code: "en",
    country: "US",
    nativeName: "English",
    isRTL: false,
    calendar: Calendar.gregorian,
  ),
  Language(
    id: 2,
    name: "Persian",
    code: "fa",
    country: "IR",
    nativeName: "فارسی",
    isRTL: true,
    calendar: Calendar.solarJalali,
  ),
];

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ApplicationCubit()),
        BlocProvider(create: (_) => HomeBloc()),
      ],
      child: const ApplicationView(),
    );
  }
}

class ApplicationView extends StatelessWidget {
  const ApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ApplicationCubit>().loadApplicationLanguageTheme();

    return BlocBuilder<ApplicationCubit, (Locale?, ThemeMode)>(
      builder: (_, localeTheme) {
        return MaterialApp(
          title: 'HyperNet',
          navigatorKey: navigatorKey,
          home: const HomeScreen(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeTheme.$1,
          themeMode: localeTheme.$2,
          builder: EasyLoading.init(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
        );
      },
    );
  }
}

class ApplicationCubit extends Cubit<(Locale?, ThemeMode)> {
  ApplicationCubit() : super(const (null, ThemeMode.system));

  Future<void> loadApplicationLanguageTheme() async {
    final language = await Preferences.applicationLanguage();
    final theme = await Preferences.appearance();

    Locale? locale;
    ThemeMode themeMode;

    if (language.name == "system") {
      locale = null;
    } else {
      locale = Locale(language.code, language.country);
    }

    if (theme > 2) {
      Preferences.setAppearance(0);
      themeMode = ThemeMode.system;
    } else {
      themeMode = ThemeMode.values[theme];
    }

    emit((locale, themeMode));
  }

  void changeLanguage(Language language) {
    Locale? locale;

    if (language.name == "system") {
      locale = null;
    } else {
      locale = Locale(language.code, language.country);
    }

    emit((locale, state.$2));
  }

  void changeTheme(ThemeMode themeMode) {
    emit((state.$1, themeMode));
  }
}
