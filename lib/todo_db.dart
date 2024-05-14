import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoItem {
  TodoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final String content;
  final bool isCompleted;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isCompleted': isCompleted,
    };
  }

  @override
  String toString() {
    return 'TodoItem{id: $id, title: $title, content: $content, isCompleted: $isCompleted}';
  }

  TodoItem copyWith({
    int? id,
    String? title,
    String? content,
    bool? isCompleted,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TodoItemDatabase {
  TodoItemDatabase() {
    initDatabase();
  }

  late Future<Database> database;

  Future<void> initDatabase() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'TodoItem_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE TodoItem(id INTEGER PRIMARY KEY, title TEXT, content TEXT, isCompleted INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertTodoItem(TodoItem todoItem) async {
    final db = await database;
    await db.insert(
      'TodoItem',
      todoItem.toMap(),
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
        isCompleted: maps[i]['isCompleted'],
      );
    });
  }

  Future<void> updateTodoItem(TodoItem todoItem) async {
    final db = await database;
    await db.update(
      'TodoItem',
      todoItem.toMap(),
      where: 'id = ?',
      whereArgs: [todoItem.id],
      conflictAlgorithm: ConflictAlgorithm.fail,
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
}
