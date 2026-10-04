import 'package:flutter_vless/flutter_vless.dart';

class Subscription {
  String url;
  List<FlutterVlessURL> configs;
  String? title;
  String? user;
  String? announce;
  String? announceUrl;
  String? supportUrl;
  int? usedBytes;
  int? totalBytes;
  DateTime? expireAt;

  Subscription({
    required this.url,
    required this.configs,
    this.title,
    this.user,
    this.announce,
    this.announceUrl,
    this.supportUrl,
    this.usedBytes,
    this.totalBytes,
    this.expireAt,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'user': user,
        'announce': announce,
        'announceUrl': announceUrl,
        'supportUrl': supportUrl,
        'configs': configs.map((config) => config.url).toList(),
        'usedBytes': usedBytes,
        'totalBytes': totalBytes,
        'expireAt': expireAt?.toIso8601String(),
      };

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final configs = (json['configs'] as List? ?? [])
        .map((url) => FlutterVless.parse(url as String))
        .toList();

    return Subscription(
      url: json['url'] as String,
      configs: configs,
      title: json['title'] as String?,
      user: json['user'] as String?,
      announce: json['announce'] as String?,
      announceUrl: json['announceUrl'] as String?,
      supportUrl: json['supportUrl'] as String?,
      usedBytes: json['usedBytes'] as int?,
      totalBytes: json['totalBytes'] as int?,
      expireAt: json['expireAt'] == null
          ? null
          : DateTime.tryParse(json['expireAt'] as String),
    );
  }

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
