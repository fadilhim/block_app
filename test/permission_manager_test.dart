import 'package:flutter_test/flutter_test.dart';
import 'package:block_app/src/data/services/permission_manager.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.block_app/permission_manager');
  final log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);

      // Mock responses for different method calls
      switch (methodCall.method) {
        case 'checkOverlayPermission':
          return true;
        case 'checkAccessibilityPermission':
          return false;
        case 'checkNotificationPermission':
          return true;
        case 'checkUsageStatsPermission':
          return false;
        case 'requestOverlayPermission':
          return true;
        case 'requestAccessibilityPermission':
          return true;
        case 'requestNotificationPermission':
          return true;
        case 'requestUsageStatsPermission':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('PermissionManager', () {
    test('hasPermission should invoke correct method channel', () async {
      // Act
      final overlayResult = await PermissionManager.hasPermission(
        PermissionType.overlay,
      );
      final accessibilityResult = await PermissionManager.hasPermission(
        PermissionType.accessibility,
      );
      final notificationResult = await PermissionManager.hasPermission(
        PermissionType.notification,
      );
      final usageStatsResult = await PermissionManager.hasPermission(
        PermissionType.usageStats,
      );

      // Assert
      expect(overlayResult, isTrue);
      expect(accessibilityResult, isFalse);
      expect(notificationResult, isTrue);
      expect(usageStatsResult, isFalse);

      expect(log, hasLength(4));
      expect(log[0].method, 'checkOverlayPermission');
      expect(log[1].method, 'checkAccessibilityPermission');
      expect(log[2].method, 'checkNotificationPermission');
      expect(log[3].method, 'checkUsageStatsPermission');
    });

    test('requestPermission should invoke correct method channel', () async {
      // Act
      final overlayResult = await PermissionManager.requestPermission(
        PermissionType.overlay,
      );
      final accessibilityResult = await PermissionManager.requestPermission(
        PermissionType.accessibility,
      );
      final notificationResult = await PermissionManager.requestPermission(
        PermissionType.notification,
      );
      final usageStatsResult = await PermissionManager.requestPermission(
        PermissionType.usageStats,
      );

      // Assert
      expect(overlayResult, isTrue);
      expect(accessibilityResult, isTrue);
      expect(notificationResult, isTrue);
      expect(usageStatsResult, isTrue);

      expect(log, hasLength(4));
      expect(log[0].method, 'requestOverlayPermission');
      expect(log[1].method, 'requestAccessibilityPermission');
      expect(log[2].method, 'requestNotificationPermission');
      expect(log[3].method, 'requestUsageStatsPermission');
    });
  });
}
