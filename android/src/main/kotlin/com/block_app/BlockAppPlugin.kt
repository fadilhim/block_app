package com.block_app

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

/** BlockAppPlugin */
class BlockAppPlugin : FlutterPlugin, ActivityAware {
    private lateinit var appManagerChannel: MethodChannel
    private lateinit var overlayChannel: MethodChannel
    private lateinit var permissionChannel: MethodChannel
    private var permissionManager: PermissionManager? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        appManagerChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.block_app/app_block_manager")
        overlayChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.block_app/app_blocking_overlay")
        permissionChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.block_app/permission_manager")
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        appManagerChannel.setMethodCallHandler(null)
        overlayChannel.setMethodCallHandler(null)
        permissionChannel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        AppManager.init(binding.activity)
        permissionManager = PermissionManager(binding.activity)
        
        appManagerChannel.setMethodCallHandler(AppManager)
        permissionChannel.setMethodCallHandler(permissionManager)
    }

    override fun onDetachedFromActivity() {
        appManagerChannel.setMethodCallHandler(null)
        permissionChannel.setMethodCallHandler(null)
        AppManager.dispose()
        permissionManager = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }
}