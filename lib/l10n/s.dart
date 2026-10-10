import 'package:flutter/material.dart';
import 'package:hyper_net/l10n/app_localizations.dart';

/// Global navigator key, attached to the MaterialApp.
/// Provides a BuildContext from anywhere in the app.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global access to localized strings without a BuildContext.
///
/// Use it like the generated `S` class of other projects:
/// ```dart
/// S.current.cannotConnectToServer
/// ```
/// Resolves the current locale through [navigatorKey], so it always
/// reflects the app's active language.
class S {
  static AppLocalizations get current {
    final context = navigatorKey.currentContext;
    if (context == null) {
      throw StateError(
        'S.current was accessed before the app was ready. '
        'Make sure navigatorKey is attached to the MaterialApp.',
      );
    }

    return AppLocalizations.of(context)!;
  }
}
