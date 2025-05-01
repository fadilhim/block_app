import 'package:flutter/material.dart';
import 'package:block_app/block_app.dart';

/// A demo app that exercises all of BlockAppManager's methods:
/// - check/request overlay, accessibility, notification, and usage-stats permissions
/// - fetch installed apps
/// - block an app by package name
void main() {
  runApp(const PermissionDemoApp());
}

class PermissionDemoApp extends StatelessWidget {
  const PermissionDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block App Demo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const PermissionDemoPage(),
    );
  }
}

class PermissionDemoPage extends StatefulWidget {
  const PermissionDemoPage({super.key});

  @override
  State<PermissionDemoPage> createState() => _PermissionDemoPageState();
}

class _PermissionDemoPageState extends State<PermissionDemoPage> {
  final BlockAppManager _manager = BlockAppManager();
  final TextEditingController _blockController = TextEditingController();
  List<AppModel> _installedApps = [];
  bool _loadingApps = false;

  Future<void> _showResult(String label, Future<bool> call) async {
    final bool granted = await call;
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label: ${granted ? "✅" : "❌"}')));
  }

  Future<void> _loadApps() async {
    setState(() {
      _loadingApps = true;
    });
    final apps = await _manager.getInstalledApps();
    setState(() {
      _installedApps = apps;
      _loadingApps = false;
    });
  }

  Future<void> _blockApp() async {
    final pkg = _blockController.text.trim();
    if (pkg.isEmpty) {
      return;
    }
    final success = await _manager.blockApp(pkg);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Block "$pkg": ${success ? "succeeded ✅" : "failed ❌"}'),
      ),
    );
  }

  @override
  void dispose() {
    _blockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Block App Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Permission Checks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed:
                  () => _showResult(
                    'Overlay permission',
                    _manager.checkOverlayPermission(),
                  ),
              child: const Text('Check Overlay Permission'),
            ),
            ElevatedButton(
              onPressed:
                  () => _showResult(
                    'Request Overlay',
                    _manager.requestOverlayPermissions(),
                  ),
              child: const Text('Request Overlay Permission'),
            ),
            ElevatedButton(
              onPressed:
                  () => _showResult(
                    'Accessibility permission',
                    _manager.checkAccesibilityPermissions(),
                  ),
              child: const Text('Check Accessibility Permission'),
            ),
            ElevatedButton(
              onPressed:
                  () => _showResult(
                    'Request Accessibility',
                    _manager.requestAccesibilityPermissions(),
                  ),
              child: const Text('Request Accessibility Permission'),
            ),
            ElevatedButton(
              onPressed:
                  () => _showResult(
                    'Notification permission',
                    _manager.checkNotificationPermission(),
                  ),
              child: const Text('Check Notification Permission'),
            ),
            ElevatedButton(
              onPressed:
                  () => _showResult(
                    'Request Notification',
                    _manager.requestNotificationPermissions(),
                  ),
              child: const Text('Request Notification Permission'),
            ),
            ElevatedButton(
              onPressed:
                  () => _showResult(
                    'Usage-stats permission',
                    _manager.checkUsageStatePermission(),
                  ),
              child: const Text('Check Usage-Stats Permission'),
            ),
            ElevatedButton(
              onPressed:
                  () => _showResult(
                    'Request Usage-Stats',
                    _manager.requestUsageStatePermissions(),
                  ),
              child: const Text('Request Usage-Stats Permission'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Installed Apps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _loadingApps ? null : _loadApps,
              child: Text(_loadingApps ? 'Loading…' : 'Get Installed Apps'),
            ),
            const SizedBox(height: 8),
            if (_installedApps.isEmpty && !_loadingApps)
              const Text('No apps loaded yet.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _installedApps.length,
                itemBuilder: (_, i) {
                  final app = _installedApps[i];
                  return ListTile(
                    title: Text(app.appName),
                    subtitle: Text(app.packageName),
                    trailing:
                        app.isSystemApp
                            ? const Icon(Icons.settings)
                            : const Icon(Icons.android),
                  );
                },
              ),
            const SizedBox(height: 24),
            const Text(
              'Block an App',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
