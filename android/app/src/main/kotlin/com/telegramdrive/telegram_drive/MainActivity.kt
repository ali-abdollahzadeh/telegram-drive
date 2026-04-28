package com.telegramdrive.telegram_drive

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var plugin: TelegramPlugin

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        plugin = TelegramPlugin(applicationContext)

        // Register method channel (Flutter → Kotlin calls)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            TelegramPlugin.METHOD_CHANNEL
        ).setMethodCallHandler(plugin)

        // Register event channel (Kotlin → Flutter push updates)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            TelegramPlugin.EVENT_CHANNEL
        ).setStreamHandler(plugin)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::plugin.isInitialized) {
            plugin.onCancel(null)
        }
    }
}
