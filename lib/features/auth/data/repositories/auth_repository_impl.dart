import 'dart:async';

import '../../domain/repositories/auth_repository.dart';
import '../../../../services/platform/native_telegram_channel.dart';
import '../../../../services/storage/secure_storage_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Real Telegram authentication via TDLib through the native Kotlin bridge.
///
/// Telegram api_id and api_hash are stored on the Android native side.
/// Flutter only sends the user's phone number, login code, and 2FA password.
///
/// Auth flow driven by TDLib auth state stream:
///   authorizationStateWaitPhoneNumber → ready for phone
///   authorizationStateWaitCode        → code sent to Telegram app
///   authorizationStateWaitPassword    → 2FA password required
///   authorizationStateReady           → logged in
class AuthRepositoryImpl implements AuthRepository {
  final SecureStorageService _storage;

  StreamSubscription<Map<String, dynamic>>? _sub;

  AuthRepositoryImpl(this._storage);

  // ---------- AuthRepository interface ----------

  @override
  Future<bool> hasSession() async {
    final isLoggedIn = await _storage.read(StorageKeys.isLoggedIn);
    final phone = await _storage.read(StorageKeys.phone);

    return isLoggedIn == 'true' && phone != null && phone.isNotEmpty;
  }

  @override
  Future<void> sendCode({
    required String phone,
  }) async {
    final cleanPhone = phone.trim();

    if (cleanPhone.isEmpty) {
      throw ArgumentError('Phone number cannot be empty.');
    }

    // Store only the phone number locally if your UI needs it.
    // Do not store api_id or api_hash in Flutter anymore.
    await _storage.write(StorageKeys.phone, cleanPhone);

    // Start listening to TDLib auth state stream.
    _subscribeToAuthStream();

    // Initialize TDLib.
    // Native Android side reads api_id/api_hash from BuildConfig.
    await NativeTelegramChannel.initialize();

    // Wait for TDLib to be ready for the phone number.
    await _waitForState('authorizationStateWaitPhoneNumber', timeout: 10);

    // Send the phone number. Telegram will send the login code.
    await NativeTelegramChannel.sendPhoneNumber(cleanPhone);

    // Wait for confirmation that code is needed.
    await _waitForState('authorizationStateWaitCode', timeout: 15);
  }

  @override
  Future<bool> verifyCode(String code) async {
    final cleanCode = code.trim();

    if (cleanCode.isEmpty) {
      throw ArgumentError('Login code cannot be empty.');
    }

    await NativeTelegramChannel.checkCode(cleanCode);

    final state = await _waitForAnyOf([
      'authorizationStateReady',
      'authorizationStateWaitPassword',
    ], timeout: 15);

    if (state == 'authorizationStateReady') {
      await _onAuthenticated();
      return true;
    }

    // authorizationStateWaitPassword means 2FA is needed.
    return false;
  }

  @override
  Future<bool> verifyPassword(String password) async {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty.');
    }

    await NativeTelegramChannel.checkPassword(password);

    final state = await _waitForState(
      'authorizationStateReady',
      timeout: 15,
    );

    if (state == 'authorizationStateReady') {
      await _onAuthenticated();
      return true;
    }

    return false;
  }

  @override
  Future<void> logout() async {
    await _sub?.cancel();
    _sub = null;

    await NativeTelegramChannel.logout();

    // This deletes app-side stored values such as phone/isLoggedIn.
    // TDLib logout should clear Telegram session on the native side.
    await _storage.deleteAll();
  }

  @override
  Future<bool> restoreSession() async {
    _subscribeToAuthStream();

    // Initialize TDLib using native BuildConfig credentials.
    // If a valid TDLib session exists on disk, TDLib should move to Ready.
    await NativeTelegramChannel.initialize();

    try {
      final state = await _waitForAnyOf([
        'authorizationStateReady',
        'authorizationStateWaitPhoneNumber',
        'authorizationStateWaitCode',
        'authorizationStateWaitPassword',
      ], timeout: 10);

      final isReady = state == 'authorizationStateReady';

      if (isReady) {
        await _storage.write(StorageKeys.isLoggedIn, 'true');
      } else {
        await _storage.write(StorageKeys.isLoggedIn, 'false');
      }

      return isReady;
    } catch (_) {
      await _storage.write(StorageKeys.isLoggedIn, 'false');
      return false;
    }
  }

  // ---------- Private helpers ----------

  void _subscribeToAuthStream() {
    _sub?.cancel();

    _sub = NativeTelegramChannel.authStateStream.listen(
      (event) {
        // This subscription keeps the stream active.
        // State-specific waiting is handled by _waitForAnyOf().
      },
      onError: (_) {
        // Errors are handled by _waitForAnyOf() listeners.
      },
    );
  }

  Future<String> _waitForState(
    String expectedState, {
    required int timeout,
  }) async {
    return _waitForAnyOf([expectedState], timeout: timeout);
  }

  Future<String> _waitForAnyOf(
    List<String> states, {
    required int timeout,
  }) async {
    final completer = Completer<String>();
    late StreamSubscription<Map<String, dynamic>> sub;

    sub = NativeTelegramChannel.authStateStream.listen(
      (event) {
        if (event['type'] == 'authState') {
          final state = event['state'] as String? ?? '';

          if (states.contains(state) && !completer.isCompleted) {
            completer.complete(state);
            sub.cancel();
          }
        } else if (event['type'] == 'error' && !completer.isCompleted) {
          final message =
              event['message'] as String? ?? 'Unknown Telegram error';
          completer.completeError(Exception(message));
          sub.cancel();
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
          sub.cancel();
        }
      },
    );

    return completer.future.timeout(
      Duration(seconds: timeout),
      onTimeout: () {
        sub.cancel();
        throw TimeoutException(
          'Telegram auth timed out waiting for: $states',
        );
      },
    );
  }

  Future<void> _onAuthenticated() async {
    await _storage.write(StorageKeys.isLoggedIn, 'true');

    await _sub?.cancel();
    _sub = null;
  }
}
