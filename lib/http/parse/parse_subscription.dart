import 'dart:convert';
import 'package:flutter_vless/flutter_vless.dart';
import 'package:hyper_net/models/subscription.dart';

class ParseSubscription {
  Subscription? subscription({required String subscriptionUrl, required dynamic data, required Map<String, List<String>> headers}) {
    if (data is String) {
      List<FlutterVlessURL> configs = [];
      String? title;
      String? user;
      String? announce;
      String? announceUrl;
      String? supportUrl;

      String decodedConfigs = utf8.decode(base64Url.decode(data));
      configs = FlutterVless.parseMany(decodedConfigs);

      String? titleHeader = headers["profile-title"]?.firstOrNull;
      if (titleHeader != null) {
        titleHeader = titleHeader.replaceFirst('base64:', '');
        title = utf8.decode(base64Url.decode(titleHeader));
      }

      String? contentDispositionHeader = headers["content-disposition"]?.firstOrNull;
      if (contentDispositionHeader != null) {
        contentDispositionHeader = contentDispositionHeader.replaceFirst('attachment; filename=', '');
        contentDispositionHeader = contentDispositionHeader.replaceAll("\"", '');
        if (contentDispositionHeader.isNotEmpty) {
          user = contentDispositionHeader;
        }
      }

      String? announceHeader = headers["announce"]?.firstOrNull;
      if (announceHeader != null) {
        announceHeader = announceHeader.replaceFirst('base64:', '');
        announce = utf8.decode(base64Url.decode(announceHeader));
      }

      announceUrl = headers["announce-url"]?.firstOrNull;

      supportUrl = headers["support-url"]?.firstOrNull;

      int? usedBytes;
      int? totalBytes;
      DateTime? expireAt;

      final userInfo = headers["subscription-userinfo"]?.firstOrNull;
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

      return Subscription(
        url: subscriptionUrl,
        configs: configs,
        title: title,
        user: user,
        announce: announce,
        announceUrl: announceUrl,
        supportUrl: supportUrl,
        usedBytes: usedBytes,
        totalBytes: totalBytes,
        expireAt: expireAt,
      );
    }

    return null;
  }
}
