import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers_db.dart';
import 'todo_db.dart';

class TodoEditPage extends ConsumerStatefulWidget {
  const TodoEditPage({super.key});

  @override
  ConsumerState<TodoEditPage> createState() => _TodoEditPageState(); // 修正
}

class _TodoEditPageState extends ConsumerState<TodoEditPage> {
  final formKey = GlobalKey<FormState>();
  final titleFormKey = GlobalKey<FormFieldState<String>>();
  final contentFormKey = GlobalKey<FormFieldState<String>>();
  final priorityFormKey = GlobalKey<FormFieldState<String>>();
  final priorityController = TextEditingController();
  final deadlineFormKey = GlobalKey<FormFieldState<String>>();
  final deadlineController = TextEditingController();
  final Map<String, dynamic> formValueStr = {};
  int valuePriority = 3;

  @override
  Widget build(BuildContext context) {
    final TodoItemDatabase database = TodoItemDatabase();
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    int index = arguments['id'];

    if (valuePriority == 3) {
      valuePriority = arguments['priority'];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo編集'),
      ),
      body: FutureBuilder(
          future: database.showTodoItem(index),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('ロード中...');
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else if (snapshot.data == null) {
              throw Exception('データが空です。');
            } else {
              final todoItem = snapshot.data!;
              return Form(
                key: formKey,
                child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    padding: const EdgeInsets.all(4),
                    width: 300,
                    child: TextFormField(
                      key: titleFormKey,
                      initialValue: todoItem.title,
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
                      initialValue: todoItem.content,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: 0,
                            groupValue: valuePriority,
                            onChanged: (int? value) {
                              setState(() {
                                valuePriority = value!;
                              });
                            },
                          ),
                          const Text('高')
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 1,
                            groupValue: valuePriority,
                            onChanged: (int? value) {
                              setState(() {
                                valuePriority = value!;
                              });
                            },
                          ),
                          const Text('中')
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                              value: 2,
                              groupValue: valuePriority,
                              onChanged: (int? value) {
                                setState(() {
                                  valuePriority = value!;
                                });
                              }),
                          const Text('低')
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    padding: const EdgeInsets.all(4),
                    width: 300,
                    child: TextFormField(
                        key: deadlineFormKey,
                        controller: deadlineController,
                        decoration: InputDecoration(
                          labelText: "変更前${todoItem.deadline}",
                        ),
                        onTap: () async {
                          FocusScope.of(context)
                              .requestFocus(FocusNode()); //キーボードを非表示
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.parse(todoItem.deadline),
                            firstDate: DateTime(2022),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            deadlineController.text =
                                date.toIso8601String().substring(0, 10);
                          } else {
                            deadlineController.text = todoItem.deadline;
                          }
                        },
                        validator: (value) {
                          return value == null || value.isEmpty
                              ? deadlineController.text = todoItem.deadline
                              : null;
                        }),
                  ),
                  SizedBox(
                    width: 300,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formValueStr['title'] =
                              titleFormKey.currentState?.value ?? '';
                          formValueStr['content'] =
                              contentFormKey.currentState?.value ?? ''; // 修正
                          formValueStr['priority'] = valuePriority;
                          formValueStr['deadline'] =
                              deadlineFormKey.currentState?.value ?? '';
                          database.updateTodoItem(index, formValueStr);
                          ref.refresh(todoProvider);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('編集完了'),
                    ),
                  )
                ])),
              );
            }
          }),
    );
  }
}