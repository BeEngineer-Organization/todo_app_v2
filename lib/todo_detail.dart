import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod をインポート
import 'providers_db.dart'; // providers.dart をインポート
import 'todo_db.dart';

class TodoDetailPage extends ConsumerWidget {
  const TodoDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 一覧ページのルートから渡された引数をint型に変換し、indexに代入
    final index = ModalRoute.of(context)!.settings.arguments! as int;
    // 状態が変化したら（完了にするボタンがタップされたら）一覧ページに戻るため、
    // 再描画する必要がない→ ref.read() でよい
    final asyncValue = ref.watch(todoProvider);
    final TodoItemDatabase database = TodoItemDatabase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo 詳細'),
      ),
      body: Center(
          child: asyncValue.when(
        data: (todo) {
          return FutureBuilder<TodoItem>(
              future: database.showTodoItem(index),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('ロード中...');
                } else if (snapshot.hasError) {
                  return const Text('エラーが起きました');
                } else if (snapshot.data == null) {
                  throw Exception('データが空です。');
                } else {
                  final todoItem = snapshot.data!;
                  return SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(bottom: 4),
                          child: const Text('タイトル'),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            width: 300,
                            child: Text(todoItem.title), // 修正
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: const Text('内容'),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            width: 300,
                            height: 200,
                            child: Text(todoItem.content), // 修正
                          ),
                        ),
                        SizedBox(
                          width: 300,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              database.changeTodoItem(
                                  index, todoItem.isCompleted); // 修正
                              Navigator.of(context).pop();
                            },
                            child: todoItem.isCompleted // 修正
                                ? const Text('未完了にする')
                                : const Text('完了にする'),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              });
        },
        error: (err, stack) => const Text('失敗'),
        loading: () => const Text('ロード中・・・'),
      )),
    );
  }
}
