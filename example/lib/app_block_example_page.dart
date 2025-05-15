import 'package:flutter/material.dart';
import 'package:block_app/block_app.dart';

/// An example page that demonstrates how to use the app blocking functionality.
class AppBlockExamplePage extends StatefulWidget {
  /// Creates an app block example page.
  const AppBlockExamplePage({Key? key}) : super(key: key);

  @override
  _AppBlockExamplePageState createState() => _AppBlockExamplePageState();
}

class _AppBlockExamplePageState extends State<AppBlockExamplePage> {
  final BlockApp _blockApp = BlockApp();
  final List<AppModel> _installedApps = [];
  final Set<String> _blockedApps = {};
  bool _isLoading = true;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _initializeBlockApp();
  }

  Future<void> _initializeBlockApp() async {
    await _blockApp.initialize(
      config: const AppBlockConfig(
        defaultMessage: 'This app has been blocked for productivity',
        overlayBackgroundColor: Colors.black87,
        overlayTextColor: Colors.white,
        actionButtonText: 'Close',
        autoStartService: true,
      ),
    );

    _blockApp.onBlockedAppDetected((packageName) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Blocked attempt to open app: $packageName'),
          backgroundColor: Colors.red,
        ),
      );
    });

    await _checkPermissions();
    await _loadApps();
  }

  Future<void> _checkPermissions() async {
    final permissions = await _blockApp.checkPermissions();
    setState(() {
      _permissionsGranted =
          permissions['hasOverlayPermission']! &&
          permissions['hasUsageStatsPermission']!;
    });
  }

  Future<void> _requestPermissions() async {
    await _blockApp.requestOverlayPermission();
    await _blockApp.requestUsageStatsPermission();
    await _checkPermissions();
  }

  Future<void> _loadApps() async {
    setState(() {
      _isLoading = true;
    });

    final apps = await _blockApp.getInstalledApps(includeSystemApps: true);
    final blockedAppsList = await _blockApp.getBlockedApps();

    setState(() {
      _installedApps.clear();
      _installedApps.addAll(apps);
      _blockedApps.clear();
      _blockedApps.addAll(blockedAppsList);
      _isLoading = false;
    });
  }

  Future<void> _toggleBlockApp(AppModel app) async {
    final isBlocked = _blockedApps.contains(app.packageName);
    bool success;

    if (isBlocked) {
      success = await _blockApp.unblockApp(app.packageName);
      if (success) {
        setState(() {
          _blockedApps.remove(app.packageName);
        });
      }
    } else {
      success = await _blockApp.blockApp(app.packageName);
      if (success) {
        setState(() {
          _blockedApps.add(app.packageName);
        });
      }
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${isBlocked ? 'unblock' : 'block'} ${app.appName}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Blocker'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadApps),
        ],
      ),
      body:
          !_permissionsGranted
              ? _buildPermissionsRequest()
              : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildAppsList(),
    );
  }

  Widget _buildPermissionsRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Permissions Required',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'This app needs permission to monitor and block other apps.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _requestPermissions,
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsList() {
    return ListView.builder(
      itemCount: _installedApps.length,
      itemBuilder: (context, index) {
        final app = _installedApps[index];
        final isBlocked = _blockedApps.contains(app.packageName);

        return ListTile(
          leading: _buildAppIcon(app),
          title: Text(app.appName),
          subtitle: Text(app.packageName),
          trailing: Switch(
            value: isBlocked,
            activeColor: Colors.red,
            onChanged: (value) => _toggleBlockApp(app),
          ),
        );
      },
    );
  }

  Widget _buildAppIcon(AppModel app) {
    if (app.icon != null) {
      try {
        return Image.memory(
          Uri.parse(app.icon!).data!.contentAsBytes(),
          width: 48,
          height: 48,
        );
      } catch (_) {
        // Fallback to default icon
      }
    }
    return const Icon(Icons.android, size: 48);
  }
}
