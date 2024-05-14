import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_add.dart';
import 'todo_detail.dart';
import 'todo_list.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyTodoApp(),
    ),
  );
}

class MyTodoApp extends StatelessWidget {
  const MyTodoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TodoListPage(),
        '/detail': (context) => const TodoDetailPage(),
        '/add': (context) => const TodoAddPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          return MaterialPageRoute(
            builder: (context) {
              return const TodoDetailPage();
            },
          );
        } else {
          return MaterialPageRoute(
            builder: (context) {
              return const TodoListPage();
            },
          );
        }
      },
    );
  }
}
