package com.telegramdrive.telegram_drive

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import org.drinkless.tdlib.Client
import org.drinkless.tdlib.TdApi

/**
 * Wraps the TDLib Java API (org.drinkless.tdlib) to manage Telegram authentication.
 *
 * Auth state machine:
 *   authorizationStateWaitTdlibParameters → sends API params automatically
 *   authorizationStateWaitPhoneNumber     → ready for phone number
 *   authorizationStateWaitCode            → code sent to user's Telegram app ✅
 *   authorizationStateWaitPassword        → 2FA password needed
 *   authorizationStateReady               → fully authenticated ✅
 */
class TelegramManager(private val context: Context) {

    companion object {
        private const val TAG = "TelegramManager"
    }

    private var client: Client? = null
    private var apiId: Int = 0
    private var apiHash: String = ""
    private val mainHandler = Handler(Looper.getMainLooper())

    // Callbacks fired on main thread → TelegramPlugin → Flutter
    var onAuthState: ((String) -> Unit)? = null
    var onError: ((String) -> Unit)? = null

    // ---------- Public API ----------

    fun initialize(apiId: Int, apiHash: String) {
        this.apiId = apiId
        this.apiHash = apiHash

        // Suppress verbose TDLib logging (1 = errors only)
        Client.execute(TdApi.SetLogVerbosityLevel(1))

        client = Client.create(::handleUpdate, null, null)
    }

    fun sendPhoneNumber(phone: String) {
        client?.send(TdApi.SetAuthenticationPhoneNumber(phone, null), ::handleResult)
    }

    fun checkCode(code: String) {
        client?.send(TdApi.CheckAuthenticationCode(code), ::handleResult)
    }

    fun checkPassword(password: String) {
        client?.send(TdApi.CheckAuthenticationPassword(password), ::handleResult)
    }

    fun logout() {
        client?.send(TdApi.LogOut(), ::handleResult)
        client?.send(TdApi.Close(), ::handleResult)
        client = null
    }

    fun destroy() {
        client?.send(TdApi.Close(), ::handleResult)
        client = null
    }

    // ---------- Update / result handlers ----------

    private fun handleUpdate(obj: TdApi.Object) {
        when (obj) {
            is TdApi.UpdateAuthorizationState -> handleAuthState(obj.authorizationState)
            else -> Unit
        }
    }

    private fun handleAuthState(state: TdApi.AuthorizationState) {
        Log.d(TAG, "Auth state: ${state.javaClass.simpleName}")
        when (state) {
            is TdApi.AuthorizationStateWaitTdlibParameters -> sendTdlibParameters()
            is TdApi.AuthorizationStateWaitPhoneNumber     -> notifyState("authorizationStateWaitPhoneNumber")
            is TdApi.AuthorizationStateWaitCode            -> notifyState("authorizationStateWaitCode")
            is TdApi.AuthorizationStateWaitPassword        -> notifyState("authorizationStateWaitPassword")
            is TdApi.AuthorizationStateReady               -> notifyState("authorizationStateReady")
            is TdApi.AuthorizationStateLoggingOut          -> notifyState("authorizationStateLoggingOut")
            is TdApi.AuthorizationStateClosed              -> notifyState("authorizationStateClosed")
            else -> Log.d(TAG, "Unhandled auth state: ${state.javaClass.simpleName}")
        }
    }

    private fun handleResult(obj: TdApi.Object) {
        if (obj is TdApi.Error) {
            val msg = "${obj.message} (code: ${obj.code})"
            Log.e(TAG, "TDLib error: $msg")
            mainHandler.post { onError?.invoke(msg) }
        }
    }

    private fun notifyState(state: String) {
        mainHandler.post { onAuthState?.invoke(state) }
    }

    // ---------- TDLib parameters ----------

    private fun sendTdlibParameters() {
        val dbPath = context.filesDir.absolutePath + "/tdlib"

        // SetTdlibParameters is a flat class with public fields (TDLib 1.8.x+)
        val params = TdApi.SetTdlibParameters().apply {
            apiId                = this@TelegramManager.apiId
            apiHash              = this@TelegramManager.apiHash
            databaseDirectory    = dbPath
            filesDirectory       = "$dbPath/files"
            databaseEncryptionKey = ByteArray(0)
            useTestDc            = false
            useFileDatabase      = true
            useChatInfoDatabase  = true
            useMessageDatabase   = true
            useSecretChats       = false
            systemLanguageCode   = "en"
            deviceModel          = Build.MODEL
            systemVersion        = Build.VERSION.RELEASE
            applicationVersion   = "1.0"
        }

        client?.send(params, ::handleResult)
    }
}
