import 'package:flutter/services.dart';
import 'package:block_app/src/data/model/app_model.dart';

class AppBlockManager {
  static final AppBlockManager _instance = AppBlockManager._internal();
  static const MethodChannel _channel = MethodChannel('com.block_app/app_block_manager');

  factory AppBlockManager() {
    return _instance;
  }

  AppBlockManager._internal();

  /// Fetch all installed apps on the device
  Future<List<AppModel>> getInstalledApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getInstalledApps',
      );

      return result
          .map((app) => AppModel.fromMap(Map<String, dynamic>.from(app)))
          .toList();
    } catch (e) {
      print('Error fetching installed apps: $e');
      return [];
    }
  }
}
