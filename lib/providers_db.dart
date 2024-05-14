import 'dart:core';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_db.dart';

final todoProvider =
    StateNotifierProvider<TodoList, List<TodoItem>>((ref) => TodoList());

final bottomBarProvider =
    StateNotifierProvider.autoDispose<BottomBarNotifier, int>(
  (ref) => BottomBarNotifier(),
);

class TodoList extends StateNotifier<List<TodoItem>> {
  TodoList() : super([]) {
    fetchTodoItems();
  }

  final TodoItemDatabase _database = TodoItemDatabase();

  Future<void> fetchTodoItems() async {
    state = await _database.getTodoItems();
  }

  Future<void> addTodoItem(Map<String, String> formValue) async {
    TodoItem item = TodoItem(
      id: state.length,
      title: formValue['title']!,
      content: formValue['content']!,
      isCompleted: false,
    );
    await _database.insertTodoItem(item);
    final updatedList = [...state, item];
    state = updatedList;
  }

  Future<void> replaceTodoItem(int index) async {
    TodoItem item = state.firstWhere((i) => i.id == index);
    TodoItem updatedItem = item.copyWith(isCompleted: !item.isCompleted);
    state = state.map((i) => i.id == index ? updatedItem : i).toList();
    await _database.updateTodoItem(updatedItem);
  }

  Future<int> getIncompletedItemCount() async {
    final inCompletedItemLength =
        state.where((item) => !item.isCompleted).length;
    return inCompletedItemLength;
  }

  Future<int> getCompletedItemCount() async {
    final completedItemLength = state.where((item) => item.isCompleted).length;
    return completedItemLength;
  }

  Future<int> sumCount() async {
    await _database.getTodoItems();
    final allItemLength = state.length;
    return allItemLength;
  }
}

class BottomBarNotifier extends StateNotifier<int> {
  BottomBarNotifier() : super(0);

  void changeBottomBarIndex(int index) {
    state = index;
  }
}
