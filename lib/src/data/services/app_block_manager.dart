import 'package:flutter/services.dart';
import 'package:block_app/src/data/model/app_model.dart';
import 'package:block_app/src/data/model/excluded_app.dart';
import 'package:block_app/src/data/services/permission_manager.dart';

/// A manager for handling app blocking functionality.
class AppBlockManager {
  static final AppBlockManager _instance = AppBlockManager._internal();
  static const MethodChannel _channel = MethodChannel(
    'com.block_app/app_block_manager',
  );
  static const MethodChannel _overlayChannel = MethodChannel(
    'com.block_app/app_blocking_overlay',
  );

  factory AppBlockManager() {
    return _instance;
  }

  AppBlockManager._internal() {
    _overlayChannel.setMethodCallHandler(_handleOverlayMethodCall);
  }

  /// Callback for when a blocked app is detected
  Function(String packageName)? onBlockedAppDetected;

  /// Handles method calls from the native side.
  Future<dynamic> _handleOverlayMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'setBlockedApp':
        final String packageName = call.arguments as String;
        if (onBlockedAppDetected != null) {
          onBlockedAppDetected!(packageName);
        }
        return true;
      default:
        return null;
    }
  }

  /// Fetch all installed apps on the device.
  ///
  /// Parameters:
  /// - [includeSystemApps]: When true, includes system apps in the results. Default is false.
  /// - [excludedApps]: A list of ExcludedApp objects representing apps to exclude from the results.
  ///   Pass ExcludedApp.defaultGoogleApps to exclude common Google apps.
  Future<List<AppModel>> getInstalledApps({
    bool includeSystemApps = false,
    List<ExcludedApp> excludedApps = const [],
  }) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getInstalledApps',
        {'includeSystemApps': includeSystemApps},
      );

      // Extract package names from the excluded apps list for easier filtering
      final Set<String> excludedPackages =
          excludedApps.map((app) => app.packageName).toSet();

      return result
          .map((app) => AppModel.fromMap(Map<String, dynamic>.from(app)))
          .where((app) =>
              (includeSystemApps || !app.isSystemApp) &&
              !excludedPackages.contains(app.packageName))
          .toList();
    } catch (e) {
      print('Error fetching installed apps: $e');
      return [];
    }
  }

  /// Block an app by its package name.
  Future<bool> blockApp(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('blockApp', {
        'packageName': packageName,
      });
      return result;
    } catch (e) {
      print('Error blocking app: $e');
      return false;
    }
  }

  /// Unblock an app by its package name.
  Future<bool> unblockApp(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('unblockApp', {
        'packageName': packageName,
      });
      return result;
    } catch (e) {
      print('Error unblocking app: $e');
      return false;
    }
  }

  /// Get a list of all blocked app package names.
  Future<List<String>> getBlockedApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getBlockedApps',
      );
      return result.cast<String>();
    } catch (e) {
      print('Error getting blocked apps: $e');
      return [];
    }
  }

  /// Check if an app is blocked.
  Future<bool> isAppBlocked(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('isAppBlocked', {
        'packageName': packageName,
      });
      return result;
    } catch (e) {
      print('Error checking if app is blocked: $e');
      return false;
    }
  }

  /// Block all installed apps except the ones specified in excludePackages.
  ///
  /// Parameters:
  /// - [excludePackages]: A list of package names to exclude from blocking. Default is empty.
  /// - [excludedApps]: A list of ExcludedApp objects to exclude from blocking. Default is empty.
  /// - [onlyUserApps]: When true, only blocks user-installed apps. Default is true.
  Future<bool> blockAllApps({
    List<String> excludePackages = const [],
    List<ExcludedApp> excludedApps = const [],
    bool onlyUserApps = true,
  }) async {
    try {
      // Combine the package names from excludePackages and excludedApps
      final Set<String> allExcludedPackages = {
        ...excludePackages,
        ...excludedApps.map((app) => app.packageName),
      };

      final bool result = await _channel.invokeMethod('blockAllApps', {
        'excludePackages': allExcludedPackages.toList(),
        'onlyUserApps': onlyUserApps,
      });
      return result;
    } catch (e) {
      print('Error blocking all apps: $e');
      return false;
    }
  }

  /// Unblock all apps.
  Future<bool> unblockAllApps() async {
    try {
      final bool result = await _channel.invokeMethod('unblockAllApps');
      return result;
    } catch (e) {
      print('Error unblocking all apps: $e');
      return false;
    }
  }

  /// Manually start the blocking service.
  Future<bool> startBlockingService() async {
    try {
      final bool result = await _channel.invokeMethod('startBlockingService');
      return result;
    } catch (e) {
      print('Error starting blocking service: $e');
      return false;
    }
  }

  /// Manually stop the blocking service.
  Future<bool> stopBlockingService() async {
    try {
      final bool result = await _channel.invokeMethod('stopBlockingService');
      return result;
    } catch (e) {
      print('Error stopping blocking service: $e');
      return false;
    }
  }

  /// Check if the required permissions are granted.
  Future<Map<String, bool>> checkPermissions() async {
    try {
      // Use the PermissionManager to check permissions
      final bool hasOverlayPermission = await PermissionManager.hasPermission(
        PermissionType.overlay,
      );

      final bool hasUsageStatsPermission =
          await PermissionManager.hasPermission(PermissionType.usageStats);

      return {
        'hasOverlayPermission': hasOverlayPermission,
        'hasUsageStatsPermission': hasUsageStatsPermission,
      };
    } on MissingPluginException catch (e) {
      print(
          'Warning: Permission manager not properly initialized: ${e.message}');
      print(
          'This might be because you are running in an environment that does not support these permissions.');
      print('Returning default permission values (false).');
      return {'hasOverlayPermission': false, 'hasUsageStatsPermission': false};
    } catch (e) {
      print('Error checking permissions: $e');
      return {'hasOverlayPermission': false, 'hasUsageStatsPermission': false};
    }
  }

  /// Request the overlay permission.
  Future<bool> requestOverlayPermission() async {
    return PermissionManager.requestPermission(PermissionType.overlay);
  }

  /// Request the usage stats permission.
  Future<bool> requestUsageStatsPermission() async {
    return PermissionManager.requestPermission(PermissionType.usageStats);
  }

  /// Close the blocking overlay.
  Future<bool> closeOverlay() async {
    try {
      final bool result = await _overlayChannel.invokeMethod('closeOverlay');
      return result;
    } catch (e) {
      print('Error closing overlay: $e');
      return false;
    }
  }

  /// Get the currently blocked app package name.
  Future<String?> getCurrentBlockedApp() async {
    try {
      final String result = await _overlayChannel.invokeMethod(
        'getCurrentBlockedApp',
      );
      return result.isEmpty ? null : result;
    } catch (e) {
      print('Error getting current blocked app: $e');
      return null;
    }
  }
}
