import 'package:flutter/material.dart';

import 'app_state.dart';

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState store,
    required super.child,
  }) : super(notifier: store);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope no encontrado');
    return scope!.notifier!;
  }
}
