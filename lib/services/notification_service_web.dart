import '../models/alert.dart';

/// Web stub: flutter_local_notifications has no web implementation,
/// so alert notifications are a no-op when running as a web app.
/// In-app alert banners still work; only OS-level push is skipped.
class NotificationService {
  Future<void> init() async {}

  Future<void> showAlert(WeatherAlert a) async {}
}
