import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoItem {
  TodoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.isCompleted,
    required this.priority,
    required this.deadline,
  });

  final int id;
  final String title;
  final String content;
  final bool isCompleted;
  final int priority;
  final String deadline;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
      'deadline': deadline,
    };
  }

  @override
  String toString() {
    return 'TodoItem{id: $id, title: $title, content: $content, isCompleted: $isCompleted,isCompleted: $isCompleted, priority:$priority}';
  }

  TodoItem copyWith({
    int? id,
    String? title,
    String? content,
    bool? isCompleted,
    int? priority,
    String? deadline,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
    );
  }
}

class TodoItemDatabase {
  late final Future<Database> database = initDatabase();

  get i => null;

  Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'TodoItem_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE TodoItem(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, isCompleted INTEGER,priority INTEGER, deadline TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertTodoItem(Map<String, dynamic> formValue) async {
    final db = await database;
    await db.insert(
      'TodoItem',
      {
        "title": formValue['title'],
        "content": formValue['content'],
        "priority": formValue['priority'],
        "deadline": formValue['deadline'],
        'isCompleted': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TodoItem>> getTodoItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('TodoItem');
    return List.generate(maps.length, (i) {
      return TodoItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        isCompleted: maps[i]['isCompleted'] == 1,
        priority: maps[i]['priority'],
        deadline: maps[i]['deadline'],
      );
    });
  }

  Future<TodoItem> showTodoItem(int index) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'TodoItem',
      where: 'id = ?',
      whereArgs: [index],
    );
    return TodoItem(
      id: maps[0]['id'],
      title: maps[0]['title'],
      content: maps[0]['content'],
      isCompleted: maps[0]['isCompleted'] == 1,
      priority: maps[0]['priority'],
      deadline: maps[0]['deadline'],
    );
  }

  Future<int> getTodoItemsCount() async {
    final List<TodoItem> todoItems = await getTodoItems();
    return todoItems.length;
  }

  Future<int> getCompletedTodoItemsCount() async {
    final List<TodoItem> todoItems = await getTodoItems();
    return todoItems.where((item) => item.isCompleted).length;
  }

  Future<void> updateTodoItem(int index, Map<String, dynamic> formValue) async {
    final db = await database;
    await db.update(
      'TodoItem',
      formValue,
      where: 'id = ?',
      whereArgs: [index],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> changeTodoItem(int index, bool isCompleted) async {
    final db = await database;
    await db.update(
      'TodoItem',
      {'isCompleted': isCompleted ? 0 : 1},
      where: 'id = ?',
      whereArgs: [index],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteTodoItem(int id) async {
    final db = await database;
    await db.delete(
      'TodoItem',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> deadlineItem(String datetime) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'TodoItem',
      where: 'deadline = ?',
      whereArgs: [datetime],
    );
    List<String> titles = [];
    for (var item in maps) {
      titles.add(
        item['title'],
      );
    }
    return titles;
  }
}
