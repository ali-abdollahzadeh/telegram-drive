package com.teledrive.tele_drive

import android.content.Context
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges Flutter MethodChannel calls to TeleManager.
 * Channel name: com.teledrive.app/telegram
 *
 * Methods Flutter can call:
 *   initialize(apiId: String, apiHash: String) → void
 *   sendPhoneNumber(phone: String)             → void
 *   checkCode(code: String)                    → void
 *   checkPassword(password: String)            → void
 *   logout()                                   → void
 *
 * Auth events are pushed back via EventChannel:
 *   com.teledrive.app/telegram_events
 *   Event map: { "type": "authState", "state": "<tdlib state name>" }
 *              { "type": "error",     "code": "...", "message": "..." }
 */
class TelegramPlugin(private val context: Context) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val METHOD_CHANNEL = "com.teledrive.app/telegram"
        const val EVENT_CHANNEL  = "com.teledrive.app/telegram_events"
    }

    private val manager = TeleManager(context)
    private var eventSink: EventChannel.EventSink? = null

    init {
        manager.onAuthState = { state ->
            eventSink?.success(mapOf("type" to "authState", "state" to state))
        }
        manager.onError = { message ->
            eventSink?.success(mapOf("type" to "error", "message" to message))
        }
        manager.onFileUpdate = { fileInfo ->
            eventSink?.success(mapOf("type" to "fileUpdate", "file" to fileInfo))
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
            "getMe" -> {
                manager.getMe({ user ->
                    result.success(user)
                }, { error ->
                    result.error("TDLIB_ERROR", error, null)
                })
            }
            "getDriveFiles" -> {
                val chatId = call.argument<Number>("chatId")?.toLong() ?: 0L
                val limit = call.argument<Int>("limit") ?: 100
                manager.getChatHistory(chatId, limit, { files ->
                    result.success(files)
                }, { error ->
                    result.error("TDLIB_ERROR", error, null)
                })
            }
            "downloadFile" -> {
                val fileId = call.argument<Int>("fileId") ?: 0
                val priority = call.argument<Int>("priority") ?: 1
                val synchronous = call.argument<Boolean>("synchronous") ?: false
                manager.downloadFile(fileId, priority, synchronous, { file ->
                    result.success(file)
                }, { error ->
                    result.error("TDLIB_ERROR", error, null)
                })
            }
            "getMyChats" -> {
                val limit = call.argument<Int>("limit") ?: 50
                manager.getMyChats(limit, { chats ->
                    result.success(chats)
                }, { error ->
                    result.error("TDLIB_ERROR", error, null)
                })
            }
            "uploadFile" -> {
                val chatId = call.argument<Number>("chatId")?.toLong() ?: 0L
                val filePath = call.argument<String>("filePath") ?: ""
                manager.uploadFile(chatId, filePath, { file ->
                    result.success(file)
                }, { error ->
                    result.error("TDLIB_ERROR", error, null)
                })
            }
            "createFolder" -> {
                val title = call.argument<String>("title") ?: ""
                manager.createPrivateChannel(title, { chat ->
                    result.success(chat)
                }, { error ->
                    result.error("TDLIB_ERROR", error, null)
                })
            }
            "optimizeStorage" -> {
                manager.optimizeStorage({
                    result.success(null)
                }, { error ->
                    result.error("TDLIB_ERROR", error, null)
                })
            }
            "deleteMessages" -> {
                try {
                    val chatId = call.argument<String>("chatId")?.toLongOrNull() ?: 0L
                    if (chatId == 0L) {
                        result.error("INVALID_CHAT_ID", "chatId is 0 or null", null)
                        return
                    }
                    val messageIdStrings = call.argument<List<*>>("messageIds") ?: emptyList<Any>()
                    val messageIds = messageIdStrings.mapNotNull {
                        when (it) {
                            is String -> it.toLongOrNull()
                            is Number -> it.toLong()
                            else -> null
                        }
                    }.toLongArray()
                    if (messageIds.isEmpty()) {
                        result.error("EMPTY_ARRAY", "messageIds is empty or could not be parsed", null)
                        return
                    }
                    val revoke = call.argument<Boolean>("revoke") ?: true
                    manager.deleteMessages(chatId, messageIds, revoke, {
                        result.success(null)
                    }, { error ->
                        result.error("TDLIB_ERROR", error, null)
                    })
                } catch (e: Exception) {
                    result.error("EXCEPTION", e.message, null)
                }
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
