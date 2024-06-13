import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 追加
import 'todo_db.dart';
import '/providers_db.dart'; // 追加

class TodoAddPage extends ConsumerStatefulWidget {
  const TodoAddPage({super.key});

  @override
  ConsumerState<TodoAddPage> createState() => _TodoAddPageState(); // 修正
}

// ConsumerState に修正
class _TodoAddPageState extends ConsumerState<TodoAddPage> {
  final formKey = GlobalKey<FormState>();
  final titleFormKey = GlobalKey<FormFieldState<String>>();
  final contentFormKey = GlobalKey<FormFieldState<String>>();
  final priorityFormKey = GlobalKey<FormFieldState<String>>();
  final priorityController = TextEditingController();
  final deadlineFormKey = GlobalKey<FormFieldState<String>>();
  final deadlineController = TextEditingController();
  final Map<String, dynamic> formValueStr = {};
  int _value = 1; //初期化

  @override
  Widget build(BuildContext context) {
    // WidgetRef は書かないでよい
    final TodoItemDatabase database = TodoItemDatabase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo 追加'),
      ),
      body: Form(
        key: formKey,
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          // タイトル
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            padding: const EdgeInsets.all(4),
            width: 300,
            child: TextFormField(
              key: titleFormKey,
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
          // 内容
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            padding: const EdgeInsets.all(4),
            width: 300,
            height: 200,
            child: TextFormField(
              key: contentFormKey,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '内容',
                alignLabelWithHint: true,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 8,
              validator: (value) {
                return value == null || value.isEmpty ? '内容を入力してください。' : null;
              },
            ),
          ),
          // ラジオボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Radio(
                    value: 0,
                    groupValue: _value,
                    onChanged: (int? value) {
                      setState(() {
                        _value = value!;
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
                    groupValue: _value,
                    onChanged: (int? value) {
                      setState(
                        () {
                          _value = value!;
                        },
                      );
                    },
                  ),
                  const Text('中')
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: 2,
                    groupValue: _value,
                    onChanged: (int? value) {
                      setState(() {
                        _value = value!;
                      });
                    },
                  ),
                  const Text('低')
                ],
              ),
            ],
          ),
          // 期限日
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            padding: const EdgeInsets.all(4),
            width: 300,
            child: TextFormField(
                key: deadlineFormKey,
                controller: deadlineController,
                decoration: const InputDecoration(
                  labelText: "Deadline",
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode()); //キーボードを非表示
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    deadlineController.text =
                        date.toIso8601String().substring(0, 10);
                  }
                },
                validator: (value) {
                  return value == null || value.isEmpty ? '期限を決めてください。' : null;
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
                  formValueStr['priority'] = _value; //優先度
                  formValueStr['deadline'] =
                      deadlineFormKey.currentState?.value ?? '';
                  database.insertTodoItem(formValueStr);
                  ref.invalidate(todoProvider);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Todo を追加'),
            ),
          )
        ])),
      ),
    );
  }
}
