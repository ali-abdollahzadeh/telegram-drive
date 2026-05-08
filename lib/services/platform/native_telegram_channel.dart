import 'dart:async';
import 'package:flutter/services.dart';

/// Dart-side wrapper for the Kotlin TelegramPlugin.
///
/// Method channel: 'com.teledrive.app/telegram'
/// Event channel:  'com.teledrive.app/telegram_events'
class NativeTelegramChannel {
  NativeTelegramChannel._();

  static const _method = MethodChannel('com.teledrive.app/telegram');
  static const _events = EventChannel('com.teledrive.app/telegram_events');

  // Singleton broadcast stream — avoids multiple native listeners
  static Stream<Map<String, dynamic>>? _broadcastStream;
  static Stream<Map<String, dynamic>> get _stream {
    _broadcastStream ??= _events
        .receiveBroadcastStream()
        .map((e) => Map<String, dynamic>.from(e as Map))
        .asBroadcastStream();
    return _broadcastStream!;
  }

  // Stream of auth state events from TDLib
  static Stream<Map<String, dynamic>> get authStateStream => _stream.where(
      (event) => event['type'] == 'authState' || event['type'] == 'error');

  // Stream of file download updates from TDLib
  static Stream<Map<String, dynamic>> get fileUpdateStream => _stream
      .where((event) => event['type'] == 'fileUpdate')
      .map((event) => Map<String, dynamic>.from(event['file'] as Map));

  /// Initialize TDLib with API credentials.
  /// TDLib will immediately push auth states via [authStateStream].
  static Future<void> initialize({
    required String apiId,
    required String apiHash,
  }) async {
    try {
      await _method.invokeMethod('initialize', {
        'apiId': apiId,
        'apiHash': apiHash,
      });
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Ask Telegram to send the verification code to the user's Telegram app.
  static Future<void> sendPhoneNumber(String phone) async {
    try {
      await _method.invokeMethod('sendPhoneNumber', {'phone': phone});
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Submit the verification code the user received.
  static Future<void> checkCode(String code) async {
    try {
      await _method.invokeMethod('checkCode', {'code': code});
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Submit the two-step verification password.
  static Future<void> checkPassword(String password) async {
    try {
      await _method.invokeMethod('checkPassword', {'password': password});
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Log out from Telegram.
  static Future<void> logout() async {
    try {
      await _method.invokeMethod('logout');
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Get the current user profile (including phone number).
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final result = await _method.invokeMapMethod<String, dynamic>('getMe');
      return result ?? {};
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Get list of all chats (Saved Messages, channels, groups, etc.)
  static Future<List<Map<String, dynamic>>> getMyChats({int limit = 50}) async {
    try {
      final result =
          await _method.invokeListMethod<Map<dynamic, dynamic>>('getMyChats', {
        'limit': limit,
      });
      return result?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Get files from a specific chat (e.g. Saved Messages).
  static Future<List<Map<String, dynamic>>> getDriveFiles(
      {required int chatId, int limit = 100}) async {
    try {
      final result = await _method
          .invokeListMethod<Map<dynamic, dynamic>>('getDriveFiles', {
        'chatId': chatId,
        'limit': limit,
      });
      return result?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Start downloading a file from Telegram.
  static Future<Map<String, dynamic>> downloadFile(
      {required int fileId, int priority = 1, bool synchronous = false}) async {
    try {
      final result =
          await _method.invokeMapMethod<String, dynamic>('downloadFile', {
        'fileId': fileId,
        'priority': priority,
        'synchronous': synchronous,
      });
      return result ?? {};
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Upload a file to a Telegram chat.
  static Future<Map<String, dynamic>> uploadFile(
      {required int chatId, required String filePath}) async {
    try {
      final result =
          await _method.invokeMapMethod<String, dynamic>('uploadFile', {
        'chatId': chatId,
        'filePath': filePath,
      });
      return result ?? {};
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Create a private channel (acts as a folder in Telegram Drive).
  static Future<Map<String, dynamic>> createFolder(
      {required String title}) async {
    try {
      final result =
          await _method.invokeMapMethod<String, dynamic>('createFolder', {
        'title': title,
      });
      return result ?? {};
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Optimize (clear) the TDLib file cache.
  static Future<void> optimizeStorage() async {
    try {
      await _method.invokeMethod('optimizeStorage');
    } on PlatformException catch (e) {
      throw _mapError(e);
    }
  }

  /// Delete multiple messages from a chat.
  static Future<void> deleteMessages(
      {required int chatId, required List<int> messageIds, bool revoke = true}) async {
    try {
      await _method.invokeMethod('deleteMessages', {
        'chatId': chatId.toString(),
        'messageIds': messageIds.map((id) => id.toString()).toList(),
        'revoke': revoke,
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => null, // silently succeed on timeout
      );
    } on PlatformException catch (e) {
      throw _mapError(e);
    } on TimeoutException {
      // Ignore timeout — TDLib may still process it in the background
    }
  }

  static Exception _mapError(PlatformException e) =>
      Exception(e.message ?? 'Unknown Telegram error');
}
