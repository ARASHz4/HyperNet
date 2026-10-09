import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:hyper_net/screens/home/bloc/home_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                Image.asset('assets/icon.png', height: 196),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                FutureBuilder<String>(
                  future: getAppVersion(), builder: (context, snapshot) {
                    final version = snapshot.data ?? "";

                    if (version.isNotEmpty) {
                      return Text('${l10n.versionLabel} $version');
                    }

                    return const SizedBox.shrink();
                  },
                ),
                FutureBuilder<String>(
                  future: context.read<HomeBloc>().getXrayCoreVersion(),
                  builder: (context, snapshot) {
                    final xrayCoreVersion = snapshot.data ?? "";

                    if (xrayCoreVersion.isNotEmpty) {
                      return Text('${l10n.xrayCoreVersion} $xrayCoreVersion');
                    }

                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.aboutDescription,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();

    return info.version;
  }
}
