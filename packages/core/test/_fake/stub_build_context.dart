import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// `useCmsTablePageState` provides a [BuildContext] only so `onManage` can read
/// the theme at push time; nothing else in the hook touches it.
class StubBuildContext extends Fake implements BuildContext {}

/// The navigator is only reachable through the manage / create overlay, which
/// these tests do not open.
class StubNavigator extends Fake implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => 'StubNavigator';
}
