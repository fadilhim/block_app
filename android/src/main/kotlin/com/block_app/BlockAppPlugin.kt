package com.block_app

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class BlockAppPlugin: FlutterPlugin, ActivityAware {
    private lateinit var permissionChannel: MethodChannel
    private lateinit var appChannel: MethodChannel
    private var permissionManager: PermissionManager? = null
    private var appManager: AppManager? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        permissionChannel = MethodChannel(binding.binaryMessenger, "com.block_app/permission_manager")
        appChannel = MethodChannel(binding.binaryMessenger, "com.block_app/app_block_manager")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        permissionManager = PermissionManager(binding.activity)
        appManager = AppManager(binding.activity)
        
        permissionChannel.setMethodCallHandler(permissionManager)
        appChannel.setMethodCallHandler(appManager)
    }

    override fun onDetachedFromActivity() {
        permissionChannel.setMethodCallHandler(null)
        appChannel.setMethodCallHandler(null)
        permissionManager = null
        appManager = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        permissionChannel.setMethodCallHandler(null)
        appChannel.setMethodCallHandler(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }
}