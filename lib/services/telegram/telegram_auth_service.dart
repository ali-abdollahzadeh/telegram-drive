/// Abstract Telegram auth service interface.
/// Concrete implementation will use TDLib via platform channels.
abstract class TelegramAuthService {
  Future<void> sendCode({
    required String apiId,
    required String apiHash,
    required String phone,
  });

  Future<String> signInWithCode(String code);

  Future<String> signInWithPassword(String password);

  Future<void> logout();

  Future<bool> hasExistingSession();

  bool get requiresTwoFactorAuth;
}
