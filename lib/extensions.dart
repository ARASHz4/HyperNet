import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hyper_net/l10n/app_localizations.dart';
import 'package:hyper_net/models/language.dart';
import 'package:hyper_net/preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher.dart';

extension AppDate on DateTime {
  String dateToYMMMd(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    if (languageCode == 'fa' ||
        Preferences.currentLanguage.calendar == Calendar.solarJalali) {
      final Map<int, String> months = {
        1: "فروردین",
        2: "اردیبهشت",
        3: "خرداد",
        4: "تیر",
        5: "اَمرداد",
        6: "شهریور",
        7: "مهر",
        8: "آبان",
        9: "آذر",
        10: "دی",
        11: "بهمن",
        12: "اسفند",
      };

      final jalaliDate = toJalali();

      final year = intl.NumberFormat("", languageCode).format(jalaliDate.year);
      final month = intl.NumberFormat("", languageCode).format(jalaliDate.month);
      final monthName = months[jalaliDate.month];
      final day = intl.NumberFormat("", languageCode).format(jalaliDate.day);

      return "$day ${monthName ?? month} $year";
    }

    return intl.DateFormat.yMMMd(languageCode).format(this);
  }

  String dateToMMMd(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    if (languageCode == 'fa' ||
        Preferences.currentLanguage.calendar == Calendar.solarJalali) {
      final Map<int, String> months = {
        1: "فروردین",
        2: "اردیبهشت",
        3: "خرداد",
        4: "تیر",
        5: "اَمرداد",
        6: "شهریور",
        7: "مهر",
        8: "آبان",
        9: "آذر",
        10: "دی",
        11: "بهمن",
        12: "اسفند",
      };

      final jalaliDate = toJalali();

      final month = intl.NumberFormat("", languageCode).format(jalaliDate.month);
      final monthName = months[jalaliDate.month];
      final day = intl.NumberFormat("", languageCode).format(jalaliDate.day);

      return "$day ${monthName ?? month}";
    }

    return intl.DateFormat.MMMd(languageCode).format(this);
  }

  String timeToString(BuildContext context) {
    final dateTime = this;

    return intl.DateFormat(
        'hh:mm a', Localizations.localeOf(context).languageCode)
        .format(dateTime);
  }

  String dateTimeToString(BuildContext context) {
    return "${dateToYMMMd(context)} ${timeToString(context)}";
  }

  String dateTimeToStringWithDay(BuildContext context, {required bool time}) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    //default is normal date string
    String dateString = dateToYMMMd(context);

    final dateToCheck = DateTime(year, month, day);
    if (dateToCheck == today) {
      dateString = l10n.today;
    }
    else if (dateToCheck == yesterday) {
      dateString = l10n.yesterday;
    }

    if (time) {
      return "$dateString\n${timeToString(context)}";
    }
    else {
      return dateString;
    }
  }
}

extension IntFormat on int {
  String formatToString(BuildContext context) {
    return intl.NumberFormat(
        "", Localizations.localeOf(context).languageCode)
        .format(this);
  }

  String formatCompactToString(BuildContext context) {
    return intl.NumberFormat.compact(
        locale: Localizations.localeOf(context).languageCode)
        .format(this);
  }
}

extension DoubleFormat on double {
  String formatToString(BuildContext context, {int? maximumFractionDigits}) {
    final format = intl.NumberFormat(
        "", Localizations.localeOf(context).languageCode);
    format.minimumIntegerDigits = 1;
    if (maximumFractionDigits != null) {
      format.maximumFractionDigits = maximumFractionDigits;
    }

    return format.format(this);
  }
}

extension BuildContextExtension on BuildContext {
  void showError({String? title, required String message, bool isWarning = false}) {
    final l10n = AppLocalizations.of(this)!;
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title ?? (isWarning ? l10n.warning : l10n.error),
        message: message,
        contentType: isWarning ? ContentType.warning : ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<dynamic> navigatorPush({required Widget screen, bool fullscreenDialog = false}) async {
    return await Navigator.of(this).push(
      MaterialPageRoute(
        fullscreenDialog: fullscreenDialog,
        builder: (context) => screen,
      ),
    );
  }

  Future<dynamic> navigatorPushReplacement({required Widget screen, bool fullscreenDialog = false}) async {
    return await Navigator.of(this).pushReplacement(
      MaterialPageRoute(
        fullscreenDialog: fullscreenDialog,
        builder: (context) => screen,
      ),
    );
  }

  void showLoading() {
    EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
      indicator: const CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }

  void dismissLoading() {
    EasyLoading.dismiss();
  }

  void showSnackBar({required String message}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> urlLauncher(String url, {LaunchMode launchMode = LaunchMode.externalApplication}) async {
    final uri = Uri.tryParse(url);

    if (uri != null) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: launchMode,
        );

        return;
      }
    }

    debugPrint("Could not launch $url");
  }
}

extension DurationFormat on Duration {
  String format(BuildContext context, {bool hideSecondsZero = false}) {
    final l10n = AppLocalizations.of(context)!;
    String duration = "";

    int day = inSeconds ~/ 86400;
    int hour = (inSeconds - day * 86400) ~/ 3600;
    int minutes = (inSeconds % 3600) ~/ 60;
    int seconds = inSeconds % 60;

    if (day > 0) {
      duration = "${day.formatToString(context)}${day == 1 ? l10n.day : l10n.days}";
    }

    if ((hour) > 0 || duration.isNotEmpty) {
      if (duration.isNotEmpty) {
        duration += " ";
      }

      duration += hour.formatToString(context) + l10n.h;
    }

    if (minutes > 0 || duration.isNotEmpty) {
      if (duration.isNotEmpty) {
        duration += " ";
      }

      duration += minutes.formatToString(context) + l10n.min;
    }

    if (seconds > 0 || duration.isNotEmpty) {
      if (!hideSecondsZero || seconds > 0) {
        if (duration.isNotEmpty) {
          duration += " ";
        }

        duration += seconds.formatToString(context) + l10n.sec;
      }
    }

    return duration;
  }

  Widget formatWidget(BuildContext context, {bool hideSecondsZero = false}) {
    final l10n = AppLocalizations.of(context)!;

    int day = inSeconds ~/ 86400;
    int hour = (inSeconds - day * 86400) ~/ 3600;
    int minutes = (inSeconds % 3600) ~/ 60;
    int seconds = inSeconds % 60;

    List<Widget> widgets = [];

    if (day > 0) {
      widgets.add(
        Row(
          children: [
            Text(day.formatToString(context)),
            Text(day == 1 ? l10n.day : l10n.days, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    if ((hour) > 0 || widgets.isNotEmpty) {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(width: 4));
      }

      widgets.add(
        Row(
          children: [
            Text(hour.formatToString(context)),
            Text(l10n.h, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    if (minutes > 0 || widgets.isNotEmpty) {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(width: 4));
      }

      widgets.add(
        Row(
          children: [
            Text(minutes.formatToString(context)),
            Text(l10n.min, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    if (seconds > 0 || widgets.isNotEmpty) {
      if (!hideSecondsZero || seconds > 0) {
        if (widgets.isNotEmpty) {
          widgets.add(const SizedBox(width: 4));
        }

        widgets.add(
          Row(
            children: [
              Text(seconds.formatToString(context)),
              Text(l10n.sec, style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }
    }

    return Row(children: widgets);
  }
}
