# SkyCast – Flutter weather app

Data: Open-Meteo (free, no API key). State: provider. Storage: shared_preferences.

## Setup
```bash
flutter create skycast
cd skycast
# copy this project's lib/ folder over the generated lib/
flutter pub add http provider geolocator shared_preferences intl fl_chart flutter_map latlong2 just_audio
flutter pub add flutter_local_notifications:18.0.1
flutter run
```

## Platform permissions
**Android** – `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```
**iOS** – `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to show the weather where you are.</string>
```
(Web/desktop: GPS works on web over HTTPS; the city search works everywhere.)

## Data sources & notes
- Forecast + air quality: Open-Meteo (free, no key). Air quality is US AQI; pollen isn't included because Open-Meteo only covers Europe.
- Radar: NEXRAD base reflectivity mosaic from the Iowa Environmental Mesonet (Iowa State University) — free, no key, sourced from NOAA/NWS. Continental US coverage only; the radar screen shows a message for places outside that area. Map tiles: OpenStreetMap (fine for a small app; use a tile provider account if usage grows).
- When you rename the app, update `_userAgent` in `screens/radar_screen.dart` to match your applicationId.
- Animated backgrounds turn off automatically when the phone's "remove animations" setting is on.

## Release & polish
See `RELEASE.md` for the icon/splash generation, app naming, signing and APK steps.

## Alerts, notifications, haptics & radio — how they actually work
- **Alerts**: US National Weather Service active alerts (free, no key). US
  coverage only; shows nothing for places outside the US.
- **Notifications**: local only, no server. A check runs whenever the app is
  opened or you pull to refresh — if a NWS alert is active that you haven't
  seen before, a notification fires then. This is *not* a background push:
  if the app never opens, you won't be notified. A true "wakes the phone up
  the instant NWS issues a warning" system needs either a push server or
  platform background scheduling (WorkManager/BGTaskScheduler), which isn't
  set up here.
- **Haptics**: a short vibration fires once per refresh when the current
  condition is rain or a thunderstorm. Toggle it off in the drawer.
- **Weather radio**: NOAA doesn't stream NWR over the internet itself. The
  station list is volunteer-run SDR relays aggregated by weatherusa.net —
  free, direct stream URLs, but coverage is patchy (nothing near Knoxville
  itself; Bristol and Memphis are the closest TN stations) and a stream can
  go offline without warning since each one is hosted by an individual.
