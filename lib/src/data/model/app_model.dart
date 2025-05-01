class AppModel {
  final String packageName;
  final String appName;
  final bool isSystemApp;

  AppModel({
    required this.packageName,
    required this.appName,
    required this.isSystemApp,
  });

  factory AppModel.fromMap(Map<String, dynamic> map) {
    return AppModel(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      isSystemApp: map['isSystemApp'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'isSystemApp': isSystemApp,
    };
  }
}
