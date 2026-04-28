import 'dart:async';
import '../../domain/repositories/auth_repository.dart';
import '../../../../services/platform/native_telegram_channel.dart';
import '../../../../services/storage/secure_storage_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Real Telegram authentication via TDLib (native Kotlin bridge).
///
/// Auth flow driven by TDLib auth state stream:
///   authorizationStateWaitPhoneNumber → ready for phone
///   authorizationStateWaitCode        → code sent to Telegram app
///   authorizationStateWaitPassword    → 2FA password required
///   authorizationStateReady           → logged in ✅
class AuthRepositoryImpl implements AuthRepository {
  final SecureStorageService _storage;

  // Completer used to wait for specific TDLib state transitions
  Completer<String>? _pendingState;
  StreamSubscription<Map<String, dynamic>>? _sub;

  AuthRepositoryImpl(this._storage);

  // ---------- AuthRepository interface ----------

  @override
  Future<bool> hasSession() async {
    final apiId = await _storage.read(StorageKeys.apiId);
    final apiHash = await _storage.read(StorageKeys.apiHash);
    final phone = await _storage.read(StorageKeys.phone);
    return apiId != null && apiHash != null && phone != null;
  }

  @override
  Future<void> sendCode({
    required String apiId,
    required String apiHash,
    required String phone,
  }) async {
    // Save credentials locally (never leave the device)
    await _storage.write(StorageKeys.apiId, apiId);
    await _storage.write(StorageKeys.apiHash, apiHash);
    await _storage.write(StorageKeys.phone, phone);

    // Start listening to TDLib auth state stream
    _subscribeToAuthStream();

    // Initialize TDLib — this triggers authorizationStateWaitPhoneNumber
    await NativeTelegramChannel.initialize(apiId: apiId, apiHash: apiHash);

    // Wait for TDLib to be ready for the phone number
    await _waitForState('authorizationStateWaitPhoneNumber', timeout: 10);

    // Send the phone → Telegram sends code to user's app
    await NativeTelegramChannel.sendPhoneNumber(phone);

    // Wait for confirmation that code was sent
    await _waitForState('authorizationStateWaitCode', timeout: 15);
  }

  @override
  Future<bool> verifyCode(String code) async {
    await NativeTelegramChannel.checkCode(code);

    final state = await _waitForAnyOf([
      'authorizationStateReady',
      'authorizationStateWaitPassword',
    ], timeout: 15);

    if (state == 'authorizationStateReady') {
      await _onAuthenticated();
      return true;
    }
    // authorizationStateWaitPassword → 2FA needed
    return false;
  }

  @override
  Future<bool> verifyPassword(String password) async {
    await NativeTelegramChannel.checkPassword(password);

    final state = await _waitForState('authorizationStateReady', timeout: 15);
    if (state == 'authorizationStateReady') {
      await _onAuthenticated();
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    _sub?.cancel();
    await NativeTelegramChannel.logout();
    await _storage.deleteAll();
  }

  // ---------- Private helpers ----------

  void _subscribeToAuthStream() {
    _sub?.cancel();
    _sub = NativeTelegramChannel.authStateStream.listen(
      (event) {
        final type = event['type'] as String?;
        if (type == 'authState') {
          final state = event['state'] as String? ?? '';
          _pendingState?.complete(state);
        } else if (type == 'error') {
          final msg = event['message'] as String? ?? 'Unknown error';
          _pendingState?.completeError(Exception(msg));
        }
      },
      onError: (e) => _pendingState?.completeError(e),
    );
  }

  /// Wait for a specific TDLib auth state, with timeout.
  Future<String> _waitForState(String expectedState, {required int timeout}) async {
    return _waitForAnyOf([expectedState], timeout: timeout);
  }

  /// Wait for any of the given states.
  Future<String> _waitForAnyOf(List<String> states, {required int timeout}) async {
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
          completer.completeError(Exception(event['message']));
          sub.cancel();
        }
      },
    );

    return completer.future.timeout(
      Duration(seconds: timeout),
      onTimeout: () {
        sub.cancel();
        throw TimeoutException('Telegram auth timed out waiting for: $states');
      },
    );
  }

  Future<void> _onAuthenticated() async {
    await _storage.write(StorageKeys.isAuthenticated, 'true');
    _sub?.cancel();
  }
}
