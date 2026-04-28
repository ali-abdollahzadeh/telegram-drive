package com.telegramdrive.telegram_drive

import android.content.Context
import android.os.Build
import android.util.Log
import org.drinkless.td.libcore.telegram.Client
import org.drinkless.td.libcore.telegram.TdApi

/**
 * Wraps the TDLib Java API (org.drinkless.td) to manage Telegram authentication.
 *
 * Auth state machine:
 *  authorizationStateWaitTdlibParameters → sends API params automatically
 *  authorizationStateWaitPhoneNumber     → ready for phone number input
 *  authorizationStateWaitCode            → code sent to Telegram app ✅
 *  authorizationStateWaitPassword        → 2FA password needed
 *  authorizationStateReady               → fully authenticated ✅
 */
class TelegramManager(private val context: Context) {

    companion object {
        private const val TAG = "TelegramManager"
    }

    private var client: Client? = null
    private var apiId: Int = 0
    private var apiHash: String = ""

    // Callbacks to TelegramPlugin → Flutter
    var onAuthState: ((String) -> Unit)? = null
    var onError: ((String) -> Unit)? = null

    // ---------- Public API ----------

    fun initialize(apiId: Int, apiHash: String) {
        this.apiId = apiId
        this.apiHash = apiHash

        Client.setLogVerbosityLevel(1) // 1 = errors only

        client = Client.create(
            ::handleUpdate,   // UpdatesHandler
            null,             // UpdateExceptionHandler
            null              // DefaultExceptionHandler
        )
    }

    fun sendPhoneNumber(phone: String) {
        client?.send(
            TdApi.SetAuthenticationPhoneNumber(phone, null),
            ::handleResult
        )
    }

    fun checkCode(code: String) {
        client?.send(TdApi.CheckAuthenticationCode(code), ::handleResult)
    }

    fun checkPassword(password: String) {
        client?.send(TdApi.CheckAuthenticationPassword(password), ::handleResult)
    }

    fun logout() {
        client?.send(TdApi.LogOut(), ::handleResult)
        client?.close()
        client = null
    }

    fun destroy() {
        client?.close()
        client = null
    }

    // ---------- TDLib handlers ----------

    private fun handleUpdate(obj: TdApi.Object) {
        Log.d(TAG, "Update: ${obj.javaClass.simpleName}")

        when (obj) {
            is TdApi.UpdateAuthorizationState -> handleAuthState(obj.authorizationState)
            else -> { /* other updates — drive feature will handle these */ }
        }
    }

    private fun handleAuthState(state: TdApi.AuthorizationState) {
        Log.d(TAG, "Auth state: ${state.javaClass.simpleName}")

        when (state) {
            is TdApi.AuthorizationStateWaitTdlibParameters -> {
                // Auto-send TDLib parameters
                sendTdlibParameters()
            }
            is TdApi.AuthorizationStateWaitPhoneNumber -> {
                onAuthState?.invoke("authorizationStateWaitPhoneNumber")
            }
            is TdApi.AuthorizationStateWaitCode -> {
                onAuthState?.invoke("authorizationStateWaitCode")
            }
            is TdApi.AuthorizationStateWaitPassword -> {
                onAuthState?.invoke("authorizationStateWaitPassword")
            }
            is TdApi.AuthorizationStateReady -> {
                onAuthState?.invoke("authorizationStateReady")
            }
            is TdApi.AuthorizationStateLoggingOut -> {
                onAuthState?.invoke("authorizationStateLoggingOut")
            }
            is TdApi.AuthorizationStateClosed -> {
                onAuthState?.invoke("authorizationStateClosed")
            }
            else -> Log.d(TAG, "Unhandled auth state: $state")
        }
    }

    private fun handleResult(obj: TdApi.Object) {
        if (obj is TdApi.Error) {
            Log.e(TAG, "TDLib error [${obj.code}]: ${obj.message}")
            onError?.invoke("${obj.message} (code: ${obj.code})")
        }
    }

    // ---------- Private ----------

    private fun sendTdlibParameters() {
        val params = TdApi.SetTdlibParameters().apply {
            apiId      = this@TelegramManager.apiId
            apiHash    = this@TelegramManager.apiHash
            databaseDirectory   = context.filesDir.absolutePath + "/tdlib"
            filesDirectory      = context.filesDir.absolutePath + "/tdlib/files"
            useMessageDatabase  = true
            useSecretChats      = false
            systemLanguageCode  = "en"
            deviceModel         = Build.MODEL
            systemVersion       = Build.VERSION.RELEASE
            applicationVersion  = "1.0"
        }
        client?.send(params, ::handleResult)
    }
}
