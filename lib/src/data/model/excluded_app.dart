/// Represents an app to be excluded from app listings or blocking operations.
class ExcludedApp {
  /// The package name of the app to exclude
  final String packageName;

  /// The name of the app (for readability)
  final String appName;

  /// Creates an excluded app instance
  const ExcludedApp({
    required this.packageName,
    required this.appName,
  });

  /// Google Maps app
  static const ExcludedApp googleMaps = ExcludedApp(
    packageName: 'com.google.android.apps.maps',
    appName: 'Google Maps',
  );

  /// YouTube app
  static const ExcludedApp youtube = ExcludedApp(
    packageName: 'com.google.android.youtube',
    appName: 'YouTube',
  );

  /// Chrome browser
  static const ExcludedApp chrome = ExcludedApp(
    packageName: 'com.android.chrome',
    appName: 'Google Chrome',
  );

  /// YouTube Music app
  static const ExcludedApp youtubeMusic = ExcludedApp(
    packageName: 'com.google.android.apps.youtube.music',
    appName: 'YouTube Music',
  );

  /// Gmail app
  static const ExcludedApp gmail = ExcludedApp(
    packageName: 'com.google.android.gm',
    appName: 'Gmail',
  );

  /// Google Photos app
  static const ExcludedApp googlePhotos = ExcludedApp(
    packageName: 'com.google.android.apps.photos',
    appName: 'Google Photos',
  );

  /// Google Drive app
  static const ExcludedApp googleDrive = ExcludedApp(
    packageName: 'com.google.android.apps.docs',
    appName: 'Google Drive',
  );

  /// Google Play Store
  static const ExcludedApp googlePlayStore = ExcludedApp(
    packageName: 'com.android.vending',
    appName: 'Google Play Store',
  );

  /// Google Messages
  static const ExcludedApp googleMessages = ExcludedApp(
    packageName: 'com.google.android.apps.messaging',
    appName: 'Google Messages',
  );

  /// List of common Google apps to exclude
  static const List<ExcludedApp> defaultGoogleApps = [
    googleMaps,
    youtube,
    chrome,
    youtubeMusic,
    gmail,
    googlePhotos,
    googleDrive,
    googlePlayStore,
    googleMessages,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExcludedApp &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;
}
