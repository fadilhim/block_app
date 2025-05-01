import 'package:flutter_test/flutter_test.dart';
import 'package:block_app/src/block_app_base.dart';
import 'package:block_app/src/data/model/app_model.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BlockAppManager blockAppManager;
  const permissionChannel = MethodChannel('com.block_app/permission_manager');
  const appChannel = MethodChannel('com.block_app/app_block_manager');

  setUp(() {
    blockAppManager = BlockAppManager();

    // Mock permission channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (
          MethodCall methodCall,
        ) async {
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

    // Mock app channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appChannel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getInstalledApps':
              return [
                {
                  'packageName': 'com.example.app1',
                  'appName': 'App 1',
                  'isSystemApp': false,
                },
                {
                  'packageName': 'com.android.settings',
                  'appName': 'Settings',
                  'isSystemApp': true,
                },
              ];
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appChannel, null);
  });

  group('BlockAppManager Tests', () {
    test('checkOverlayPermission returns correct value', () async {
      final result = await blockAppManager.checkOverlayPermission();
      expect(result, true);
    });

    test('checkAccessibilityPermissions returns correct value', () async {
      final result = await blockAppManager.checkAccesibilityPermissions();
      expect(result, false);
    });

    test('checkNotificationPermission returns correct value', () async {
      final result = await blockAppManager.checkNotificationPermission();
      expect(result, true);
    });

    test('checkUsageStatePermission returns correct value', () async {
      final result = await blockAppManager.checkUsageStatePermission();
      expect(result, false);
    });

    test('requestOverlayPermissions returns correct value', () async {
      final result = await blockAppManager.requestOverlayPermissions();
      expect(result, true);
    });

    test('requestAccesibilityPermissions returns correct value', () async {
      final result = await blockAppManager.requestAccesibilityPermissions();
      expect(result, true);
    });

    test('requestNotificationPermissions returns correct value', () async {
      final result = await blockAppManager.requestNotificationPermissions();
      expect(result, true);
    });

    test('requestUsageStatePermissions returns correct value', () async {
      final result = await blockAppManager.requestUsageStatePermissions();
      expect(result, true);
    });

    group('App Management Tests', () {
      test('getInstalledApps returns list of apps', () async {
        final apps = await blockAppManager.getInstalledApps();

        expect(apps, isA<List<AppModel>>());
        expect(apps.length, 2);

        // Check regular app
        expect(apps[0].packageName, 'com.example.app1');
        expect(apps[0].appName, 'App 1');
        expect(apps[0].isSystemApp, false);

        // Check system app
        expect(apps[1].packageName, 'com.android.settings');
        expect(apps[1].appName, 'Settings');
        expect(apps[1].isSystemApp, true);
      });

      test('getInstalledApps handles error', () async {
        // Override mock to simulate error
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(appChannel, (
              MethodCall methodCall,
            ) async {
              throw PlatformException(
                code: 'ERROR',
                message: 'Failed to get apps',
              );
            });

        final apps = await blockAppManager.getInstalledApps();
        expect(apps, isEmpty);
      });
    });
  });
}
