package com.block_app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.app.NotificationManager
import android.content.Context
import android.app.AppOpsManager
import android.os.Process
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class PermissionManager(private val activity: Activity) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "checkOverlayPermission" -> {
                result.success(Settings.canDrawOverlays(activity))
            }
            "requestOverlayPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    if (!Settings.canDrawOverlays(activity)) {
                        // If we don't have permission, open Android's settings screen
                        // This will show the user the permission request dialog
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:${activity.packageName}")
                        )
                        // Start the settings activity
                        activity.startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE)
                        result.success(false)
                    } else {
                        result.success(true)
                    }
                } else {
                    result.success(true)
                }
            }
            "checkAccessibilityPermission" -> {
                result.success(isAccessibilityEnabled())
            }
            "requestAccessibilityPermission" -> {
                val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                activity.startActivityForResult(intent, ACCESSIBILITY_PERMISSION_REQ_CODE)
                result.success(false)
            }
            "checkNotificationPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    val notificationManager = activity.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    result.success(notificationManager.areNotificationsEnabled())
                } else {
                    result.success(true)
                }
            }
            "requestNotificationPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                        .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
                    activity.startActivityForResult(intent, NOTIFICATION_PERMISSION_REQ_CODE)
                } else {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                        .setData(Uri.parse("package:${activity.packageName}"))
                    activity.startActivityForResult(intent, NOTIFICATION_PERMISSION_REQ_CODE)
                }
                result.success(false)
            }
            "checkUsageStatsPermission" -> {
                result.success(isUsageStatsEnabled())
            }
            "requestUsageStatsPermission" -> {
                val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                activity.startActivityForResult(intent, USAGE_STATS_PERMISSION_REQ_CODE)
                result.success(false)
            }
            else -> result.notImplemented()
        }
    }

    private fun isAccessibilityEnabled(): Boolean {
        val accessibilityEnabled = try {
            Settings.Secure.getInt(
                activity.contentResolver,
                Settings.Secure.ACCESSIBILITY_ENABLED
            )
        } catch (e: Settings.SettingNotFoundException) {
            0
        }
        return accessibilityEnabled == 1
    }

    private fun isUsageStatsEnabled(): Boolean {
        val appOps = activity.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                activity.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                activity.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    companion object {
        const val OVERLAY_PERMISSION_REQ_CODE = 1234
        const val ACCESSIBILITY_PERMISSION_REQ_CODE = 1235
        const val NOTIFICATION_PERMISSION_REQ_CODE = 1236
        const val USAGE_STATS_PERMISSION_REQ_CODE = 1237
    }
}