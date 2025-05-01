# Block App

A Flutter package for managing Android system permissions and app management including overlay, accessibility, notification, usage stats permissions, and installed apps listing.

## Features

- Check and request overlay permission (SYSTEM_ALERT_WINDOW)
- Check and request accessibility service permission
- Check and request notification permission
- Check and request usage stats permission
- Get list of installed applications

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  block_app:
    git:
      url: your-repository-url
```

### Android Setup

Add these permissions to your Android app's `AndroidManifest.xml` file (usually located at `android/app/src/main/AndroidManifest.xml`):

```xml
<!-- Required for overlay permission -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>

<!-- Required for notification permission -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Required for usage stats permission -->
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"
    tools:ignore="ProtectedPermissions"/>
    
<!-- Required for querying installed apps (Android 11+) -->
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"
    tools:ignore="QueryAllPackagesPermission" />
```

For Android 11+ (API level 30), also add this to your manifest:
```xml
<queries>
    <intent>
        <action android:name="android.intent.action.MAIN" />
    </intent>
</queries>
```

Also, add the `xmlns:tools` namespace to your manifest tag if not already present:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="your.package.name">
```

## Usage

First, create an instance of BlockAppManager:

```dart
final blockAppManager = BlockAppManager();
```

### Getting Installed Apps

```dart
// Get list of installed apps
List<AppModel> apps = await blockAppManager.getInstalledApps();
for (var app in apps) {
  print('App: ${app.appName} (${app.packageName})');
  print('Is System App: ${app.isSystemApp}');
}
```

### Overlay Permission

```dart
// Check overlay permission
bool hasOverlay = await blockAppManager.checkOverlayPermission();

// Request overlay permission if needed
if (!hasOverlay) {
    bool granted = await blockAppManager.requestOverlayPermissions();
    print('Overlay permission granted: $granted');
}
```

### Accessibility Permission

```dart
// Check accessibility permission
bool hasAccessibility = await blockAppManager.checkAccesibilityPermissions();

// Request accessibility permission if needed
if (!hasAccessibility) {
    bool granted = await blockAppManager.requestAccesibilityPermissions();
    print('Accessibility permission granted: $granted');
}
```

### Notification Permission

```dart
// Check notification permission
bool hasNotification = await blockAppManager.checkNotificationPermission();

// Request notification permission if needed
if (!hasNotification) {
    bool granted = await blockAppManager.requestNotificationPermissions();
    print('Notification permission granted: $granted');
}
```

### Usage Stats Permission

```dart
// Check usage stats permission
bool hasUsageStats = await blockAppManager.checkUsageStatePermission();

// Request usage stats permission if needed
if (!hasUsageStats) {
    bool granted = await blockAppManager.requestUsageStatePermissions();
    print('Usage stats permission granted: $granted');
}
```

## Notes

- All permission requests will open the appropriate system settings page for the user to grant the permission
- For Android 6.0 (API level 23) and above, the user needs to explicitly grant these permissions
- Some permissions like SYSTEM_ALERT_WINDOW and PACKAGE_USAGE_STATS are special permissions that can only be granted through system settings
- Make sure to declare all required permissions in your app's AndroidManifest.xml as shown in the installation section

## Requirements

- Android SDK 16 or higher
- Flutter 2.0.0 or higher

## License

This project is licensed under the MIT License - see the LICENSE file for details
