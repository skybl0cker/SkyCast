// flutter_local_notifications has no web implementation, so the web build
// uses a no-op stub while mobile builds use the real plugin.
export 'notification_service_mobile.dart'
    if (dart.library.js_interop) 'notification_service_web.dart';
