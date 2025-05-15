package com.block_app

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.util.Base64
import java.io.ByteArrayOutputStream
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.SharedPreferences

object AppManager : MethodCallHandler {
    private const val PREFS_NAME = "AppBlockingPrefs"
    private const val BLOCKED_APPS_KEY = "blockedApps"

    // Holds the in-memory set of blocked apps
    var blockedApps: MutableSet<String> = mutableSetOf()
        private set // Restrict direct modification from outside

    private var activity: Activity? = null
    private val permissionManager: PermissionManager?
        get() = activity?.let { PermissionManager(it) }

    fun init(activity: Activity) {
        this.activity = activity
        // It's good practice to load persisted state when the context is available
        loadBlockedApps(activity.applicationContext)
    }

    fun dispose() {
        this.activity = null
        // Potentially add other cleanup logic here if needed in the future
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getInstalledApps" -> {
                try {
                    val includeSystemApps = call.argument<Boolean>("includeSystemApps") ?: false
                    val apps = getInstalledApps(includeSystemApps)
                    result.success(apps)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to get installed apps", e.message)
                }
            }
            "blockApp" -> {
                try {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        blockApp(packageName)
                        result.success(true)
                    } else {
                        result.error("ERROR", "Package name is required", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to block app", e.message)
                }
            }
            "unblockApp" -> {
                try {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        unblockApp(packageName)
                        result.success(true)
                    } else {
                        result.error("ERROR", "Package name is required", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to unblock app", e.message)
                }
            }
            "getBlockedApps" -> {
                try {
                    result.success(blockedApps.toList())
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to get blocked apps", e.message)
                }
            }
            "isAppBlocked" -> {
                try {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        result.success(isAppBlocked(packageName))
                    } else {
                        result.error("ERROR", "Package name is required", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to check if app is blocked", e.message)
                }
            }
            "checkPermissions" -> {
                try {
                    result.success(mapOf(
                        "hasOverlayPermission" to permissionManager?.isOverlayPermissionGranted(),
                        "hasUsageStatsPermission" to permissionManager?.isUsageStatsEnabled()
                    ))
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to check permissions", e.message)
                }
            }
            "requestOverlayPermission" -> {
                try {
                    permissionManager?.requestOverlayPermission()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to request overlay permission", e.message)
                }
            }
            "requestUsageStatsPermission" -> {
                try {
                    permissionManager?.requestUsageStatsPermission()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to request usage stats permission", e.message)
                }
            }
            "blockAllApps" -> {
                try {
                    val excludePackages = call.argument<List<String>>("excludePackages") ?: listOf()
                    val onlyUserApps = call.argument<Boolean>("onlyUserApps") ?: true
                    
                    blockAllApps(excludePackages, onlyUserApps)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to block all apps", e.message)
                }
            }
            "unblockAllApps" -> {
                try {
                    unblockAllApps()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to unblock all apps", e.message)
                }
            }
            "startBlockingService" -> {
                try {
                    startBlockingService()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to start blocking service", e.message)
                }
            }
            "stopBlockingService" -> {
                try {
                    stopBlockingService()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to stop blocking service", e.message)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getInstalledApps(includeSystemApps: Boolean = false): List<Map<String, Any>> {
        val currentActivity = activity ?: return emptyList() // Early exit if activity is null
        val packageManager = currentActivity.packageManager
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        
        return installedApps
            .filter { appInfo -> 
                includeSystemApps || (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0
            }
            .map { appInfo ->
                val iconBase64 = try {
                    val drawable = packageManager.getApplicationIcon(appInfo.packageName)
                    drawableToBase64(drawable)
                } catch (e: Exception) {
                    null
                }
                
                mapOf(
                    "packageName" to appInfo.packageName as Any,
                    "appName" to (packageManager.getApplicationLabel(appInfo).toString()) as Any,
                    "isSystemApp" to ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) as Any,
                    "icon" to (iconBase64 ?: "") as Any
                )
            }
    }
    
    private fun drawableToBase64(drawable: Drawable): String {
        try {
            val bitmap = Bitmap.createBitmap(
                drawable.intrinsicWidth,
                drawable.intrinsicHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            
            val byteArrayOutputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
            val byteArray = byteArrayOutputStream.toByteArray()
            return Base64.encodeToString(byteArray, Base64.DEFAULT)
        } catch (e: Exception) {
            return "" // Return empty string instead of null
        }
    }
    
    private fun blockApp(packageName: String) {
        blockedApps.add(packageName)
        // Start the app blocking service if needed
        saveBlockedApps() // Persist changes
        startBlockingService()
    }
    
    private fun unblockApp(packageName: String) {
        blockedApps.remove(packageName)
        saveBlockedApps() // Persist changes
        // If no apps are blocked, stop the service
        if (blockedApps.isEmpty()) {
            stopBlockingService()
        }
    }
    
    private fun isAppBlocked(packageName: String): Boolean {
        return blockedApps.contains(packageName)
    }
    
    private fun blockAllApps(excludePackages: List<String>, onlyUserApps: Boolean) {
        val currentActivity = activity ?: return // Early exit if activity is null
        val packageManager = currentActivity.packageManager
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        
        installedApps
            .filter { appInfo -> 
                val isUserApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0
                val isNotExcluded = !excludePackages.contains(appInfo.packageName)
                val isNotOurApp = appInfo.packageName != currentActivity.packageName
                
                isNotExcluded && isNotOurApp && (!onlyUserApps || isUserApp)
            }
            .forEach { appInfo ->
                blockedApps.add(appInfo.packageName)
            }
        
        if (blockedApps.isNotEmpty()) {
            saveBlockedApps() // Persist changes
            startBlockingService()
        }
    }
    
    private fun unblockAllApps() {
        blockedApps.clear()
        saveBlockedApps() // Persist changes
        stopBlockingService()
    }
    
    private fun startBlockingService() {
        activity?.let {
            val serviceIntent = Intent(it, AppBlockingService::class.java)
            it.startService(serviceIntent)
        }
    }
    
    private fun stopBlockingService() {
        activity?.let {
            val serviceIntent = Intent(it, AppBlockingService::class.java)
            it.stopService(serviceIntent)
        }
    }

    /**
     * Loads the set of blocked app package names from SharedPreferences.
     * This should be called when the application or service starts.
     */
    fun loadBlockedApps(context: Context) {
        val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        // Retrieve the set, defaulting to an empty set if not found
        val loadedApps = prefs.getStringSet(BLOCKED_APPS_KEY, mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        blockedApps.clear()
        blockedApps.addAll(loadedApps)
    }

    /**
     * Updates the list of blocked apps and saves it to SharedPreferences.
     * This method should be called from your Flutter plugin when the user
     * modifies the block list.
     *
     * @param context Context to access SharedPreferences.
     * @param newBlockedApps The new set of package names to be blocked.
     */
    fun updateBlockedApps(context: Context, newBlockedApps: Set<String>) {
        blockedApps.clear()
        blockedApps.addAll(newBlockedApps)
        saveBlockedApps(context)
    }

    /**
     * Saves the current set of blocked apps to SharedPreferences.
     *
     * @param context Context to access SharedPreferences. If null, uses the initialized activity's context.
     */
    private fun saveBlockedApps(context: Context? = null) {
        val ctx = context ?: activity?.applicationContext ?: return // Early exit if no context
        val prefs: SharedPreferences = ctx.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor: SharedPreferences.Editor = prefs.edit()
        editor.putStringSet(BLOCKED_APPS_KEY, blockedApps)
        editor.apply() // Apply changes asynchronously
    }

    /**
     * Adds a single app to the blocked list and persists the change.
     * (Convenience method, might be called from platform channel)
     *
     * @param context Context to access SharedPreferences. If null, uses the initialized activity's context.
     * @param packageName The package name of the app to add.
     */
    fun addBlockedApp(context: Context? = null, packageName: String) {
        if (blockedApps.add(packageName)) { // add returns true if the element was added
            saveBlockedApps(context)
        }
    }

    /**
     * Removes a single app from the blocked list and persists the change.
     * (Convenience method, might be called from platform channel)
     *
     * @param context Context to access SharedPreferences. If null, uses the initialized activity's context.
     * @param packageName The package name of the app to remove.
     */
    fun removeBlockedApp(context: Context? = null, packageName: String) {
        if (blockedApps.remove(packageName)) { // remove returns true if the element was removed
            saveBlockedApps(context)
        }
    }
}