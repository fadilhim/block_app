import 'package:example/app_block_example_page.dart';
import 'package:flutter/material.dart';
import 'package:block_app/block_app.dart';

/// A demo app that exercises all of BlockAppManager's methods:
/// - check/request overlay, accessibility, notification, and usage-stats permissions
/// - fetch installed apps
/// - block an app by package name
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block App Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

/// An example page that demonstrates how to use the app blocking functionality.
class HomePage extends StatefulWidget {
  /// Creates an app block example page.
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BlockApp _blockApp = BlockApp();
  final Map<String, bool> _permissions = {
    'hasOverlayPermission': false,
    'hasUsageStatsPermission': false,
  };
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initBlockApp();
  }

  Future<void> _initBlockApp() async {
    await _blockApp.initialize(
      config: const AppBlockConfig(
        defaultMessage: 'This app has been blocked for productivity',
        overlayBackgroundColor: Colors.black87,
        overlayTextColor: Colors.white,
        actionButtonText: 'Close',
        autoStartService: true,
      ),
    );

    setState(() {
      _isInitialized = true;
    });

    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    final permissions = await _blockApp.checkPermissions();
    setState(() {
      _permissions.addAll(permissions);
    });
  }

  Future<void> _requestOverlayPermission() async {
    await _blockApp.requestOverlayPermission();
    await _checkAllPermissions();
  }

  Future<void> _requestUsageStatsPermission() async {
    await _blockApp.requestUsageStatsPermission();
    await _checkAllPermissions();
  }

  Future<void> _openAppBlockingPage() async {
    if (_permissions['hasOverlayPermission']! &&
        _permissions['hasUsageStatsPermission']!) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AppBlockExamplePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please grant all required permissions first'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Block App Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Required Permissions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Overlay Permission
            PermissionItem(
              title: 'Display Over Other Apps',
              isGranted: _permissions['hasOverlayPermission'] ?? false,
              onCheck: _checkAllPermissions,
              onRequest: _requestOverlayPermission,
              description:
                  'Required to show blocking overlay when a blocked app is launched',
            ),

            const SizedBox(height: 16),

            // Usage Stats Permission
            PermissionItem(
              title: 'Usage Stats Access',
              isGranted: _permissions['hasUsageStatsPermission'] ?? false,
              onCheck: _checkAllPermissions,
              onRequest: _requestUsageStatsPermission,
              description: 'Required to detect when a blocked app is launched',
            ),

            const SizedBox(height: 32),

            Center(
              child: ElevatedButton.icon(
                onPressed: _openAppBlockingPage,
                icon: const Icon(Icons.block),
                label: const Text('Open App Blocking Page'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionItem extends StatelessWidget {
  final String title;
  final bool isGranted;
  final VoidCallback onCheck;
  final VoidCallback onRequest;
  final String description;

  const PermissionItem({
    Key? key,
    required this.title,
    required this.isGranted,
    required this.onCheck,
    required this.onRequest,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isGranted ? Colors.green : Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGranted ? Icons.check_circle : Icons.error,
                color: isGranted ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: onCheck, child: const Text('Check')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onRequest,
                child: const Text('Request'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
