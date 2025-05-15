class AppModel {
  final String packageName;
  final String appName;
  final bool isSystemApp;
  final String? icon; // Base64 encoded icon data

  AppModel({
    required this.packageName,
    required this.appName,
    required this.isSystemApp,
    this.icon,
  });

  factory AppModel.fromMap(Map<String, dynamic> map) {
    return AppModel(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      isSystemApp: map['isSystemApp'] as bool,
      icon: map['icon'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'isSystemApp': isSystemApp,
      'icon': icon,
    };
  }
}
