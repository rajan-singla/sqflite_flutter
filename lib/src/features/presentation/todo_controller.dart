import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_flutter/src/features/domain/todo.dart';
import 'package:sqlite_flutter/utils/database_helper.dart';

enum FilterTodo { all, pending, completed }

@immutable
class TodoController extends AsyncNotifier<List<Todo>> {
  TodoController();

  late final DatabaseHelper db;
  static const tableName = 'todos';

  @override
  FutureOr<List<Todo>> build() {
    db = ref.watch(databaseHelperProvider);
    return _fetchTodos();
  }

  /// Function used to get the list of todos
  Future<List<Todo>> _fetchTodos() async {
    List<Todo> originalList = [];
    final result = await db.getData(tableName);
    final value = result.map((element) => Todo.fromJson(element)).toList();
    debugPrint(value.toString());
    originalList = (value).reversed.toList();
    return originalList;
  }

  /// Function used to insert the data into the specific table
  Future<void> insertData(Todo todo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await db.insertData(tableName, todo.toMap());
      return _fetchTodos();
    });
  }

  /// Function used to update the particular todo
  Future<void> updateTodo(Todo todo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await db.updateData(tableName, todo.toMap());
      return _fetchTodos();
    });
  }

  /// Function used to toggle the todo completion while pressed on checkbox
  Future<void> toggleTodoCompletion(Todo todo) async {
    final updated = todo.copyWith(
      id: todo.id,
      title: todo.title,
      isCompleted: !todo.isCompleted,
    );
    await updateTodo(updated);
  }

  /// Function used to remove the Todo based on todoId
  Future<void> removeTodo(String todoId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await db.deleteData(tableName, todoId);
      return _fetchTodos();
    });
  }
}

/// Main provider for TodoController
final todoControllerProvider =
    AsyncNotifierProvider<TodoController, List<Todo>>(() {
  return TodoController();
});

/// Provider used to get the Todo filter
final todoFilterProvider = StateProvider((ref) => FilterTodo.all);

/// Provider used to get the filtered list of Todo's
final todoFilteredListProvider = Provider<List<Todo>>((ref) {
  final controller = ref.watch(todoControllerProvider);
  final todoFilter = ref.watch(todoFilterProvider);
  final asyncValue = controller.whenData((todos) {
    switch (todoFilter) {
      case FilterTodo.all:
        return todos;
      case FilterTodo.pending:
        return todos.where((todo) => !todo.isCompleted).toList();
      case FilterTodo.completed:
        return todos.where((todo) => todo.isCompleted).toList();
      default:
        return todos;
    }
  });
  return asyncValue.value ?? <Todo>[];
});

/// Provider used to get the count of unfinished Todo's
final todoCounterLeft = StateProvider<int>((ref) {
  final controller = ref.watch(todoFilteredListProvider);
  final value = controller.where((todo) => !todo.isCompleted).toList();
  return value.length;
});
