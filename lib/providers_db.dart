import 'dart:core';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_db.dart';

final todoProvider = FutureProvider((ref) async => await TodoItemDatabase());

final bottomBarProvider = NotifierProvider<BottomBarNotifier, int>(
  () => BottomBarNotifier(),
);

class BottomBarNotifier extends Notifier<int> {
  BottomBarNotifier();

  @override
  int build() {
    return 0;
  }

  void changeBottomBarIndex(int index) {
    state = index;
  }
}
