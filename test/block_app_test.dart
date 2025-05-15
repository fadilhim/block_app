import 'package:flutter_test/flutter_test.dart';
import 'package:block_app/block_app.dart';
import 'package:block_app/src/data/model/app_block_config.dart';
import 'package:flutter/widgets.dart';

void main() {
  late BlockApp blockApp;

  setUp(() {
    blockApp = BlockApp();
  });

  group('BlockApp Config Tests', () {
    test('initialize sets default config when none provided', () async {
      // Act
      await blockApp.initialize();
      // No assertions needed, just verifying it doesn't throw
    });

    test('initialize accepts custom config', () async {
      // Arrange
      final config = AppBlockConfig(
        defaultMessage: 'Test message',
        overlayBackgroundColor: const Color(0xFF000000),
        overlayTextColor: const Color(0xFFFFFFFF),
        actionButtonText: 'Test button',
        autoStartService: false,
      );

      // Act
      await blockApp.initialize(config: config);
      // No assertions needed, just verifying it doesn't throw
    });
  });

  group('Default Overlay Tests', () {
    test('createDefaultBlockingOverlay returns AppBlockingOverlay', () {
      // Act
      final overlay = blockApp.createDefaultBlockingOverlay();

      // Assert
      expect(overlay, isA<AppBlockingOverlay>());
    });

    test('createDefaultBlockingOverlay accepts custom parameters', () {
      // Act
      final overlay = blockApp.createDefaultBlockingOverlay(
        customMessage: 'Custom message',
        actionButtonText: 'Custom button',
        backgroundColor: const Color(0xFF000000),
        textColor: const Color(0xFFFFFFFF),
        enableCloseButton: false,
      );

      // Assert
      expect(overlay, isA<AppBlockingOverlay>());
    });
  });

  // Note: Testing methods that interact with platform channels
  // would typically be done with mocks, but in this simplified approach
  // we're just ensuring they exist and return the expected type
  group('Method Existence Tests', () {
    test('API methods exist and return expected types', () {
      // Check that methods exist and return the expected types
      expect(blockApp.getInstalledApps(), isA<Future<List<AppModel>>>());
      expect(blockApp.blockApp('test'), isA<Future<bool>>());
      expect(blockApp.unblockApp('test'), isA<Future<bool>>());
      expect(blockApp.getBlockedApps(), isA<Future<List<String>>>());
      expect(blockApp.isAppBlocked('test'), isA<Future<bool>>());
      expect(blockApp.blockAllApps(), isA<Future<bool>>());
      expect(blockApp.unblockAllApps(), isA<Future<bool>>());
      expect(blockApp.startBlockingService(), isA<Future<bool>>());
      expect(blockApp.stopBlockingService(), isA<Future<bool>>());
      expect(blockApp.checkPermissions(), isA<Future<Map<String, bool>>>());
      expect(blockApp.requestOverlayPermission(), isA<Future<bool>>());
      expect(blockApp.requestUsageStatsPermission(), isA<Future<bool>>());

      // Callback registration doesn't throw
      blockApp.onBlockedAppDetected((packageName) {});
    });
  });
}
