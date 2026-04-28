package com.telegramdrive.telegram_drive

import android.content.Context
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges Flutter MethodChannel calls to TelegramManager.
 * Channel name: com.telegramdrive.app/telegram
 *
 * Methods Flutter can call:
 *   initialize(apiId: String, apiHash: String) → void
 *   sendPhoneNumber(phone: String)             → void
 *   checkCode(code: String)                    → void
 *   checkPassword(password: String)            → void
 *   logout()                                   → void
 *
 * Auth events are pushed back via EventChannel:
 *   com.telegramdrive.app/telegram_events
 *   Event map: { "type": "authState", "state": "<tdlib state name>" }
 *              { "type": "error",     "code": "...", "message": "..." }
 */
class TelegramPlugin(private val context: Context) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val METHOD_CHANNEL = "com.telegramdrive.app/telegram"
        const val EVENT_CHANNEL  = "com.telegramdrive.app/telegram_events"
    }

    private val manager = TelegramManager(context)
    private var eventSink: EventChannel.EventSink? = null

    init {
        manager.onAuthState = { state, _ ->
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                eventSink?.success(mapOf("type" to "authState", "state" to state))
            }
        }
        manager.onError = { code, message ->
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                eventSink?.success(mapOf("type" to "error", "code" to code, "message" to message))
            }
        }
    }

    // MethodChannel.MethodCallHandler
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                val apiId   = call.argument<String>("apiId")?.toIntOrNull() ?: 0
                val apiHash = call.argument<String>("apiHash") ?: ""
                manager.initialize(apiId, apiHash)
                result.success(null)
            }
            "sendPhoneNumber" -> {
                val phone = call.argument<String>("phone") ?: ""
                manager.sendPhoneNumber(phone)
                result.success(null)
            }
            "checkCode" -> {
                val code = call.argument<String>("code") ?: ""
                manager.checkCode(code)
                result.success(null)
            }
            "checkPassword" -> {
                val password = call.argument<String>("password") ?: ""
                manager.checkPassword(password)
                result.success(null)
            }
            "logout" -> {
                manager.logout()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // EventChannel.StreamHandler
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
