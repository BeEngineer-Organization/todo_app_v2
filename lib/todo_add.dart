import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 追加
import 'todo_db.dart';
import '/providers_db.dart'; // 追加

class TodoAddPage extends ConsumerStatefulWidget {
  const TodoAddPage({super.key});

  @override
  ConsumerState<TodoAddPage> createState() => _TodoAddPageState(); // 修正
}

// ConsumerState に修正
class _TodoAddPageState extends ConsumerState<TodoAddPage> {
  final formKey = GlobalKey<FormState>();
  final titleFormKey = GlobalKey<FormFieldState<String>>();
  final contentFormKey = GlobalKey<FormFieldState<String>>();
  final Map<String, String> formValue = {};

  @override
  Widget build(BuildContext context) {
    // WidgetRef は書かないでよい
    final asyncValue = ref.read(todoProvider);
    final TodoItemDatabase database = TodoItemDatabase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo 追加'),
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                padding: const EdgeInsets.all(4),
                width: 300,
                child: TextFormField(
                  key: titleFormKey,
                  decoration: const InputDecoration(
                    labelText: 'タイトル',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'タイトルを入力してください。';
                    } else if (value.length > 30) {
                      return 'タイトルは30文字以内で入力してください。';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                padding: const EdgeInsets.all(4),
                width: 300,
                height: 200,
                child: TextFormField(
                  key: contentFormKey,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '内容',
                    alignLabelWithHint: true,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 8,
                  validator: (value) {
                    return value == null || value.isEmpty
                        ? '内容を入力してください。'
                        : null;
                  },
                ),
              ),
              asyncValue.when(
                data: (_) {
                  return SizedBox(
                    width: 300,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formValue['title'] =
                              titleFormKey.currentState?.value ?? '';
                          formValue['content'] =
                              contentFormKey.currentState?.value ?? ''; // 修正
                          database.insertTodoItem(formValue);
                          ref.refresh(todoProvider);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Todo を追加'),
                    ),
                  );
                },
                error: (err, stack) => const Text('失敗'),
                loading: () => const Text('ロード中・・・'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
