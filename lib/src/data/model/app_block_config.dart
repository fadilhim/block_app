import 'package:flutter/material.dart';

/// Configuration for app blocking functionality.
class AppBlockConfig {
  /// Custom overlay widget to show when an app is blocked.
  final Widget Function(BuildContext context, String packageName)?
      customOverlayBuilder;

  /// Custom overlay route name.
  final String? customOverlayRoute;

  /// Default message to show on the blocking overlay.
  final String defaultMessage;

  /// Background color for the default overlay.
  final Color overlayBackgroundColor;

  /// Text color for the default overlay.
  final Color overlayTextColor;

  /// Action button text for the default overlay.
  final String actionButtonText;

  /// Whether to enable auto-start blocking service on app launch.
  final bool autoStartService;

  /// Creates an app block configuration.
  const AppBlockConfig({
    this.customOverlayBuilder,
    this.customOverlayRoute,
    this.defaultMessage = 'This app has been blocked for your productivity',
    this.overlayBackgroundColor = Colors.black87,
    this.overlayTextColor = Colors.white,
    this.actionButtonText = 'Close',
    this.autoStartService = true,
  });
}
