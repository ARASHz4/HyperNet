import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vless/flutter_vless.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:hyper_net/models/subscription.dart';

part 'home_state.dart';
part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeLoaded()) {
    add(const LoadSubscriptions());

    on<LoadSubscriptions>((event, emit) {
      final box = Hive.box<String>('subscriptions');
      final subscriptions = box.values
          .map((value) {
            try {
              return Subscription.fromJson(
                  jsonDecode(value) as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<Subscription>()
          .toList();

      emit((state as HomeLoaded).copyWith(subscriptions: subscriptions));
    });

    on<AddSubscription>((event, emit) async {
      if (state is! HomeLoaded) return;

      final currentState = state as HomeLoaded;

      final subscription = await getSubscription(event.url);

      if (subscription != null) {
        Hive.box<String>('subscriptions')
            .put(subscription.url, jsonEncode(subscription.toJson()));

        emit(currentState.copyWith(
          subscriptions: [...currentState.subscriptions, subscription],
        ));
      }
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
  }

  late final flutterVless = FlutterVless(
    onStatusChanged: (status) {
      add(VlessStatusChanged(status));
    },
  );

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
}

bool canStop(VlessStatus status) {
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
