import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hyper_net/models/subscription.dart';

class LocalStorage {
  static const String _subscriptionsBox = 'subscriptions';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_subscriptionsBox);
  }

  // ---------- Subscription ----------

  Box<String>? get _subscriptions =>
      Hive.isBoxOpen(_subscriptionsBox)
          ? Hive.box<String>(_subscriptionsBox)
          : null;

  Future<void> saveSubscription(Subscription subscription) async {
    await _subscriptions?.put(
      subscription.url,
      jsonEncode(subscription.toJson()),
    );
  }

  Future<void> saveSubscriptions(List<Subscription> subscriptions) async {
    final entries = {
      for (final subscription in subscriptions)
        subscription.url: jsonEncode(subscription.toJson()),
    };
    await _subscriptions?.putAll(entries);
  }

  List<Subscription> getSubscriptions() {
    final box = _subscriptions;
    if (box == null) return [];

    return box.values
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
  }

  Future<void> deleteSubscription(String url) async {
    await _subscriptions?.delete(url);
  }

  Future<void> clearSubscriptions() async {
    await _subscriptions?.clear();
  }
}
