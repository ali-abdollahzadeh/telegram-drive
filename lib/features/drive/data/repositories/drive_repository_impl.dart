import 'dart:async';
import '../../domain/entities/drive_file.dart';
import '../../domain/entities/drive_folder.dart';
import '../../domain/repositories/drive_repository.dart';
import '../../../../services/platform/native_telegram_channel.dart';

/// Real implementation of DriveRepository using TDLib via NativeTelegramChannel.
class DriveRepositoryImpl implements DriveRepository {
  static const String savedMessagesId = 'saved_messages';

  /// Cached user ID for Saved Messages chat
  int? _myUserId;

  Future<int> _getMyUserId() async {
    if (_myUserId != null) return _myUserId!;
    final me = await NativeTelegramChannel.getMe();
    _myUserId = me['id'] as int;
    return _myUserId!;
  }

  @override
  Future<List<DriveFolder>> getFolders() async {
    final me = await NativeTelegramChannel.getMe();
    final myId = me['id'] as int;
    _myUserId = myId;

    // Fetch all chats from TDLib
    final chats = await NativeTelegramChannel.getMyChats(limit: 50);

    final folders = <DriveFolder>[];

    // Always add Saved Messages first
    folders.add(DriveFolder(
      id: savedMessagesId,
      title: 'Saved Messages',
      telegramChannelId: myId.toString(),
      createdAt: DateTime.now(),
      fileCount: 0,
      isSavedMessages: true,
    ));

    // Add channels the user owns/is in
    for (final chat in chats) {
      final chatId = chat['id'] as int;
      final title = chat['title'] as String;
      final type = chat['type'] as String;

      // Skip the user's own private chat (that's Saved Messages above)
      if (chatId == myId) continue;

      // Include channels and supergroups (these act like folders)
      if (type == 'channel' || type == 'supergroup') {
        folders.add(DriveFolder(
          id: chatId.toString(),
          title: title,
          telegramChannelId: chatId.toString(),
          createdAt: DateTime.now(),
          fileCount: 0,
        ));
      }
    }

    return folders;
  }

  @override
  Future<List<DriveFile>> getFiles({String? folderId}) async {
    int chatId;

    // Determine the chat ID to fetch from
    if (folderId == null || folderId == savedMessagesId) {
      chatId = await _getMyUserId();
    } else {
      chatId = int.tryParse(folderId) ?? 0;
    }

    if (chatId == 0) return [];

    final rawFiles = await NativeTelegramChannel.getDriveFiles(chatId: chatId, limit: 200);

    return rawFiles.map((map) {
      DriveFileType type = DriveFileType.other;
      switch (map['type']) {
        case 'document': type = DriveFileType.document; break;
        case 'image': type = DriveFileType.image; break;
        case 'video': type = DriveFileType.video; break;
        case 'audio': type = DriveFileType.audio; break;
        case 'pdf': type = DriveFileType.pdf; break;
        case 'archive': type = DriveFileType.archive; break;
      }

      final date = DateTime.fromMillisecondsSinceEpoch((map['date'] as int) * 1000);
      final localPath = map['localPath'] as String;

      return DriveFile(
        id: map['fileId'].toString(),
        telegramMessageId: map['messageId'].toString(),
        folderId: folderId ?? savedMessagesId,
        name: map['fileName'] ?? 'Unknown File',
        type: type,
        size: map['size'] ?? 0,
        uploadedAt: date,
        localPath: localPath.isNotEmpty ? localPath : null,
        isDownloaded: map['isDownloadingCompleted'] == true,
      );
    }).toList();
  }

  @override
  Future<String> downloadFile({
    required DriveFile file,
    void Function(double progress)? onProgress,
  }) async {
    final fileId = int.parse(file.id);

    final completer = Completer<String>();

    final sub = NativeTelegramChannel.fileUpdateStream.listen((event) {
      if (event['fileId'] == fileId) {
        final isCompleted = event['isDownloadingCompleted'] == true;
        final size = event['size'] as int;
        final downloaded = event['downloadedPrefixSize'] as int;
        final localPath = event['localPath'] as String;

        if (size > 0 && onProgress != null) {
          onProgress(downloaded / size);
        }

        if (isCompleted && localPath.isNotEmpty && !completer.isCompleted) {
          completer.complete(localPath);
        }
      }
    });

    try {
      final initialRes = await NativeTelegramChannel.downloadFile(fileId: fileId, priority: 32);
      final initialPath = initialRes['localPath'] as String? ?? '';
      if (initialRes['isDownloadingCompleted'] == true && initialPath.isNotEmpty) {
        if (!completer.isCompleted) completer.complete(initialPath);
      }

      // Wait for completion with timeout
      final result = await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw Exception('Download timed out'),
      );
      return result;
    } finally {
      sub.cancel();
    }
  }

  @override
  Future<List<DriveFile>> searchFiles(String query, {String? folderId}) async {
    final files = await getFiles(folderId: folderId);
    final q = query.toLowerCase();
    return files.where((f) => f.name.toLowerCase().contains(q)).toList();
  }

  @override
  Future<DriveFile> uploadFile({
    required String localPath,
    required String fileName,
    required String folderId,
    void Function(double progress)? onProgress,
  }) async {
    int chatId;
    if (folderId == savedMessagesId) {
      chatId = await _getMyUserId();
    } else {
      chatId = int.tryParse(folderId) ?? 0;
    }

    if (chatId == 0) throw Exception('Invalid folder ID');

    final result = await NativeTelegramChannel.uploadFile(chatId: chatId, filePath: localPath);

    return DriveFile(
      id: result['fileId']?.toString() ?? '0',
      telegramMessageId: result['messageId']?.toString() ?? '0',
      folderId: folderId,
      name: fileName,
      type: DriveFileType.document,
      size: result['size'] as int? ?? 0,
      uploadedAt: DateTime.now(),
      isDownloaded: false,
    );
  }

  @override
  Future<void> deleteFile(DriveFile file) async {
    throw UnimplementedError('Delete is pending native implementation.');
  }

  @override
  Future<DriveFolder> createFolder(String name) async {
    final result = await NativeTelegramChannel.createFolder(title: name);
    final chatId = result['id'] as int;
    final title = result['title'] as String;

    return DriveFolder(
      id: chatId.toString(),
      title: title,
      telegramChannelId: chatId.toString(),
      createdAt: DateTime.now(),
      fileCount: 0,
    );
  }

  @override
  Future<void> deleteFolder(DriveFolder folder) async {
    throw UnimplementedError('Folder deletion is pending native implementation.');
  }
}
