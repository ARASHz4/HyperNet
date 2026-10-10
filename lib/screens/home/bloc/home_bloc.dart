import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vless/flutter_vless.dart';
import 'package:hyper_net/application.dart';
import 'package:hyper_net/extensions.dart';
import 'package:hyper_net/http/http_subscription.dart';
import 'package:hyper_net/http/models/http_error.dart';
import 'package:hyper_net/l10n/s.dart';
import 'package:hyper_net/models/subscription.dart';
import 'package:hyper_net/preferences.dart';
import 'package:hyper_net/screens/settings/routing_config.dart';
import 'package:hyper_net/storage/local_storage.dart';

part 'home_state.dart';
part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeLoaded()) {
    on<InitializeVless>((event, emit) async {
      await _initializeVless();
    });

    on<LoadSubscriptions>((event, emit) async {
      final subscriptions = LocalStorage().getSubscriptions();
      final savedUrl = await Preferences.selectedConfigUrl();

      FlutterVlessURL? savedConfig;
      if (savedUrl != null && savedUrl.isNotEmpty) {
        for (final subscription in subscriptions) {
          for (final config in subscription.configs) {
            if (config.url == savedUrl) {
              savedConfig = config;
              break;
            }
          }
          if (savedConfig != null) break;
        }

        try {
          savedConfig ??= FlutterVless.parse(savedUrl);
        } catch (_) {
          savedConfig = null;
        }
      }

      emit((state as HomeLoaded).copyWith(
        subscriptions: subscriptions,
        selectedConfig: savedConfig,
      ));
    });

    on<LoadConfigs>((event, emit) {
      if (state is! HomeLoaded) return;

      final urls = LocalStorage().getSingleConfigUrls();
      final configs = urls
          .map((url) {
        try {
          return FlutterVless.parse(url);
        } catch (_) {
          return null;
        }
      })
          .whereType<FlutterVlessURL>()
          .toList();

      emit((state as HomeLoaded).copyWith(singleConfigs: configs));
    });

    on<AddConfig>((event, emit) async {
      if (state is! HomeLoaded) {
        return;
      }

      final currentState = state as HomeLoaded;

      try {
        final config = FlutterVless.parse(event.rawUrl);

        await LocalStorage().saveSingleConfig(event.rawUrl);

        emit(currentState.copyWith(
          singleConfigs: [...currentState.singleConfigs, config],
        ));
      } catch (ex) {
        if (kDebugMode) {
          print("failed to add config $ex");
        }
      }
    });

    on<AddConfigs>((event, emit) async {
      if (state is! HomeLoaded) {
        return;
      }

      final currentState = state as HomeLoaded;

      try {
        for (final config in event.configs) {
          await LocalStorage().saveSingleConfig(config.url);
        }

        emit(currentState.copyWith(
          singleConfigs: [...currentState.singleConfigs, ...event.configs],
        ));
      } catch (ex) {
        if (kDebugMode) {
          print("failed to add configs $ex");
        }
      }
    });

    on<RemoveConfig>((event, emit) async {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      await LocalStorage().deleteSingleConfig(event.rawUrl);

      emit(currentState.copyWith(
        singleConfigs: currentState.singleConfigs
            .where((c) => c.url != event.rawUrl)
            .toList(),
        selectedConfig: identical(currentState.selectedConfig?.url, event.rawUrl) && currentState.selectedConfig != null
            ? null
            : currentState.selectedConfig,
      ));
    });

    on<RemoveAllConfigs>((event, emit) async {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      final urls = currentState.singleConfigs.map((c) => c.url).toList();
      for (final url in urls) {
        await LocalStorage().deleteSingleConfig(url);
      }

      emit(currentState.copyWith(
        singleConfigs: [],
        selectedConfig: currentState.selectedConfig != null && currentState.singleConfigs.any((c) => identical(c, currentState.selectedConfig))
            ? null
            : currentState.selectedConfig,
      ));
    });

    on<AddSubscription>((event, emit) async {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      navigatorKey.currentContext?.showLoading();

      try {
        final response = await HttpSubscription().getSubscription(subscriptionUrl: event.url);

        await response.when(
          success: (subscription) async {
            await LocalStorage().saveSubscription(subscription);

            emit(currentState.copyWith(
              subscriptions: [...currentState.subscriptions, subscription],
            ));
          },
          failure: (error) async {
            if (kDebugMode) {
              print("add subscription failed $error");
            }

            final context = navigatorKey.currentContext;
            if (context != null && context.mounted) {
              context.showError(message: error.displayMessage());
            }
          },
        );
      } catch (e) {
        if (kDebugMode) {
          print("add subscription exception $e");
        }

        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          context.showError(message: S.current.cannotConnectToServer);
        }
      } finally {
        navigatorKey.currentContext?.dismissLoading();
      }
    });

    on<RefreshSubscription>((event, emit) {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      emit(currentState.copyWith(
          refreshing: [...currentState.refreshing, event.url]));

      _refreshSubscription(event.url);
    });

    on<RemoveSubscription>((event, emit) async {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      emit(currentState.copyWith(
        subscriptions: currentState.subscriptions
            .where((s) => s.url != event.url)
            .toList(),
      ));

      await LocalStorage().deleteSubscription(event.url);
    });

    on<SubscriptionRefreshed>((event, emit) {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      emit(currentState.copyWith(
        subscriptions: event.subscription == null
            ? null
            : currentState.subscriptions
                .map((s) {return s.url == event.subscription!.url ? event.subscription! : s;})
                .toList(),
        refreshing: currentState.refreshing
            .where((url) => url != event.url)
            .toList(),
      ));
    });

    on<SelectConfig>((event, emit) async {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      emit(currentState.copyWith(selectedConfig: event.config));

      await Preferences.setSelectedConfigUrl(event.config.url);

      switch (currentState.vlessStatus.connectionState) {
        case VlessConnectionState.connected:
        case VlessConnectionState.connecting:
          await flutterVless.stopVless();
          await connect(event.config);
          break;
        case VlessConnectionState.disconnecting:
        case VlessConnectionState.disconnected:
        case VlessConnectionState.unknown:
          break;
      }
    });

    on<VlessStatusChanged>((event, emit) {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      debugPrint(
        'status=${event.status.state} connection=${event.status.connectionState.name} '
        'delay=${event.status.duration}s',
      );

      emit(currentState.copyWith(vlessStatus: event.status));
    });

    on<Connect>((event, emit) async {
      await connect(event.config);
    });

    on<Disconnect>((event, emit) async {
      await flutterVless.stopVless();
    });

    on<PingConfigs>((event, emit) async {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      emit(currentState.copyWith(
        pinging: [
          ...currentState.pinging,
          for (final config in event.configs)
            if (!currentState.pinging.contains(config.url)) config.url,
        ],
      ));

      final delays = Map<String, int>.from(currentState.delays);

      for (final config in event.configs) {
        int delay = -1;
        try {
          delay = await flutterVless.getServerDelay(
            config: config.getFullConfiguration(),
          );
        } catch (_) {
          delay = -1;
        }

        delays[config.url] = delay;

        final latest = state as HomeLoaded;
        emit(latest.copyWith(
          delays: Map<String, int>.from(delays),
          pinging: latest.pinging.where((url) => url != config.url).toList(),
        ));
      }
    });

    add(const InitializeVless());

    add(const LoadSubscriptions());
    add(const LoadConfigs());
  }

  late final flutterVless = FlutterVless(
    onStatusChanged: (status) {
      add(VlessStatusChanged(status));
    },
  );

  Future<void> _initializeVless() {
    return flutterVless.initializeVless(
      providerBundleIdentifier: 'com.arashz4.hypernet',
      groupIdentifier: 'group.com.arashz4.hypernet',
      notificationIconResourceName: 'ic_notification',
      notificationIconResourceType: 'drawable',
    );
  }

  Future<void> _refreshSubscription(String url) async {
    final response = await HttpSubscription().getSubscription(subscriptionUrl: url);

    response.when(
      success: (subscription) async {
        await LocalStorage().saveSubscription(subscription);

        add(SubscriptionRefreshed(url: url, subscription: subscription));
      },
      failure: (error) {

      },
    );
  }

  Future<void> connect(FlutterVlessURL config) async {
    await _initializeVless();

    if (await flutterVless.requestPermission()) {
      var configuration = config.getFullConfiguration();
      final bypassDomains = await Preferences.bypassDomains();

      if (bypassDomains.isNotEmpty) {
        try {
          configuration = routingConfig(
            config: configuration,
            selectedSites: bypassDomains,
          );
        } catch (_) {
          // The config has no direct outbound to route around the VPN;
          // connect without domain bypass rules.
        }
      }

      await flutterVless.startVless(
        remark: config.remark,
        config: configuration,
        blockedApps: await Preferences.bypassApps(),
      );
    }
  }

  Future<String> getXrayCoreVersion() async {
    final version = await flutterVless.getCoreVersion();

    // The core returns a full build string like:
    // "Xray 26.9.9 (Xray, Penetrates Everything.) v26.9.9 (go1.27.0 android/arm64)"
    // Keep only the version number.
    final match = RegExp(r'\d+\.\d+(?:\.\d+)*').firstMatch(version);

    return match?.group(0) ?? version;
  }
}
