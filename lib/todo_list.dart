import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod をインポート
import 'providers_db.dart';

class TodoListPage extends ConsumerWidget {
  // ConsumerWidget を継承
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WidgetRef を引数に追加
    // 一覧ページでは状態が変化すると同時にウィジェットを再描画する必要があるため
    // ref.watch を使用
    final todos = ref.watch(todoProvider);
    final todoNotifier = ref.read(todoProvider.notifier);
    final bottomBarIndex = ref.watch(bottomBarProvider);
    final bottomBarIndexNotifier = ref.read(bottomBarProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<int>>(
          future: Future.wait([
            todoNotifier.getCompletedItemCount(),
            todoNotifier.getIncompletedItemCount(),
          ]),
          builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('loading...');
            } else {
              if (snapshot.hasError) {
                return Text('Errors:${snapshot.error}');
              } else {
                int completedItemLength = snapshot.data![0];
                int inCompletedItemLength = snapshot.data![1];
                int sum = completedItemLength + inCompletedItemLength;
                return Text('ToDo 一覧（完了済み $completedItemLength/$sum)');
              }
            }
          },
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            // 取得した todo 一覧を展開する
            for (final todo in todos)
              // todo の進捗状況とボトムバーの種類によって表示する todo を変える
              if ((!todo.isCompleted && bottomBarIndex == 0) ||
                  (todo.isCompleted && bottomBarIndex == 1))
                Card(
                  child: ListTile(
                    title: Text('${todo.id + 1} ${todo.title}'),
                    trailing: Checkbox(
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      onChanged: (value) {
                        // チェックボックスが変更されたときの処理
                        todoNotifier.replaceTodoItem(todo.id);
                      },
                      value: todo.isCompleted,
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        // 詳細ページには、タップされたアイテムのインデックスを伝える
                        '/detail',
                        arguments: todo.id,
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 修正
          Navigator.of(context).pushNamed(
            '/add',
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.unpublished),
            label: '未完了',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: '完了',
          ),
        ],
        onTap: bottomBarIndexNotifier.changeBottomBarIndex, // 修正
        currentIndex: bottomBarIndex, // 修正
        selectedItemColor: Colors.blue,
      ),
    );
  }
}
