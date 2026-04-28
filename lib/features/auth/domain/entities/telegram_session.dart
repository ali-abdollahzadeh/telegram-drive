/// Domain entity: Telegram session
class TelegramSession {
  final String apiId;
  final String apiHash;
  final String phoneNumber;
  final String sessionString;
  final bool isActive;

  const TelegramSession({
    required this.apiId,
    required this.apiHash,
    required this.phoneNumber,
    required this.sessionString,
    this.isActive = true,
  });

  TelegramSession copyWith({
    String? apiId,
    String? apiHash,
    String? phoneNumber,
    String? sessionString,
    bool? isActive,
  }) {
    return TelegramSession(
      apiId: apiId ?? this.apiId,
      apiHash: apiHash ?? this.apiHash,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      sessionString: sessionString ?? this.sessionString,
      isActive: isActive ?? this.isActive,
    );
  }
}
