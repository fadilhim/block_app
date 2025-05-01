import 'package:flutter/services.dart';

/// Enum defining different types of permissions
enum PermissionType { overlay, accessibility, notification, usageStats }

/// A generic permission manager class that handles different types of permissions
class PermissionManager {
  static const MethodChannel _channel = MethodChannel(
    'com.block_app/permission_manager',
  );

  /// Check if a specific permission is granted
  static Future<bool> hasPermission(PermissionType permission) async {
    try {
      final String methodName = _getCheckMethodName(permission);
      final bool hasPermission = await _channel.invokeMethod(methodName);
      return hasPermission;
    } on PlatformException catch (e) {
      print('Error checking permission ${permission.name}: ${e.message}');
      return false;
    }
  }

  /// Request a specific permission
  static Future<bool> requestPermission(PermissionType permission) async {
    try {
      final String methodName = _getRequestMethodName(permission);
      final bool granted = await _channel.invokeMethod(methodName);
      return granted;
    } on PlatformException catch (e) {
      print('Error requesting permission ${permission.name}: ${e.message}');
      return false;
    }
  }

  /// Get the method name for checking a specific permission
  static String _getCheckMethodName(PermissionType permission) {
    switch (permission) {
      case PermissionType.overlay:
        return 'checkOverlayPermission';
      case PermissionType.accessibility:
        return 'checkAccessibilityPermission';
      case PermissionType.notification:
        return 'checkNotificationPermission';
      case PermissionType.usageStats:
        return 'checkUsageStatsPermission';
    }
  }

  /// Get the method name for requesting a specific permission
  static String _getRequestMethodName(PermissionType permission) {
    switch (permission) {
      case PermissionType.overlay:
        return 'requestOverlayPermission';
      case PermissionType.accessibility:
        return 'requestAccessibilityPermission';
      case PermissionType.notification:
        return 'requestNotificationPermission';
      case PermissionType.usageStats:
        return 'requestUsageStatsPermission';
    }
  }
}
