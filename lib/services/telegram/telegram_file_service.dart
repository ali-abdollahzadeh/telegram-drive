/// Abstract Telegram file service interface.
abstract class TelegramFileService {
  /// Fetch all messages with files from Saved Messages
  Future<List<Map<String, dynamic>>> getSavedMessages();

  /// Fetch messages with files from a channel
  Future<List<Map<String, dynamic>>> getChannelMessages(String channelId);

  /// Upload a file to a chat
  Future<Map<String, dynamic>> uploadFile({
    required String chatId,
    required String filePath,
    required String fileName,
    void Function(int sent, int total)? onProgress,
  });

  /// Download a file
  Future<String> downloadFile({
    required String fileId,
    required String savePath,
    void Function(int received, int total)? onProgress,
  });

  /// Delete a message
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  });

  /// Get thumbnail for a file
  Future<String?> getThumbnail(String fileId);
}
