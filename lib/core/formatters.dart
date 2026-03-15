import 'package:flutter/material.dart';

class AppFormatters {
  static String date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  static String dateRange(DateTime start, DateTime end) {
    return '${date(start)} - ${date(end)}';
  }

  static String score(num? value) {
    if (value == null) return '-';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  static Color scoreColor(BuildContext context, num? home, num? away) {
    if (home == null || away == null) {
      return Theme.of(context).colorScheme.outline;
    }
    if (home == away) return Theme.of(context).colorScheme.secondary;
    return home > away
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
  }
}
