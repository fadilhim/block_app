import 'package:flutter/material.dart';
import 'package:block_app/src/data/model/app_model.dart';
import 'package:block_app/src/data/services/app_block_manager.dart';

/// Default overlay UI shown when a blocked app is launched.
class AppBlockingOverlay extends StatefulWidget {
  /// Custom message to show on the overlay.
  final String? customMessage;

  /// Custom action button text.
  final String? actionButtonText;

  /// Custom action button callback.
  final VoidCallback? onActionButtonPressed;

  /// Background color of the overlay.
  final Color backgroundColor;

  /// Text color for the overlay.
  final Color textColor;

  /// Whether to enable the close button.
  final bool enableCloseButton;

  /// Creates a default app blocking overlay.
  const AppBlockingOverlay({
    super.key,
    this.customMessage,
    this.actionButtonText,
    this.onActionButtonPressed,
    this.backgroundColor = Colors.black87,
    this.textColor = Colors.white,
    this.enableCloseButton = true,
  });

  @override
  State<AppBlockingOverlay> createState() => _AppBlockingOverlayState();
}

class _AppBlockingOverlayState extends State<AppBlockingOverlay> {
  final AppBlockManager _blockManager = AppBlockManager();
  AppModel? _blockedApp;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBlockedAppInfo();
  }

  Future<void> _fetchBlockedAppInfo() async {
    final packageName = await _blockManager.getCurrentBlockedApp();
    if (packageName != null) {
      final apps = await _blockManager.getInstalledApps(
        includeSystemApps: true,
      );
      setState(() {
        _blockedApp = apps.firstWhere(
          (app) => app.packageName == packageName,
          orElse: () => AppModel(
            packageName: packageName,
            appName: 'Unknown App',
            isSystemApp: false,
          ),
        );
        _isLoading = false;
      });
    } else {
      setState(() {
        _blockedApp = null;
        _isLoading = false;
      });
    }
  }

  void _closeOverlay() {
    _blockManager.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor,
      child: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _buildBlockedAppContent(),
      ),
    );
  }

  Widget _buildBlockedAppContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.block, color: Colors.red, size: 80),
          const SizedBox(height: 24),
          Text(
            _blockedApp?.appName ?? 'Unknown App',
            style: TextStyle(
              color: widget.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.customMessage ??
                'This app has been blocked for your productivity',
            textAlign: TextAlign.center,
            style: TextStyle(color: widget.textColor, fontSize: 18),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: widget.onActionButtonPressed ?? _closeOverlay,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              widget.actionButtonText ?? 'Close',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (widget.enableCloseButton && widget.onActionButtonPressed != null)
            TextButton(
              onPressed: _closeOverlay,
              child: Text(
                'Go Back',
                style:
                    TextStyle(color: widget.textColor.withValues(alpha: 0.7)),
              ),
            ),
        ],
      ),
    );
  }
}
