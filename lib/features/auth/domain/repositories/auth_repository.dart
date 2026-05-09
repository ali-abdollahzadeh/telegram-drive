abstract class AuthRepository {
  /// Returns true if a Telegram session already exists on this device.
  Future<bool> hasSession();

  /// Initialize TDLib and send the verification code to the user's Telegram app.
  ///
  /// Telegram api_id and api_hash are stored on the Android native side.
  /// Flutter only sends the user's phone number.
  Future<void> sendCode({
    required String phone,
  });

  /// Verify the code.
  /// Returns true if authenticated, false if 2FA is required.
  Future<bool> verifyCode(String code);

  /// Verify the 2FA password.
  /// Returns true if authenticated.
  Future<bool> verifyPassword(String password);

  /// Log out and clear session.
  Future<void> logout();

  /// Restore an existing TDLib session.
  /// Returns true if TDLib reaches authorizationStateReady.
  Future<bool> restoreSession();
}
