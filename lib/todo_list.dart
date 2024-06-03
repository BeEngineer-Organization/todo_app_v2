import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod をインポート
import 'todo_db.dart';
import 'providers_db.dart';

class TodoListPage extends ConsumerWidget {
  // ConsumerWidget を継承
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WidgetRef を引数に追加
    // 一覧ページでは状態が変化すると同時にウィジェットを再描画する必要があるため
    // ref.watch を使用
    final asyncValue = ref.watch(todoProvider);
    final bottomBarIndex = ref.watch(bottomBarProvider);
    final bottomBarIndexNotifier = ref.read(bottomBarProvider.notifier);
    final TodoItemDatabase database = TodoItemDatabase();
    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // databaseの非同期
          FutureBuilder<List<int>>(
            future: Future.wait([
              database.getTodoItemsCount(),
              database.getCompletedTodoItemsCount(),
            ]),
            builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('loading...');
              } else {
                if (snapshot.hasError) {
                  return Text('Errors:${snapshot.error}');
                } else {
                  int sum = snapshot.data![0];
                  int completedItemLength = snapshot.data![1];
                  return Text('ToDo 一覧（完了済み $completedItemLength/$sum)');
                }
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/calendar',
                    );
                  },
                  icon: const Icon(Icons.calendar_month)),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/notification',
                    );
                  },
                  icon: const Icon(Icons.notifications))
            ],
          )
        ],
      )),
      body: Center(
        // databaseのプロバイダーの非同期
        child: asyncValue.when(
          data: (database) {
            return FutureBuilder<List<TodoItem>>(
              future: database.getTodoItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('いるのこれ');
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  final todoItems = snapshot.data ?? [];
                  return ListView.builder(
                      itemCount: todoItems.length,
                      itemBuilder: (context, index) {
                        if (todoItems[index].isCompleted == false &&
                                bottomBarIndex == 0 ||
                            todoItems[index].isCompleted == true &&
                                bottomBarIndex == 1) {
                          return ListTile(
                            title: Text(
                                '${todoItems[index].id} ${todoItems[index].title}'),
                            trailing: Checkbox(
                              activeColor: Colors.green,
                              checkColor: Colors.white,
                              onChanged: (value) {
                                // チェックボックスが変更されたときの処理
                                database.changeTodoItem(todoItems[index].id,
                                    todoItems[index].isCompleted);
                                ref.refresh(todoProvider); //databaseの再取得
                              },
                              value: todoItems[index].isCompleted,
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                // 詳細ページには、タップされたアイテムのインデックスを伝える
                                '/detail',
                                arguments: todoItems[index].id,
                              );
                            },
                          );
                        } else {
                          // リストタイルを潰す
                          return const SizedBox.shrink();
                        }
                      });
                }
              },
            );
          },
          error: (err, stack) => const Text('失敗'),
          loading: () => const Text('ロード中・・・'),
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
