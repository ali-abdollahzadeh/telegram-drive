/// Abstract folder service — manages private Telegram channels as folders.
abstract class TelegramFolderService {
  /// Get all private channels used as folders
  Future<List<Map<String, dynamic>>> getFolders();

  /// Create a new private channel (used as folder)
  Future<Map<String, dynamic>> createFolder(String name);

  /// Delete/leave a channel
  Future<void> deleteFolder(String channelId);

  /// Rename a channel
  Future<void> renameFolder(String channelId, String newName);
}
