import 'dart:async';
import 'package:flutter/services.dart';

/// Dart-side wrapper for the Kotlin TelegramPlugin.
///
/// Method channel: 'com.telegramdrive.app/telegram'
/// Event channel:  'com.telegramdrive.app/telegram_events'
class NativeTelegramChannel {
  NativeTelegramChannel._();

  static const _method = MethodChannel('com.telegramdrive.app/telegram');
  static const _events = EventChannel('com.telegramdrive.app/telegram_events');

  // Stream of auth state events from TDLib
  static Stream<Map<String, dynamic>> get authStateStream =>
      _events.receiveBroadcastStream().map((e) => Map<String, dynamic>.from(e as Map));

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

  static Exception _mapError(PlatformException e) =>
      Exception(e.message ?? 'Unknown Telegram error');
}
