import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  DateTime addTime({int? year, int? month, int? day}) {
    return copyWith(
      year: this.year + (year ?? 0),
      month: this.month + (month ?? 0),
      day: this.day + (day ?? 0),
    );
  }

  DateTime withTime(TimeOfDay timeOfDay) {
    return copyWith(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
    );
  }

  String toDisplayString() {
    final dateFormat = DateFormat("dd MMMM yyyy HH:mm", 'en_US');
    return dateFormat.format(this);
  }

  String toDisplayStringWithoutHours() {
    final dateFormat = DateFormat("dd MMMM yyyy", 'en_US');
    return dateFormat.format(this);
  }

  DateTime subtractTimeOfDay(TimeOfDay time) => subtract(Duration(hours: time.hour, minutes: time.minute));
}
