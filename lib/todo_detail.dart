import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod をインポート
import 'providers_db.dart'; // providers.dart をインポート

class TodoDetailPage extends ConsumerWidget {
  const TodoDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 一覧ページのルートから渡された引数をint型に変換し、indexに代入
    final index = ModalRoute.of(context)!.settings.arguments! as int;
    // 状態が変化したら（完了にするボタンがタップされたら）一覧ページに戻るため、
    // 再描画する必要がない→ ref.read() でよい
    final todos = ref.read(todoProvider);
    final todoNotifier = ref.read(todoProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo 詳細'),
      ),
      body: Center(
        child: SizedBox(
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
                  child: Text(todos[index].title), // 修正
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
                  child: Text(todos[index].content), // 修正
                ),
              ),
              Row(
                children: [
                  const Text('優先度:'),
                  FutureBuilder<String>(
                    future: todoNotifier.getPriorityRank(todos[index].id),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                            'loading...'); // データを待っている間に表示するウィジェット
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // エラーが発生した場合に表示するウィジェット
                      } else {
                        return Text(
                            '${snapshot.data}'); // データが利用可能になったときに表示するウィジェット
                      }
                    },
                  ),
                ],
              ),
              SizedBox(
                width: 300,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    todoNotifier.replaceTodoItem(index); // 修正
                    Navigator.of(context).pop();
                  },
                  child: todos[index].isCompleted // 修正
                      ? const Text('未完了にする')
                      : const Text('完了にする'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
