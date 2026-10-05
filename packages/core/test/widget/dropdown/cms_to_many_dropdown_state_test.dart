import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:utopia_cms/src/ui/widget/dropdown/to_many/cms_to_many_dropdown_state.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

/// Records the filter of every options request and never answers it.
class _RecordingToManyDelegate extends Fake implements CmsToManyDelegate {
  final filters = <CmsFilter>[];

  @override
  Future<List<JsonMap>> get({Object? originId, CmsFilter filter = const CmsFilter.all()}) {
    filters.add(filter);
    return Completer<List<JsonMap>>().future;
  }
}

class _FakeBaseState extends Fake implements CmsManagementBaseState {
  @override
  void Function(OnSavedCallback) get addOnSavedCallback => (_) {};
}

void main() {
  late _RecordingToManyDelegate delegate;
  late SimpleHookContext<CmsToManyDropdownState> context;

  /// The hook reads the overlay's base state through `Provider.of`, which only a
  /// real element below a [Provider] can answer. [ViewCollection] renders
  /// nothing, so the tree needs no View to attach to.
  BuildContext overlayContext() {
    late BuildContext result;
    RootWidget(
      child: Provider<CmsManagementBaseState>.value(
        value: _FakeBaseState(),
        child: Builder(
          builder: (it) {
            result = it;
            return const ViewCollection(views: []);
          },
        ),
      ),
    ).attach(BuildOwner(focusManager: FocusManager()));
    return result;
  }

  void build({List<String>? filterFields}) {
    context = SimpleHookContext(
      () => useCmsToManyDropdownState(
        delegate: delegate,
        originId: null,
        filterFields: filterFields,
        filterBuilder: null,
      ),
      provided: {BuildContext: overlayContext()},
    );
  }

  setUp(() => delegate = _RecordingToManyDelegate());

  tearDown(() {
    if (context.mounted) context.dispose();
  });

  test('without filterFields or a filterBuilder every option is offered', () {
    build();

    // Not an empty OR group: supabase and hasura both read that as always-false.
    expect(delegate.filters, [const CmsFilter.all()]);
  });

  test('filterFields search the typed text in every field, joined with OR', () async {
    build(filterFields: ['name', 'email']);

    context.value.searchState.value = 'ada';
    // Bounded: the request follows the search debounce, and a search that never
    // reaches the delegate should fail here rather than as a whole-test timeout.
    await context.waitUntil((_) => delegate.filters.length == 2).timeout(const Duration(seconds: 1));

    expect(
      delegate.filters.last,
      const CmsFilter.or([CmsFilter.containsString('name', 'ada'), CmsFilter.containsString('email', 'ada')]),
    );
  });
}
