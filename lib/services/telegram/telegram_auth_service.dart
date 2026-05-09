/// Abstract Telegram auth service interface.
///
/// Concrete implementation will use TDLib via platform channels.
/// The user only provides phone number, login code, and 2FA password if needed.
abstract class TelegramAuthService {
  Future<void> sendCode({
    required String phone,
  });

  Future<String> signInWithCode(String code);

  Future<String> signInWithPassword(String password);

  Future<void> logout();

  Future<bool> hasExistingSession();

  bool get requiresTwoFactorAuth;
}
