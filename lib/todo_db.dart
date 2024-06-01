import 'dart:async';
import 'package:flutter/material.dart';
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

  get i => null;

  Future<void> initDatabase() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'TodoItem_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE TodoItem(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, isCompleted INTEGER)',
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
        'isCompleted': 'false'
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
        isCompleted: maps[i]['isCompleted'],
      );
    });
  }

  Future<TodoItem> showTodoItem(int index) async {
    final List<TodoItem> todoItems = await getTodoItems();
    return todoItems[index];
  }

  Future<int> getTodoItemsCount() async {
    final List<TodoItem> todoItems = await getTodoItems();
    return todoItems.length;
  }

  Future<int> getCompletedTodoItemsCount() async {
    final List<TodoItem> todoItems = await getTodoItems();
    return todoItems.where((item) => item.isCompleted).length;
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

  Future<void> changeTodoItem(int index, bool isCompleted) async {
    final db = await database;
    await db.update(
      'TodoItem',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [index],
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
