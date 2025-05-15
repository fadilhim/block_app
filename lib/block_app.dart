/// Support for doing something awesome.
///
library block_app;

export 'src/data/model/app_model.dart';
export 'src/data/model/app_block_config.dart';
export 'src/data/model/excluded_app.dart';
export 'src/data/services/app_block_manager.dart';
export 'src/ui/app_blocking_overlay.dart';

import 'package:flutter/material.dart';
import 'src/data/model/app_model.dart';
import 'src/data/model/app_block_config.dart';
import 'src/data/model/excluded_app.dart';
import 'src/data/services/app_block_manager.dart';
import 'src/ui/app_blocking_overlay.dart';

/// Main class for the block app package.
class BlockApp {
  static final BlockApp _instance = BlockApp._internal();
  final AppBlockManager _blockManager = AppBlockManager();
  AppBlockConfig? _config;

  /// Factory constructor for BlockApp.
  factory BlockApp() {
    return _instance;
  }

  BlockApp._internal();

  /// Initialize the block app with configuration.
  Future<void> initialize({AppBlockConfig? config}) async {
    _config = config ?? const AppBlockConfig();
  }

  /// Get all installed apps on the device.
  ///
  /// Parameters:
  /// - [includeSystemApps]: When true, includes system apps in the results. Default is false.
  /// - [excludedApps]: Optional list of apps to exclude from results.
  ///   Use ExcludedApp.defaultGoogleApps to exclude common Google apps.
  Future<List<AppModel>> getInstalledApps({
    bool includeSystemApps = false,
    List<ExcludedApp> excludedApps = const [],
  }) {
    return _blockManager.getInstalledApps(
      includeSystemApps: includeSystemApps,
      excludedApps: excludedApps,
    );
  }

  /// Block an app by its package name.
  Future<bool> blockApp(String packageName) {
    return _blockManager.blockApp(packageName);
  }

  /// Unblock an app by its package name.
  Future<bool> unblockApp(String packageName) {
    return _blockManager.unblockApp(packageName);
  }

  /// Get all blocked apps.
  Future<List<String>> getBlockedApps() {
    return _blockManager.getBlockedApps();
  }

  /// Check if an app is blocked.
  Future<bool> isAppBlocked(String packageName) {
    return _blockManager.isAppBlocked(packageName);
  }

  /// Block all installed apps except the ones specified in excludePackages.
  ///
  /// Parameters:
  /// - [excludePackages]: A list of package names to exclude from blocking.
  /// - [excludedApps]: A list of ExcludedApp objects to exclude from blocking.
  ///   Use ExcludedApp.defaultGoogleApps to exclude common Google apps.
  /// - [onlyUserApps]: When true, only blocks user-installed apps. Default is true.
  Future<bool> blockAllApps({
    List<String> excludePackages = const [],
    List<ExcludedApp> excludedApps = const [],
    bool onlyUserApps = true,
  }) {
    return _blockManager.blockAllApps(
      excludePackages: excludePackages,
      excludedApps: excludedApps,
      onlyUserApps: onlyUserApps,
    );
  }

  /// Unblock all apps.
  Future<bool> unblockAllApps() {
    return _blockManager.unblockAllApps();
  }

  /// Manually start the blocking service.
  Future<bool> startBlockingService() {
    return _blockManager.startBlockingService();
  }

  /// Manually stop the blocking service.
  Future<bool> stopBlockingService() {
    return _blockManager.stopBlockingService();
  }

  /// Check if the required permissions are granted.
  Future<Map<String, bool>> checkPermissions() {
    return _blockManager.checkPermissions();
  }

  /// Request the overlay permission.
  Future<bool> requestOverlayPermission() {
    return _blockManager.requestOverlayPermission();
  }

  /// Request the usage stats permission.
  Future<bool> requestUsageStatsPermission() {
    return _blockManager.requestUsageStatsPermission();
  }

  /// Register a callback for when a blocked app is detected.
  void onBlockedAppDetected(Function(String packageName) callback) {
    _blockManager.onBlockedAppDetected = callback;
  }

  /// Create a default blocking overlay widget.
  Widget createDefaultBlockingOverlay({
    String? customMessage,
    String? actionButtonText,
    VoidCallback? onActionButtonPressed,
    Color? backgroundColor,
    Color? textColor,
    bool enableCloseButton = true,
  }) {
    return AppBlockingOverlay(
      customMessage: customMessage ?? _config?.defaultMessage,
      actionButtonText: actionButtonText ?? _config?.actionButtonText,
      onActionButtonPressed: onActionButtonPressed,
      backgroundColor:
          backgroundColor ?? _config?.overlayBackgroundColor ?? Colors.black87,
      textColor: textColor ?? _config?.overlayTextColor ?? Colors.white,
      enableCloseButton: enableCloseButton,
    );
  }
}
