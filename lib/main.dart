import 'package:flutter/material.dart';
import 'package:hyper_net/application.dart';
import 'package:hyper_net/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  runApp(const Application());
}
