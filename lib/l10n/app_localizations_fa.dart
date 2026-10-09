// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'هایپرنت';

  @override
  String get addSubscription => 'افزودن اشتراک';

  @override
  String get subscription => 'اشتراک';

  @override
  String get connect => 'اتصال';

  @override
  String get disconnect => 'قطع اتصال';

  @override
  String get cancel => 'انصراف';

  @override
  String get add => 'افزودن';

  @override
  String get url => 'آدرس';

  @override
  String get enterSubscriptionUrl => 'آدرس اشتراک را وارد کنید';

  @override
  String get language => 'زبان';

  @override
  String get appearance => 'ظاهر';

  @override
  String get system => 'پیش‌فرض سیستم';

  @override
  String get lightMode => 'حالت روشن';

  @override
  String get darkMode => 'حالت تاریک';

  @override
  String get english => 'انگلیسی';

  @override
  String get persian => 'فارسی';

  @override
  String get settings => 'تنظیمات';

  @override
  String get removeSubscription => 'پاک کردن';

  @override
  String get shareSubscriptionUrl => 'هم‌رسانی';

  @override
  String get noSubscriptionsYet => 'هنوز اشتراکی ندارید';

  @override
  String get scanQrCode => 'اسکن کد QR';

  @override
  String get switchCamera => 'تبديل دوربين';

  @override
  String get flash => 'نور';

  @override
  String get gallery => 'گالری';

  @override
  String get noQrFoundInPhoto => 'کد QR در آن عکس پیدا نشد.';

  @override
  String get copyLink => 'کپی کردن لینک';

  @override
  String get shareQrCode => 'هم‌رسانی QR کد';

  @override
  String get share => 'هم‌رسانی';

  @override
  String get removeAction => 'حذف';

  @override
  String get connectedLabel => 'متصل شده';

  @override
  String get pingingEllipsis => 'در حال تست پینگ...';

  @override
  String get timeoutLabel => 'زمان تمام شد';

  @override
  String get expiredLabel => 'منقضی شده';

  @override
  String daysLeft(int count) {
    return '$count روز باقی مانده';
  }

  @override
  String get linkCopied => 'لینک کپی شد';

  @override
  String get qrInvalidSubscriptionLink => 'کد QR لینک اشتراک معتبری نیست.';

  @override
  String get importFromClipboard => 'وارد کردن از حافظه موقت';

  @override
  String get pingAll => 'پینگ همه';

  @override
  String get refreshLabel => 'تازه کردن';

  @override
  String get removeAllConfigs => 'حذف همه کانفیگ‌ها';

  @override
  String get selectConfigToConnect => 'برای اتصال یک کانفیگ انتخاب کنید';

  @override
  String get addConfig => 'افزودن کانفیگ';

  @override
  String get singleConfigs => 'کانفیگ‌های تکی';

  @override
  String get yourConfigs => 'کانفیگ‌های شما';

  @override
  String get invalidConfigUrl => 'آدرس کانفیگ نامعتبر است';

  @override
  String get routing => 'مسیریابی';

  @override
  String get routingTitle => 'مسیریابی — دور زدن VPN';

  @override
  String get bypassDomains => 'دامنه‌های دور زده (هر کدام در یک خط)';

  @override
  String get bypassApps => 'برنامه‌های دور زده (نام بسته، هر کدام در یک خط)';

  @override
  String get applyRules => 'اعمال قوانین';

  @override
  String get clear => 'پاک کردن';

  @override
  String get routingRulesSaved =>
      'قوانین مسیریابی ذخیره شد. برای اعمال، VPN را دوباره متصل کنید.';

  @override
  String get invalidDomainEntry => 'ورودی دامنه نامعتبر است.';

  @override
  String get routingSubtitle => 'دامنه‌ها و برنامه‌های دور زده';

  @override
  String get about => 'درباره';

  @override
  String get versionLabel => 'نسخه';

  @override
  String get aboutDescription =>
      'یک کلاینت VPN با پروتکل VLESS و هسته Xray برای اندروید و iOS.';

  @override
  String get aboutCore => 'هسته';
}
