import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Formats the instant in the viewer's local time zone.
  String toDisplayString() {
    final dateFormat = DateFormat("dd MMM yyyy HH:mm", 'en_US');
    return dateFormat.format(toLocal());
  }

  /// Formats the instant's local calendar date.
  String toDisplayStringWithoutHours() {
    final dateFormat = DateFormat("dd MMM yyyy", 'en_US');
    return dateFormat.format(toLocal());
  }
}
