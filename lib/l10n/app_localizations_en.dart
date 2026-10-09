// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HyperNet';

  @override
  String get addSubscription => 'Add Subscription';

  @override
  String get subscription => 'Subscription';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get url => 'Url';

  @override
  String get enterSubscriptionUrl => 'Enter Subscription Url';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get system => 'System';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get english => 'English';

  @override
  String get persian => 'Persian';

  @override
  String get settings => 'Settings';

  @override
  String get removeSubscription => 'Remove';

  @override
  String get shareSubscriptionUrl => 'Share';

  @override
  String get noSubscriptionsYet => 'No subscriptions yet';

  @override
  String get scanQrCode => 'Scan QR code';

  @override
  String get switchCamera => 'Switch';

  @override
  String get flash => 'Flash';

  @override
  String get gallery => 'Gallery';

  @override
  String get noQrFoundInPhoto => 'No QR code found in that photo.';

  @override
  String get copyLink => 'Copy link';

  @override
  String get shareQrCode => 'Share QR code';

  @override
  String get share => 'Share';

  @override
  String get removeAction => 'Remove';

  @override
  String get connectedLabel => 'Connected';

  @override
  String get pingingEllipsis => 'Pinging...';

  @override
  String get timeoutLabel => 'timeout';

  @override
  String get expiredLabel => 'expired';

  @override
  String daysLeft(int count) {
    return '$count days left';
  }

  @override
  String get linkCopied => 'Link copied';

  @override
  String get qrInvalidSubscriptionLink =>
      'QR code is not a valid subscription link.';

  @override
  String get importFromClipboard => 'Import from clipboard';

  @override
  String get pingAll => 'Ping all';

  @override
  String get refreshLabel => 'Refresh';

  @override
  String get removeAllConfigs => 'Remove all configs';

  @override
  String get selectConfigToConnect => 'Select a config to connect';

  @override
  String get addConfig => 'Add config';

  @override
  String get singleConfigs => 'Single configs';

  @override
  String get yourConfigs => 'Your Configs';

  @override
  String get invalidConfigUrl => 'Invalid config URL';

  @override
  String get routing => 'Routing';

  @override
  String get routingTitle => 'Routing — Bypass VPN';

  @override
  String get bypassDomains => 'Bypass domains (one per line)';

  @override
  String get bypassApps => 'Bypass apps (package names, one per line)';

  @override
  String get applyRules => 'Apply rules';

  @override
  String get clear => 'Clear';

  @override
  String get routingRulesSaved =>
      'Routing rules saved. Reconnect VPN to apply.';

  @override
  String get invalidDomainEntry => 'Invalid domain entry.';

  @override
  String get routingSubtitle => 'Bypass domains and apps';

  @override
  String get about => 'About';

  @override
  String get versionLabel => 'Version';

  @override
  String get aboutDescription => 'A Xray VPN client';

  @override
  String get xrayCoreVersion => 'Xray Core Version';
}
