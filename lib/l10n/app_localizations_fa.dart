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
  String get appearance => 'نما';

  @override
  String get system => 'پیش‌فرض سیستم';

  @override
  String get lightMode => 'روشن';

  @override
  String get darkMode => 'تاریک';

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
  String get switchCamera => 'جابجایی دوربين';

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
  String get remove => 'حذف';

  @override
  String get connected => 'وصل شده';

  @override
  String get pingingEllipsis => 'در حال تست پینگ...';

  @override
  String get timeout => 'زمان تمام شد';

  @override
  String get expired => 'منقضی شده';

  @override
  String daysLeft(String count) {
    return '$count روز باقی مانده';
  }

  @override
  String get linkCopied => 'لینک کپی شد';

  @override
  String get qrInvalidSubscriptionLink => 'کد QR لینک همرسانی نادرست است.';

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
  String get yourConfigs => 'کانفیگ‌های شما';

  @override
  String get invalidConfigUrl => 'آدرس کانفیگ نادرسا است';

  @override
  String get routing => 'مسیریابی';

  @override
  String get routingTitle => 'مسیریابی — دور زدن VPN';

  @override
  String get bypassDomains => 'دامنه‌های دور زده (هر کدام در یک خط)';

  @override
  String get bypassApps => 'نرم‌افزار‌های دور زده (نام بسته، هر کدام در یک خط)';

  @override
  String get applyRules => 'انجام دستورات';

  @override
  String get clear => 'پاک کردن';

  @override
  String get routingRulesSaved =>
      'دستورات مسیریابی ذخیره شد. برای انجام، VPN را دوباره وصل کنید.';

  @override
  String get invalidDomainEntry => 'ورودی دامنه نادرست است.';

  @override
  String get routingSubtitle => 'دامنه‌ها و نرم‌افزار‌های دور زده';

  @override
  String get about => 'درباره';

  @override
  String get versionLabel => 'ویرایش';

  @override
  String get aboutDescription => 'یک کلاینت Xray VPN';

  @override
  String get xrayCoreVersion => 'وبرایش هسته Xray';

  @override
  String get today => 'امروز';

  @override
  String get yesterday => 'دیروز';

  @override
  String get day => 'روز';

  @override
  String get days => 'روز';

  @override
  String get h => 'ساعت';

  @override
  String get min => 'دقیقه';

  @override
  String get sec => 'ثانیه';

  @override
  String get warning => 'هشدار';

  @override
  String get error => 'خطا';

  @override
  String get cannotConnectToServer => 'نمی‌توان با سرور ارتباط برقرار کرد';

  @override
  String get incorrectData => 'داده نارست';

  @override
  String get byte => 'بایت';

  @override
  String get kb => 'کیلوبایت';

  @override
  String get mb => 'مگ';

  @override
  String get gb => 'گیگ';

  @override
  String get tb => 'ترا';

  @override
  String get ofLabel => 'از';
}
