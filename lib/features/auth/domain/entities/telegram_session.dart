/// Domain entity: Telegram session.
///
/// This model represents the app-side session status only.
/// The real Telegram authorization session is managed by TDLib on Android.
class TelegramSession {
  final String phoneNumber;
  final bool isActive;

  const TelegramSession({
    required this.phoneNumber,
    this.isActive = true,
  });

  TelegramSession copyWith({
    String? phoneNumber,
    bool? isActive,
  }) {
    return TelegramSession(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
    );
  }
}
