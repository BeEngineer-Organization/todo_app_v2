import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'providers_db.dart';
import 'todo_db.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? stringSelectedDay;

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(todoProvider);
    return Scaffold(
        appBar: AppBar(title: const Text('カレンダー')),
        body: asyncValue.when(
          data: (database) {
            return Column(
              children: [
                Expanded(
                  child: TableCalendar(
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 10, 16),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }),
                ),
                Expanded(
                  child: FutureBuilder<List<TodoItem>>(
                      future: database.getTodoItems(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        } else {
                          final todoItems = snapshot.data ?? [];
                          if (_selectedDay != null) {
                            return ListView.builder(
                                itemCount: todoItems.length,
                                itemBuilder: (context, index) {
                                  stringSelectedDay = _selectedDay!
                                      .toIso8601String()
                                      .substring(0, 10);
                                  if (stringSelectedDay ==
                                      todoItems[index].deadline) {
                                    return ListTile(
                                        title: Text(
                                            '${todoItems[index].id} ${todoItems[index].title}'));
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                });
                          } else {
                            return const Text("日にちを指定していません");
                          }
                        }
                      }),
                )
              ],
            );
          },
          error: (err, stack) => const Text('Error'),
          loading: () => const Center(child: CircularProgressIndicator()),
        ));
  }
}
