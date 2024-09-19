import 'dart:async';

import 'package:flow_vm/flow_vm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTest
void viewModelTest(
  String description, {
  required Iterable<FlowTestCase> Function() cases,
  required Future Function() action,
  FutureOr Function()? verify,
  dynamic Function()? setUp,
}) {
  _viewModelTest(
    description,
    casesBuilder: cases,
    action: action,
    verify: verify,
    setUpFun: setUp,
  );
}

void _viewModelTest(
  String description, {
  required Iterable<FlowTestCase> Function() casesBuilder,
  required Future Function() action,
  required FutureOr Function()? verify,
  required dynamic Function()? setUpFun,
}) {
  test(
    description,
    () async {
      setUpFun?.call();

      final cases = casesBuilder();
      for (var element in cases) {
        element._start();
      }
      await action();
      for (var element in cases) {
        element._finish();
      }
      await verify?.call();
    },
  );
}

class FlowTestCase<V> {
  FlowTestCase({
    required this.flow,
    required Iterable<V> expect,
  }) : _expect = expect;

  final DataFlow<V> flow;
  final Iterable<V> _expect;
  late final received = <V>[];

  void _listener() {
    received.add(flow.value);
  }

  void _start() {
    flow.listenable.addListener(_listener);
  }

  void _finish() {
    flow.listenable.removeListener(_listener);
    return expect(received, _expect);
  }
}
