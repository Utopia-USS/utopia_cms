import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';

/// One recorded [RecordingCmsDelegate.get] call, resolved by the test.
class RecordedGet {
  final CmsFunctionsSortingParams? sorting;
  final CmsFilter filter;
  final int offset;
  final int? limit;
  final _completer = Completer<List<JsonMap>>();

  RecordedGet({required this.sorting, required this.filter, required this.offset, required this.limit});

  void complete(List<JsonMap> rows) => _completer.complete(rows);
}

/// Records every [get] and [delete] and lets the test resolve each one, so the
/// order of concurrent operations is decided by the test, not by a scheduler.
/// Any other call throws.
class RecordingCmsDelegate extends Fake implements CmsDelegate {
  @override
  final String idKey;

  final gets = <RecordedGet>[];
  final deletes = <JsonMap>[];

  final _getWaiters = <int, Completer<void>>{};
  final _deleteWaiters = <int, Completer<void>>{};
  final _deleteCompleters = <Completer<void>>[];

  RecordingCmsDelegate({this.idKey = 'id'});

  /// Completes once [get] has been called [count] times.
  Future<void> untilGetCount(int count) =>
      gets.length >= count ? Future.value() : (_getWaiters[count] ??= Completer<void>()).future;

  /// Completes once [delete] has been called [count] times.
  Future<void> untilDeleteCount(int count) =>
      deletes.length >= count ? Future.value() : (_deleteWaiters[count] ??= Completer<void>()).future;

  /// Resolves the [index]-th recorded [delete].
  void completeDelete(int index) => _deleteCompleters[index].complete();

  @override
  Future<List<JsonMap>> get({
    CmsFunctionsSortingParams? sorting,
    CmsFilter filter = const CmsFilterAll(),
    required CmsFunctionsPagingParams paging,
  }) {
    final call = RecordedGet(sorting: sorting, filter: filter, offset: paging.offset, limit: paging.limit);
    gets.add(call);
    _getWaiters.remove(gets.length)?.complete();
    return call._completer.future;
  }

  @override
  Future<void> delete(JsonMap value) {
    deletes.add(value);
    final completer = Completer<void>();
    _deleteCompleters.add(completer);
    _deleteWaiters.remove(deletes.length)?.complete();
    return completer.future;
  }
}
