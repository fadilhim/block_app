package com.block_app

import android.app.Activity
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AppManager(private val activity: Activity) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getInstalledApps" -> {
                try {
                    val apps = getInstalledApps()
                    result.success(apps)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to get installed apps", e.message)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val packageManager = activity.packageManager
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        
        return installedApps.map { appInfo ->
            mapOf(
                "packageName" to appInfo.packageName,
                "appName" to (packageManager.getApplicationLabel(appInfo).toString()),
                "isSystemApp" to ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0)
            )
        }
    }
}