# Block App

A Flutter plugin for blocking access to other apps on Android for productivity purposes.

## Features

- Get list of installed apps
- Block and unblock specific apps
- Display custom overlay UI when blocked apps are launched
- Monitor blocked app launch attempts
- Handle required Android permissions automatically

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  block_app: ^0.0.1
```

Then, run:

```bash
flutter pub get
```

## Android Setup

The plugin requires the following permissions in your AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

These permissions will be automatically added by the plugin.

## Usage

### Initialize the plugin

```dart
import 'package:block_app/block_app.dart';

final blockApp = BlockApp();

// Initialize with default configuration
await blockApp.initialize();

// Or with custom configuration
await blockApp.initialize(
  config: const AppBlockConfig(
    defaultMessage: 'This app is blocked',
    overlayBackgroundColor: Colors.black87,
    overlayTextColor: Colors.white,
    actionButtonText: 'Close',
    autoStartService: true,
    autoCheckPermissions: true,
  ),
);
```

### Get installed apps

```dart
// Get non-system apps
final apps = await blockApp.getInstalledApps();

// Include system apps
final allApps = await blockApp.getInstalledApps(includeSystemApps: true);
```

### Block and unblock apps

```dart
// Block an app
await blockApp.blockApp('com.example.app');

// Unblock an app
await blockApp.unblockApp('com.example.app');

// Check if an app is blocked
final isBlocked = await blockApp.isAppBlocked('com.example.app');

// Get all blocked apps
final blockedApps = await blockApp.getBlockedApps();

// Block all apps (except current app and specified excludes)
await blockApp.blockAllApps(
  excludePackages: ['com.example.important_app'],
  onlyUserApps: true, // Do not block system apps
);

// Unblock all apps
await blockApp.unblockAllApps();

// Manually start/stop the blocking service
await blockApp.startBlockingService();
await blockApp.stopBlockingService();
```

### Manage permissions

```dart
// Check permissions
final permissions = await blockApp.checkPermissions();
final hasOverlayPermission = permissions['hasOverlayPermission'];
final hasUsageStatsPermission = permissions['hasUsageStatsPermission'];

// Request permissions
await blockApp.requestOverlayPermission();
await blockApp.requestUsageStatsPermission();
```

### Customize blocking overlay

#### Using default UI with customization

```dart
// Create a default overlay with customization
final overlay = blockApp.createDefaultBlockingOverlay(
  customMessage: 'Focus on your work!',
  actionButtonText: 'Return',
  backgroundColor: Colors.black.withOpacity(0.9),
  textColor: Colors.white,
);
```

#### Using completely custom UI

```dart
// Initialize with custom UI builder
await blockApp.initialize(
  config: AppBlockConfig(
    customOverlayBuilder: (context, packageName) {
      return YourCustomOverlayWidget(packageName: packageName);
    },
  ),
);
```

### Listen for blocked app attempts

```dart
blockApp.onBlockedAppDetected((packageName) {
  print('User tried to open blocked app: $packageName');
  // Handle the event
});
```

## Complete Example

Check out the example app for a full implementation:

```dart
import 'package:flutter/material.dart';
import 'package:block_app/block_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Blocker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AppBlockExamplePage(),
    );
  }
}
```

The plugin includes an example page that demonstrates all functionality.

## License

MIT
