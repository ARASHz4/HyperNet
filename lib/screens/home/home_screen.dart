import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_net/application.dart';
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hyper_net/models/subscription.dart';
import 'package:hyper_net/screens/home/bloc/home_bloc.dart';
import 'package:hyper_net/screens/settings/application_appearance_screen.dart';
import 'package:hyper_net/screens/settings/application_languages_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const SizedBox.shrink();
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icon.png', height: 28),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.appTitle),
              ],
            ),
            actions: [
              PopupMenuButton<int>(
                icon: const Icon(Icons.settings),
                itemBuilder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return [
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text(l10n.language),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Text(l10n.appearance),
                    ),
                  ];
                },
                onSelected: (value) async {
                  final cubit = context.read<ApplicationCubit>();
                  final localeTheme = cubit.state;

                  if (value == 1) {
                    final current = localeTheme.$1 == null
                        ? languages[0]
                        : languages.firstWhere(
                            (element) =>
                                element.code == localeTheme.$1!.languageCode,
                            orElse: () => languages[0],
                          );
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ApplicationLanguageScreen(language: current),
                      ),
                    );
                  } else if (value == 2) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplicationAppearanceScreen(
                          appearance: ThemeMode.values.indexOf(localeTheme.$2),
                        ),
                      ),
                    );
                  }
                },
              ),
              PopupMenuButton<int>(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child: ListTile(
                        title: Text(AppLocalizations.of(context)!.addSubscription),
                        leading: const Icon(Icons.add),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () async {
                        final url = await addSubscription(context);
                        if (url != null) {
                          context.read<HomeBloc>().add(AddSubscription(url));
                        }
                      },
                    ),
                  ];
                },
              ),
            ],
          ),
          body: state.subscriptions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, size: 64, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.noSubscriptionsYet),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () async {
                          final url = await addSubscription(context);
                          if (url != null) {
                            context.read<HomeBloc>().add(AddSubscription(url));
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: Text(AppLocalizations.of(context)!.addSubscription),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
            itemBuilder: (context, index) {
              final subscription = state.subscriptions[index];

              return ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    state.refreshing.contains(subscription.url)
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context
                              .read<HomeBloc>()
                              .add(RefreshSubscription(subscription.url));
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        subscription.getTitle ?? AppLocalizations.of(context)!.subscription,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context
                            .read<HomeBloc>()
                            .add(PingConfigs(subscription.configs));
                      },
                      icon: const Icon(Icons.speed),
                    ),
                  ],
                ),
                subtitle: _subscriptionUsage(subscription),
                leading: SizedBox(
                  width: 32,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'remove') {
                        context
                            .read<HomeBloc>()
                            .add(RemoveSubscription(subscription.url));
                      } else if (value == 'share') {
                        SharePlus.instance.share(
                          ShareParams(text: subscription.url),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'remove',
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: Text(AppLocalizations.of(context)!.removeSubscription),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'share',
                        child: ListTile(
                          leading: const Icon(Icons.share),
                          title: Text(AppLocalizations.of(context)!.shareSubscriptionUrl),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                children: List.generate(
                  subscription.configs.length,
                  (index) {
                    final config = subscription.configs[index];
                    final isSelected = identical(state.selectedConfig, config);

                    return ListTile(
                      selected: isSelected,
                      selectedTileColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      onTap: () {
                        context.read<HomeBloc>().add(SelectConfig(config));
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                          if (state.pinging.contains(config.url))
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text("Pinging...", style: TextStyle(fontSize: 9)),
                            )
                          else if (state.delays.containsKey(config.url))
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                state.delays[config.url]! < 0
                                    ? 'timeout'
                                    : '${state.delays[config.url]} ms',
                                style: TextStyle(
                                  color: state.delays[config.url]! < 0
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(config.remark),
                      subtitle: Text("${config.network} ${config.outbound1["protocol"]}"),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
            itemCount: state.subscriptions.length,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.selectedConfig != null
                ? () {
                    if (canStop(state.vlessStatus)) {
                      context.read<HomeBloc>().add(const Disconnect());
                    } else {
                      context.read<HomeBloc>().add(Connect(state.selectedConfig!));
                    }
                  }
                : null,
            label: Text(
              canStop(state.vlessStatus)
                  ? AppLocalizations.of(context)!.disconnect
                  : AppLocalizations.of(context)!.connect,
            ),
            icon: Icon(
              canStop(state.vlessStatus) ? Icons.stop : Icons.play_arrow,
            ),
          ),
        );
      },
    );
  }
}

Future<String?> addSubscription(BuildContext context) async {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final subscriptionTextController = TextEditingController();

  final resalt = await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (builderContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Text(AppLocalizations.of(context)!.addSubscription),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: subscriptionTextController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.url,
                      border: const OutlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final text = await importFromClipboard();
                              if ((text ?? "").isNotEmpty) {
                                subscriptionTextController.text = text!;
                              }
                            },
                            icon: const Icon(Icons.paste),
                          ),
                          IconButton(
                            onPressed: () async {
                              final text = await scanSubscriptionQrCode(context);
                              if (text != null) {
                                subscriptionTextController.text = text;
                              }
                            },
                            icon: const Icon(Icons.qr_code_scanner),
                          ),
                        ],
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? "").isEmpty) {
                        return AppLocalizations.of(context)!.enterSubscriptionUrl;
                      }

                      return null;
                    },
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(builderContext);
                      },
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(builderContext, subscriptionTextController.text);
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (resalt is String) {
    return resalt;
  }

  return null;
}

bool isSubscriptionUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
}

Future<String?> scanSubscriptionQrCode(BuildContext context) async {
  final result = await Navigator.push<String?>(
    context,
    MaterialPageRoute(
      builder: (_) => const QrScanScreen(),
    ),
  );

  if (result == null) return null;

  if (isSubscriptionUrl(result)) {
    return result;
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code is not a valid subscription link.')),
    );
  }

  return null;
}

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scanQrCode),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_done) return;

          final code = capture.barcodes.isNotEmpty
              ? capture.barcodes.first.rawValue
              : null;

          if (code != null) {
            _done = true;
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}

Future<String?> importFromClipboard() async {
  if (await Clipboard.hasStrings()) {
    return (await Clipboard.getData('text/plain'))?.text?.trim();
  }

  return null;
}

String _formatBytes(int? bytes) {
  if (bytes == null) return '?';

  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var index = 0;

  while (value >= 1024 && index < units.length - 1) {
    value /= 1024;
    index++;
  }

  return '${value.toStringAsFixed(value >= 10 || index == 0 ? 0 : 1)} ${units[index]}';
}

Widget? _subscriptionUsage(Subscription subscription) {
  if (subscription.usedBytes == null &&
      subscription.totalBytes == null &&
      subscription.expireAt == null) {
    return null;
  }

  final progress = (subscription.usedBytes != null &&
          subscription.totalBytes != null &&
          subscription.totalBytes! > 0)
      ? (subscription.usedBytes! / subscription.totalBytes!).clamp(0.0, 1.0)
      : null;

  final daysLeft = subscription.expireAt?.difference(DateTime.now()).inDays;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (progress != null)
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          [
            if (subscription.usedBytes != null || subscription.totalBytes != null)
              '${_formatBytes(subscription.usedBytes)} / ${_formatBytes(subscription.totalBytes)}',
            if (daysLeft != null)
              daysLeft < 0 ? 'expired' : '$daysLeft days left',
          ].join(' • '),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    ],
  );
}
