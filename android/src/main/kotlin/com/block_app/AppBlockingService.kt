package com.block_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.WindowManager
import android.widget.FrameLayout
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class AppBlockingService : Service() {
    companion object {
        private const val CHANNEL_ID = "AppBlockingServiceChannel"
        private const val NOTIFICATION_ID = 1001
        private const val CHECK_INTERVAL_MS = 500L
        private const val FLUTTER_ENGINE_ID = "app_blocking_overlay"
        private const val OVERLAY_ROUTE = "appBlockingOverlay"
        private var customOverlayRoute: String? = null
    }

    private val executor = Executors.newSingleThreadScheduledExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private lateinit var windowManager: WindowManager
    private lateinit var flutterEngine: FlutterEngine
    private var overlayView: FrameLayout? = null
    private var currentForegroundApp: String = ""
    private var overlayShowing: Boolean = false

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
        
        AppManager.loadBlockedApps(applicationContext)
        
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        initFlutterEngine()
        
        startAppMonitoring()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let {
            if (it.hasExtra("customOverlayRoute")) {
                customOverlayRoute = it.getStringExtra("customOverlayRoute")
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        executor.shutdownNow()
        hideOverlay()
        flutterEngine.destroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "App Blocking Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors and blocks restricted apps"
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("App Blocking Active")
            .setContentText("Monitoring for blocked apps")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun initFlutterEngine() {
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        
        // Setup method channel for communication with Flutter
        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.block_app/app_blocking_overlay"
        )
        
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "closeOverlay" -> {
                    hideOverlay()
                    result.success(true)
                }
                "getCurrentBlockedApp" -> {
                    result.success(currentForegroundApp)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startAppMonitoring() {
        executor.scheduleAtFixedRate({
            val foregroundApp = getForegroundApp()
            foregroundApp?.let { packageName ->
                if (AppManager.blockedApps.contains(packageName) && packageName != currentForegroundApp) {
                    currentForegroundApp = packageName
                    mainHandler.post {
                        showOverlay(packageName)
                    }
                } else if (!AppManager.blockedApps.contains(packageName) && overlayShowing) {
                    currentForegroundApp = ""
                    mainHandler.post {
                        hideOverlay()
                    }
                }
            }
        }, 0, CHECK_INTERVAL_MS, TimeUnit.MILLISECONDS)
    }

    private fun getForegroundApp(): String? {
        try {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val time = System.currentTimeMillis()
            val events = usageStatsManager.queryEvents(time - 5000, time)
            val usageEvent = UsageEvents.Event()
            var lastEventPackageName: String? = null

            while (events.hasNextEvent()) {
                events.getNextEvent(usageEvent)
                if (usageEvent.eventType == UsageEvents.Event.ACTIVITY_RESUMED || 
                    usageEvent.eventType == UsageEvents.Event.ACTIVITY_PAUSED) {
                    lastEventPackageName = usageEvent.packageName
                }
            }

            return lastEventPackageName
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun showOverlay(packageName: String) {
        if (overlayShowing) return
        
        try {
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) 
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY 
                else 
                    WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT
            )
            params.gravity = Gravity.CENTER
            
            val flutterView = FlutterView(this)
            flutterView.attachToFlutterEngine(flutterEngine)
            
            // Navigate to the Flutter overlay route
            flutterEngine.navigationChannel.pushRoute(
                customOverlayRoute ?: OVERLAY_ROUTE
            )
            
            overlayView = FrameLayout(this).apply {
                addView(flutterView)
            }
            
            windowManager.addView(overlayView, params)
            overlayShowing = true
            
            // Send blocked app data to Flutter
            val methodChannel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "com.block_app/app_blocking_overlay"
            )
            methodChannel.invokeMethod("setBlockedApp", packageName)
            
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun hideOverlay() {
        try {
            overlayView?.let {
                windowManager.removeView(it)
                overlayView = null
                overlayShowing = false
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
} 