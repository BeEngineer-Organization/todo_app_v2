import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'todo_db.dart';

Future<void> morningNotify() {
  final flnp = FlutterLocalNotificationsPlugin();
  debugPrint("notifier");
  return flnp
      .initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      )
      .then((_) => flnp.zonedSchedule(
            0, //id
            'morning', //タイトル
            '今日も一日頑張ろう', //内容
            tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)), //デバッグ用
            // tz.TZDateTime.from(DateTime(2024, 6, 13, 8), tz.local),//本番用
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'morning_id',
                'morning_name',
              ),
            ),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time, //毎日繰り返し
          ));
}

Future<void> deadlineNotify() async {
  final flnp = FlutterLocalNotificationsPlugin();
  DateTime now = DateTime.now();
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  String date = outputFormat.format(now);
  TodoItemDatabase todoItemDatabase = TodoItemDatabase();
  final deadlineItem = await todoItemDatabase.deadlineItem(date);
  String deadlineItemStr = deadlineItem.join(' ');
  //データがない時
  if (deadlineItem.isEmpty) {
    debugPrint("notifier2");
    return flnp
        .initialize(
          const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        )
        .then((_) => flnp.zonedSchedule(
              3, //id
              "今日、締め切り", //タイトル
              "ありません。", //内容
              tz.TZDateTime.now(tz.local)
                  .add(const Duration(seconds: 10)), //デバッグ用
              // tz.TZDateTime.from(DateTime(2024, 6, 13, 23, 37), tz.local),//本番用
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'deadline_id',
                  'deadlineItem.',
                ),
              ),
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.time, //毎日繰り返し
            ));
  } else {
    //今日締め切りのtodoがある時
    debugPrint("notifier2");
    return flnp
        .initialize(
          const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        )
        .then((_) => flnp.zonedSchedule(
              3, //id
              "今日、締め切り", //タイトル
              deadlineItemStr, //内容
              tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
              // tz.TZDateTime.from(DateTime(2024, 6, 13, 23, 37), tz.local),
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'deadline_id',
                  'deadlineItem.',
                ),
              ),
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.time, //毎日繰り返し
            ));
  }
}
