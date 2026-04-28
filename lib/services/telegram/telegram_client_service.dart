/// Abstract Telegram client service.
/// Implement this with TDLib in Phase 2.
abstract class TelegramClientService {
  Future<void> initialize({
    required String apiId,
    required String apiHash,
  });

  Future<void> close();

  bool get isConnected;

  Stream<TelegramUpdate> get updates;
}

/// Represents a generic Telegram update event
class TelegramUpdate {
  final String type;
  final Map<String, dynamic> data;

  const TelegramUpdate({required this.type, required this.data});
}
