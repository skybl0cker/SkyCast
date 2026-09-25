import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alert.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _ready = true;
  }

  Future<void> showAlert(WeatherAlert a) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'weather_alerts',
        'Weather alerts',
        channelDescription: 'Active NWS watches and warnings for your places',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(a.id.hashCode, a.event,
        a.headline.isNotEmpty ? a.headline : a.areas, details);
  }
}
