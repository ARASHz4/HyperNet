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
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

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
  String get remove => 'Remove';

  @override
  String get connected => 'Connected';

  @override
  String get pinging => 'Pinging...';

  @override
  String get timeout => 'timeout';

  @override
  String get expired => 'Expired';

  @override
  String daysLeft(String count) {
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

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get day => 'day';

  @override
  String get days => 'days';

  @override
  String get h => 'h';

  @override
  String get min => 'min';

  @override
  String get sec => 'sec';

  @override
  String get warning => 'Warning';

  @override
  String get error => 'Error';

  @override
  String get cannotConnectToServer => 'Cannot Connect to the Server';

  @override
  String get incorrectData => 'Incorrect data';

  @override
  String get byte => 'Byte';

  @override
  String get kb => 'KB';

  @override
  String get mb => 'MB';

  @override
  String get gb => 'GB';

  @override
  String get tb => 'TB';

  @override
  String get ofLabel => 'of';
}
