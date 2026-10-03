import 'package:flutter_vless/flutter_vless.dart';

class Subscription {
  String url;
  List<FlutterVlessURL> configs;
  String? title;
  String? user;
  String? announce;
  String? announceUrl;
  String? supportUrl;

  Subscription({
    required this.url,
    required this.configs,
    this.title,
    this.user,
    this.announce,
    this.announceUrl,
    this.supportUrl,
  });

  String? get getTitle {
    if (title != null && title!.isNotEmpty) {
      String text = title!;

      if (user != null && user!.isNotEmpty) {
        text = "$text ($user)";
      }

      return text;
    }

    return null;
  }
}

extension Ping on FlutterVlessURL {
  // Ping results should be stored externally (e.g. in a Map<FlutterVlessURL, int>);
  // extensions cannot declare instance fields.
}