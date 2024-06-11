import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationController {
  // 「flutter_local_notifications」にあるローカル通知を扱うためのクラスをインスタンス化
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 初期設定
  Future<void> initNotification() async {
    // プラットフォームごとの初期設定をまとめる(今回はAndroidのみ)
    const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('test_icon'));

    // 通知設定を初期化(先程の設定＋通知をタップしたときの処理)
    await notificationsPlugin.initialize(
      initializationSettings,

      // 通知をタップしたときの処理(今回はprint)
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        print('id=${notificationResponse.id}の通知に対してアクション。');
      },
    );
  }

  // 通知を表示する
  Future<void> showNotification() async {
    // プラットフォームごとの詳細設定
    const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName'));

    // 通知を表示
    await notificationsPlugin.show(
      0,
      "title",
      "body",
      notificationDetails,
    );
  }
}

// Future<void> _requestPermissions() async {
//   if (Platform.isIOS || Platform.isMacOS) {
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             MacOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//   } else if (Platform.isAndroid) {
//     final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//         flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();
//     await androidImplementation?.requestPermission();
//   }
// }

// Future<void> _scheduleDaily8AMNotification() async {
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     0,
//     'OB-1',
//     '本日の顔を撮影をしましょう',
//     _nextInstanceOf8AM(),
//     const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'ob-1-face-daily',
//         'ob-1-face-daily',
//         channelDescription: 'Face photo notification',
//       ),
//       iOS: DarwinNotificationDetails(
//         badgeNumber: 1,
//       ),
//     ),
//     uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime,
//     androidAllowWhileIdle: true,
//   );
// }

// // 1回目に通知を飛ばす時間の作成
// tz.TZDateTime _nextInstanceOf8AM() {
//   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//   tz.TZDateTime scheduledDate =
//       tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
//   if (scheduledDate.isBefore(now)) {
//     scheduledDate = scheduledDate.add(const Duration(days: 1));
//   }
//   return scheduledDate;
// }
