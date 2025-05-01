import 'package:block_app/src/data/model/app_model.dart';

import 'package:block_app/src/data/services/app_block_manager.dart';
import 'package:block_app/src/data/services/permission_manager.dart';

/// BlockAppManager provides a unified interface to manage various Android system permissions.
///
/// This class handles four types of permissions:
/// 1. Overlay permission (SYSTEM_ALERT_WINDOW)
/// 2. Accessibility service permission
/// 3. Notification permission
/// 4. Usage stats permission
///
/// Each permission has two associated methods:
/// - A check method that returns the current permission status
/// - A request method that opens the appropriate system settings for the user to grant permission
///
/// Example usage:
/// ```dart
/// final manager = BlockAppManager();
///
/// if (!await manager.checkOverlayPermission()) {
///   await manager.requestOverlayPermissions();
/// }
/// ```
class BlockAppManager {
  final _appBlockManager = AppBlockManager();

  /// Checks if overlay permission (SYSTEM_ALERT_WINDOW) is granted
  ///
  /// Returns `true` if the permission is granted, `false` otherwise.
  /// This permission is required for drawing over other apps.
  ///
  /// For Android 6.0 (API level 23) and above, this permission must be explicitly
  /// granted by the user through system settings.
  Future<bool> checkOverlayPermission() async {
    return await PermissionManager.hasPermission(PermissionType.overlay);
  }

  /// Checks if accessibility service permission is granted
  ///
  /// Returns `true` if the permission is granted, `false` otherwise.
  /// This permission is required for monitoring and controlling other apps.
  ///
  /// The user must enable the accessibility service through Android's
  /// Accessibility Settings.
  Future<bool> checkAccesibilityPermissions() async {
    return await PermissionManager.hasPermission(PermissionType.accessibility);
  }

  /// Checks if notification permission is granted
  ///
  /// Returns `true` if the permission is granted, `false` otherwise.
  /// This permission is required for posting notifications.
  ///
  /// For Android 13 (API level 33) and above, this permission must be explicitly
  /// granted by the user.
  Future<bool> checkNotificationPermission() async {
    return await PermissionManager.hasPermission(PermissionType.notification);
  }

  /// Checks if usage stats permission is granted
  ///
  /// Returns `true` if the permission is granted, `false` otherwise.
  /// This permission is required for accessing app usage statistics.
  ///
  /// This is a special permission that must be granted through system settings
  /// on all Android versions.
  Future<bool> checkUsageStatePermission() async {
    return await PermissionManager.hasPermission(PermissionType.usageStats);
  }

  /// Requests overlay permission by opening system settings
  ///
  /// Returns `true` if permission is granted after the request, `false` otherwise.
  /// This will open the system settings screen where the user can grant the
  /// SYSTEM_ALERT_WINDOW permission.
  Future<bool> requestOverlayPermissions() async {
    return await PermissionManager.requestPermission(PermissionType.overlay);
  }

  /// Requests accessibility service permission by opening accessibility settings
  ///
  /// Returns `true` if permission is granted after the request, `false` otherwise.
  /// This will open Android's Accessibility Settings screen where the user can
  /// enable the service.
  Future<bool> requestAccesibilityPermissions() async {
    return await PermissionManager.requestPermission(
      PermissionType.accessibility,
    );
  }

  /// Requests notification permission by opening notification settings
  ///
  /// Returns `true` if permission is granted after the request, `false` otherwise.
  /// For Android 13+ this will show the system permission dialog.
  /// For older versions, this will open the app's notification settings.
  Future<bool> requestNotificationPermissions() async {
    return await PermissionManager.requestPermission(
      PermissionType.notification,
    );
  }

  /// Requests usage stats permission by opening usage access settings
  ///
  /// Returns `true` if permission is granted after the request, `false` otherwise.
  /// This will open the system settings screen where the user can grant the
  /// PACKAGE_USAGE_STATS permission.
  Future<bool> requestUsageStatePermissions() async {
    return await PermissionManager.requestPermission(PermissionType.usageStats);
  }

  /// Fetch all installed apps on the device
  Future<List<AppModel>> getInstalledApps() async {
    return await _appBlockManager.getInstalledApps();
  }

  /// Block access to an app using its package ID
  Future<bool> blockApp(String appId) async {
    try {
      // Check permissions first
      if (!await requestAccesibilityPermissions() ||
          !await requestOverlayPermissions()) {
        throw Exception('Required permissions not granted');
      }

      // Implement app blocking logic here
      // This might require platform-specific implementation
      // through method channels or a native plugin

      // Placeholder for actual implementation
      return true;
    } catch (e) {
      print('Error blocking app: $e');
      return false;
    }
  }
}
