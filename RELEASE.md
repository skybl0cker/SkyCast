# Polish & release checklist

Run everything from your Flutter project folder (the one with `pubspec.yaml`).

## 0. Pin the notifications package version
`flutter_local_notifications` changed its API in later major versions (and
v22+ needs Java 17 and Android core library desugaring). The code here is
written against 18.0.1, which needs none of that extra setup. Install it
pinned so `flutter pub upgrade` doesn't silently move you to a newer major
and break the build again:
```bash
flutter pub add flutter_local_notifications:18.0.1
```
If you ever want the newer major version, say so and I'll update
`notification_service.dart` to match its named-parameter API and add the
Java 17/desugaring Gradle changes back.

## 1. Copy in the new files
From this zip, copy into your project:
- `assets/` (icon + splash images)
- `flutter_launcher_icons.yaml`
- `flutter_native_splash.yaml`
- `lib/` (unchanged since last time)

## 2. Generate the icon and splash screen
```bash
flutter pub add --dev flutter_launcher_icons flutter_native_splash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
The icon includes an Android 13+ themed (monochrome) version.

## 3. Name the app
**App name** – `android/app/src/main/AndroidManifest.xml`, change the label:
```xml
<application
    android:label="SkyCast"
```
**App ID** – in `android/app/build.gradle.kts` (or `build.gradle`), change only
`applicationId`, e.g. `com.yourname.skycast`. Leave `namespace` alone; changing
it also requires moving the Kotlin package folders.

Then set `_userAgent` in `lib/screens/radar_screen.dart` to the same ID.

## 4. Sign the release (do this once, keep the key forever)
Friends can only install updates over an older install if every build is signed
with the *same* key. Back up the keystore file and passwords somewhere safe.
```bash
keytool -genkey -v -keystore ~/skycast-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias skycast
```
Create `android/key.properties` (never share or commit this file):
```
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=skycast
storeFile=/home/YOU/skycast-key.jks
```
**If your file is `android/app/build.gradle.kts`** (newer Flutter):
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ...existing settings...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```
The `import` lines go at the very top of the file; the rest merges into the
existing `android { }` block (replace the existing `release` block).

**If your file is `android/app/build.gradle`** (Groovy), use the Groovy snippet
in Flutter's Android deployment guide: https://docs.flutter.dev/deployment/android

## 5. Build and share
```bash
flutter build apk --release --split-per-abi
```
Send friends `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
(right for nearly every modern phone). They'll need to allow installs from
unknown sources, and Play Protect may show an "unrecognized app" prompt.
That's normal for apps outside the Play Store.

## 6. Shipping updates
Bump the number after the `+` in `pubspec.yaml` (`version: 1.0.1+2`) every time.
Android refuses to install an update whose build number isn't higher.
