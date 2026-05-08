import '../entities/drive_file.dart';
import '../entities/drive_folder.dart';

abstract class DriveRepository {
  /// Get files from Saved Messages or a specific folder
  Future<List<DriveFile>> getFiles({String? folderId});

  /// Get all drive folders (private channels)
  Future<List<DriveFolder>> getFolders();

  /// Upload a file to the specified folder or Saved Messages
  Future<DriveFile> uploadFile({
    required String localPath,
    required String fileName,
    required String folderId,
    void Function(double progress)? onProgress,
  });

  /// Download a file locally
  Future<String> downloadFile({
    required DriveFile file,
    void Function(double progress)? onProgress,
  });

  /// Delete a file (deletes the Telegram message)
  Future<void> deleteFile(DriveFile file);

  /// Delete multiple files
  Future<void> deleteFiles(List<DriveFile> files);

  /// Create a new folder (creates a private Telegram channel)
  Future<DriveFolder> createFolder(String name);

  /// Delete a folder (leaves/deletes the Telegram channel)
  Future<void> deleteFolder(DriveFolder folder);

  /// Search files by name
  Future<List<DriveFile>> searchFiles(String query, {String? folderId});
}
