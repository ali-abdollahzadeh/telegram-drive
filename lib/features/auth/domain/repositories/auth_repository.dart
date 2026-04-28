abstract class AuthRepository {
  /// Returns true if credentials are already saved on device.
  Future<bool> hasSession();

  /// Initialize TDLib and send the verification code to the user's Telegram app.
  Future<void> sendCode({
    required String apiId,
    required String apiHash,
    required String phone,
  });

  /// Verify the code. Returns true if authenticated, false if 2FA is required.
  Future<bool> verifyCode(String code);

  /// Verify the 2FA password. Returns true if authenticated.
  Future<bool> verifyPassword(String password);

  /// Log out and clear session.
  Future<void> logout();
}
