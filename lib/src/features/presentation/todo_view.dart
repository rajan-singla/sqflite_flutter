import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_flutter/src/features/domain/todo.dart';
import 'package:sqlite_flutter/src/features/presentation/todo_controller.dart';
import 'package:uuid/uuid.dart';

class TodoView extends ConsumerWidget {
  TodoView({super.key});

  final textEditingController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(todoControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.error.toString())));
      }
    });
    final value = ref.watch(todoControllerProvider);
    final todos = ref.watch(todoFilteredListProvider);
    final itemsLeft = ref.watch(todoCounterLeft);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todoey?'),
      ),
      body: value.when(
        data: (_) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: formKey,
                child: TextFormField(
                  controller: textEditingController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your TODO';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    hintText: 'Add TODO for the day',
                    labelText: 'TODO',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          child: IconButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                if (textEditingController.text.trim().isNotEmpty) {
                                  final todo = Todo(
                                    id: _uuid.v4(),
                                    title: textEditingController.text.trim(),
                                    isCompleted: false,
                                  );
                                  await ref
                                      .read(todoControllerProvider.notifier)
                                      .insertData(todo);
                                  textEditingController.clear();
                                }
                              }
                            },
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text('$itemsLeft items left'),
                  const Spacer(),
                  TextButton(
                      onPressed: value.isLoading
                          ? null
                          : () => ref
                              .read(todoFilterProvider.notifier).state = FilterTodo.all,
                      child: Text(FilterTodo.all.name)),
                  TextButton(
                      onPressed: value.isLoading
                          ? null
                          : () => ref
                              .read(todoFilterProvider.notifier).state = FilterTodo.pending,
                      child: Text(FilterTodo.pending.name)),
                  TextButton(
                      onPressed: value.isLoading
                          ? null
                          : () => ref
                              .read(todoFilterProvider.notifier).state = FilterTodo.completed,
                      child: Text(FilterTodo.completed.name)),
                ],
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Dismissible(
                    key: ValueKey(todo.id),
                    onDismissed: (_) async {
                      await ref
                          .read(todoControllerProvider.notifier)
                          .removeTodo(todo.id);
                    },
                    child: ListTile(
                      leading: Checkbox(
                        onChanged: (value) async {
                          await ref
                              .read(todoControllerProvider.notifier)
                              .toggleTodoCompletion(todo);
                        },
                        value: todo.isCompleted,
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  );
                },
              )),
            ],
          ),
        ),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Text(error.toString()),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
