/// Abstract Telegram client service.
///
/// The Android native side owns the Telegram api_id and api_hash.
/// Flutter should not pass Telegram API credentials.
abstract class TelegramClientService {
  Future<void> initialize();

  Future<void> close();

  bool get isConnected;

  Stream<TelegramUpdate> get updates;
}

/// Represents a generic Telegram update event.
class TelegramUpdate {
  final String type;
  final Map<String, dynamic> data;

  const TelegramUpdate({
    required this.type,
    required this.data,
  });
}
