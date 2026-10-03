import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vless/flutter_vless.dart';
import 'package:http/http.dart' as http;
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:hyper_net/models/subscription.dart';
import 'package:hyper_net/screens/settings/application_appearance_screen.dart';
import 'package:hyper_net/screens/settings/application_languages_screen.dart';
import 'package:hyper_net/application.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Subscription> subscriptions = [];
  FlutterVlessURL? selectedConfig;

  final vlessStatus = ValueNotifier<VlessStatus>(VlessStatus());

  late final flutterVless = FlutterVless(
    onStatusChanged: (status) {
      vlessStatus.value = status;

      debugPrint(
        'status=${status.state} connection=${status.connectionState.name} '
            'delay=${status.duration}s',
      );
    },
  );

  @override
  void dispose() {
    vlessStatus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
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
                    leading: Icon(Icons.add),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () async {
                    final url = await addSubscription();
                    if (url != null) {
                      final subscription = await getSubscription(url);
                      if (subscription != null) {
                        setState(() {
                          subscriptions.add(subscription);
                        });
                      }
                    }
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final subscription = subscriptions[index];

          return ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    subscription.getTitle ?? AppLocalizations.of(context)!.subscription,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {

                  },
                  icon: Icon(Icons.speed),
                ),
              ],
            ),
            leading: IconButton(
              onPressed: () {

              },
              icon: Icon(Icons.refresh),
            ),
            children: List.generate(
              subscription.configs.length,
                  (index) {
                final config = subscription.configs[index];
                return ListTile(
                  title: Text(config.remark),
                  subtitle: Text("${config.network} ${config.outbound1["protocol"]}"),
                  onTap: () {
                    setState(() {
                      selectedConfig = config;
                    });
                  },
                );
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 16);
        },
        itemCount: subscriptions.length,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedConfig != null ? () async {
          if (_canStop(vlessStatus.value)) {
            await _disconnect();
          } else {
            await connect(selectedConfig!);
          }
        } : null,
        label: ValueListenableBuilder<VlessStatus>(
          valueListenable: vlessStatus,
          builder: (context, status, child) {
            return Text(
              _canStop(status) ? AppLocalizations.of(context)!.disconnect : AppLocalizations.of(context)!.connect,
            );
          },
        ),
        icon: ValueListenableBuilder<VlessStatus>(
          valueListenable: vlessStatus,
          builder: (context, status, child) {
            return Icon(
              _canStop(status) ? Icons.stop : Icons.play_arrow,
            );
          },
        ),
      ),
    );
  }

  Future<String?> addSubscription() async {
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
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            final text = await importFromClipboard();
                            if ((text ?? "").isNotEmpty) {
                              subscriptionTextController.text = text!;
                            }
                          },
                          icon: Icon(Icons.paste),
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

  Future<String?> importFromClipboard() async {
    if (await Clipboard.hasStrings()) {
      return (await Clipboard.getData('text/plain'))?.text?.trim();
    }

    return null;
  }

  Future<Subscription?> getSubscription(String subscription) async {
    try {
      final url = Uri.parse(subscription);
      final response = await http.get(url);

      print(response.statusCode);

      if (response.statusCode == HttpStatus.ok) {
        List<FlutterVlessURL> configs = [];
        String? title;
        String? user;
        String? announce;
        String? announceUrl;
        String? supportUrl;

        String decodedConfigs = utf8.decode(base64Url.decode(response.body));
        configs = FlutterVless.parseMany(decodedConfigs);

        String? titleHeader = response.headers["profile-title"];
        if (titleHeader != null) {
          titleHeader = titleHeader.replaceFirst('base64:', '');
          title = utf8.decode(base64Url.decode(titleHeader));
        }

        String? contentDispositionHeader = response.headers["content-disposition"];
        if (contentDispositionHeader != null) {
          contentDispositionHeader = contentDispositionHeader.replaceFirst('attachment; filename=', '');
          contentDispositionHeader = contentDispositionHeader.replaceAll("\"", '');
          if (contentDispositionHeader.isNotEmpty) {
            user = contentDispositionHeader;
          }
        }

        String? announceHeader = response.headers["announce"];
        if (announceHeader != null) {
          announceHeader = announceHeader.replaceFirst('base64:', '');
          announce = utf8.decode(base64Url.decode(announceHeader));
        }

        announceUrl = response.headers["announce-url"];

        supportUrl = response.headers["support-url"];

        return Subscription(url: subscription, configs: configs, title: title, user: user, announce: announce, announceUrl: announceUrl, supportUrl: supportUrl);
      }
    } catch (ex) {
      if (kDebugMode) {
        print("get subscription fail $ex");
      }
    }

    return null;
  }

  Future<void> connect(FlutterVlessURL config) async {
    await flutterVless.initializeVless(
      providerBundleIdentifier: 'com.arashz4.hypernet',
      groupIdentifier: 'group.com.arashz4.hypernet',
    );

    if (await flutterVless.requestPermission()) {
      await flutterVless.startVless(
        remark: config.remark,
        config: config.getFullConfiguration(),
      );

      final version = await flutterVless.getCoreVersion();

      print("version: $version");
    }
  }

  Future<void> _disconnect() async {
    await flutterVless.stopVless();
  }

  bool _canStop(VlessStatus status) {
    return switch (status.connectionState) {
      VlessConnectionState.connected ||
      VlessConnectionState.connecting ||
      VlessConnectionState.disconnecting =>
      true,
      VlessConnectionState.disconnected ||
      VlessConnectionState.unknown =>
      false,
    };
  }
}
