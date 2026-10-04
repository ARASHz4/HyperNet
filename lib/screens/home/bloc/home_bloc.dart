import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vless/flutter_vless.dart';
import 'package:http/http.dart' as http;
import 'package:hyper_net/models/subscription.dart';
import 'package:hyper_net/storage/local_storage.dart';

part 'home_state.dart';
part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeLoaded()) {
    on<LoadSubscriptions>((event, emit) {
      final subscriptions = LocalStorage().getSubscriptions();

      emit((state as HomeLoaded).copyWith(subscriptions: subscriptions));
    });

    on<AddSubscription>((event, emit) async {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      final subscription = await getSubscription(event.url);

      if (subscription != null) {
        await LocalStorage().saveSubscription(subscription);

        emit(currentState.copyWith(
          subscriptions: [...currentState.subscriptions, subscription],
        ));
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
                .map((s) =>
                    s.url == event.subscription!.url ? event.subscription! : s)
                .toList(),
        refreshing: currentState.refreshing
            .where((url) => url != event.url)
            .toList(),
      ));
    });

    on<SelectConfig>((event, emit) {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      emit(currentState.copyWith(selectedConfig: event.config));
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

    add(const LoadSubscriptions());
  }

  late final flutterVless = FlutterVless(
    onStatusChanged: (status) {
      add(VlessStatusChanged(status));
    },
  );

  Future<void> _refreshSubscription(String url) async {
    final subscription = await getSubscription(url);

    if (subscription != null) {
      await LocalStorage().saveSubscription(subscription);
    }

    add(SubscriptionRefreshed(url: url, subscription: subscription));
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

        int? usedBytes;
        int? totalBytes;
        DateTime? expireAt;

        final userInfo = response.headers["subscription-userinfo"];
        if (userInfo != null) {
          final parts = <String, String>{};
          for (final part in userInfo.split(';')) {
            final index = part.indexOf('=');
            if (index > 0) {
              parts[part.substring(0, index).trim()] =
                  part.substring(index + 1).trim();
            }
          }

          final upload = int.tryParse(parts['upload'] ?? '') ?? 0;
          final download = int.tryParse(parts['download'] ?? '') ?? 0;
          usedBytes = upload + download;
          totalBytes = int.tryParse(parts['total'] ?? '');
          final expire = int.tryParse(parts['expire'] ?? '');
          if (expire != null) {
            expireAt = DateTime.fromMillisecondsSinceEpoch(expire * 1000);
          }
        }

        return Subscription(url: subscription, configs: configs, title: title, user: user, announce: announce, announceUrl: announceUrl, supportUrl: supportUrl, usedBytes: usedBytes, totalBytes: totalBytes, expireAt: expireAt);
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
      notificationIconResourceName: 'ic_notification',
      notificationIconResourceType: 'mipmap',
    );

    if (await flutterVless.requestPermission()) {
      await flutterVless.startVless(
        remark: config.remark,
        config: config.getFullConfiguration(),
      );
    }
  }
}
