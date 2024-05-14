class TodoItem {
  final int id;
  final String title;
  final String content;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.isCompleted,
  });

  void toggleIsCompleted() => isCompleted = !isCompleted;

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
