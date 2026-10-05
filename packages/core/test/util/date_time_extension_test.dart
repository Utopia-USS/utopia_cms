import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/src/util/date_time_extension.dart';

void main() {
  // Backend values arrive UTC-flavored, but the table shows the viewer's wall
  // clock. Each input is a local wall-clock time handed over as UTC, so the
  // literals hold in every zone: 00:30 is the previous UTC day east of UTC,
  // 23:30 the next UTC day west of it. A UTC zone cannot tell the two apart.
  test(
    'formats a utc-flavored instant in local time',
    () {
      final afterMidnight = DateTime(2024, 1, 15, 0, 30).toUtc();
      final beforeMidnight = DateTime(2024, 1, 15, 23, 30).toUtc();

      expect(afterMidnight.toDisplayString(), '15 Jan 2024 00:30');
      expect(afterMidnight.toDisplayStringWithoutHours(), '15 Jan 2024');
      expect(beforeMidnight.toDisplayString(), '15 Jan 2024 23:30');
      expect(beforeMidnight.toDisplayStringWithoutHours(), '15 Jan 2024');
    },
    skip: DateTime(2024, 1, 15).timeZoneOffset == Duration.zero ? 'needs a non-UTC TZ' : null,
  );
}
