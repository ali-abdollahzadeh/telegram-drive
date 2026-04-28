import 'dart:math';
import '../../domain/entities/drive_file.dart';
import '../../domain/entities/drive_folder.dart';
import '../../domain/repositories/drive_repository.dart';

/// Mock implementation of DriveRepository.
/// Returns realistic demo data. Replace with TDLib in Phase 2.
class DriveRepositoryImpl implements DriveRepository {
  static final _random = Random();

  static const String savedMessagesId = 'saved_messages';

  // In-memory mock store
  final List<DriveFolder> _folders = _generateFolders();
  final List<DriveFile> _files = _generateFiles();

  static List<DriveFolder> _generateFolders() {
    final now = DateTime.now();
    return [
      DriveFolder(
        id: savedMessagesId,
        title: 'Saved Messages',
        telegramChannelId: 'me',
        createdAt: now.subtract(const Duration(days: 365)),
        fileCount: 24,
        isSavedMessages: true,
      ),
      DriveFolder(
        id: 'f1',
        title: 'Work Documents',
        telegramChannelId: '-100123456001',
        createdAt: now.subtract(const Duration(days: 60)),
        fileCount: 8,
      ),
      DriveFolder(
        id: 'f2',
        title: 'Photos Backup',
        telegramChannelId: '-100123456002',
        createdAt: now.subtract(const Duration(days: 30)),
        fileCount: 45,
      ),
      DriveFolder(
        id: 'f3',
        title: 'Project Assets',
        telegramChannelId: '-100123456003',
        createdAt: now.subtract(const Duration(days: 14)),
        fileCount: 12,
      ),
      DriveFolder(
        id: 'f4',
        title: 'Music Collection',
        telegramChannelId: '-100123456004',
        createdAt: now.subtract(const Duration(days: 7)),
        fileCount: 30,
      ),
    ];
  }

  static List<DriveFile> _generateFiles() {
    final now = DateTime.now();

    final rawFiles = [
      // Saved Messages
      ('img_vacation.jpg', DriveFileType.image, 3400000, savedMessagesId, 2),
      ('project_report.pdf', DriveFileType.pdf, 1200000, savedMessagesId, 5),
      ('meeting_notes.docx', DriveFileType.document, 450000, savedMessagesId, 8),
      ('demo_video.mp4', DriveFileType.video, 89000000, savedMessagesId, 10),
      ('song_preview.mp3', DriveFileType.audio, 5600000, savedMessagesId, 15),
      ('backup_2024.zip', DriveFileType.archive, 234000000, savedMessagesId, 20),
      ('photo_01.png', DriveFileType.image, 2100000, savedMessagesId, 22),
      ('invoice_march.pdf', DriveFileType.pdf, 890000, savedMessagesId, 25),

      // Work Documents folder
      ('contract_v2.pdf', DriveFileType.pdf, 678000, 'f1', 1),
      ('budget_2025.xlsx', DriveFileType.document, 340000, 'f1', 3),
      ('presentation.pptx', DriveFileType.document, 12000000, 'f1', 6),
      ('design_brief.pdf', DriveFileType.pdf, 980000, 'f1', 9),

      // Photos Backup
      ('selfie_paris.jpg', DriveFileType.image, 4500000, 'f2', 1),
      ('sunset_beach.jpg', DriveFileType.image, 6200000, 'f2', 2),
      ('portrait.png', DriveFileType.image, 3100000, 'f2', 4),
      ('wedding_clip.mp4', DriveFileType.video, 340000000, 'f2', 7),

      // Project Assets
      ('logo_final.png', DriveFileType.image, 890000, 'f3', 1),
      ('brand_kit.zip', DriveFileType.archive, 45000000, 'f3', 3),
      ('demo_reel.mp4', DriveFileType.video, 120000000, 'f3', 5),

      // Music
      ('track_01.mp3', DriveFileType.audio, 8900000, 'f4', 1),
      ('track_02.flac', DriveFileType.audio, 34000000, 'f4', 2),
      ('album_cover.jpg', DriveFileType.image, 1200000, 'f4', 3),
    ];

    return rawFiles.asMap().entries.map((entry) {
      final i = entry.key;
      final (name, type, size, folderId, daysAgo) = entry.value;
      return DriveFile(
        id: 'file_$i',
        telegramMessageId: '${100000 + i}',
        folderId: folderId,
        name: name,
        type: type,
        size: size,
        uploadedAt: now.subtract(Duration(days: daysAgo)),
      );
    }).toList();
  }

  @override
  Future<List<DriveFile>> getFiles({String? folderId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (folderId == null || folderId == savedMessagesId) {
      return _files.where((f) => f.folderId == savedMessagesId).toList();
    }
    return _files.where((f) => f.folderId == folderId).toList();
  }

  @override
  Future<List<DriveFolder>> getFolders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_folders);
  }

  @override
  Future<DriveFile> uploadFile({
    required String localPath,
    required String fileName,
    required String folderId,
    void Function(double progress)? onProgress,
  }) async {
    // Simulate upload progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress?.call(i / 10);
    }

    final fileType = _guessType(fileName);
    final file = DriveFile(
      id: 'file_${DateTime.now().millisecondsSinceEpoch}',
      telegramMessageId: '${200000 + _random.nextInt(10000)}',
      folderId: folderId,
      name: fileName,
      type: fileType,
      size: _random.nextInt(10000000) + 100000,
      uploadedAt: DateTime.now(),
    );

    _files.insert(0, file);

    // Update folder count
    final folderIdx = _folders.indexWhere((f) => f.id == folderId);
    if (folderIdx != -1) {
      _folders[folderIdx] = _folders[folderIdx].copyWith(
        fileCount: _folders[folderIdx].fileCount + 1,
      );
    }

    return file;
  }

  @override
  Future<String> downloadFile({
    required DriveFile file,
    void Function(double progress)? onProgress,
  }) async {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      onProgress?.call(i / 10);
    }
    return '/storage/emulated/0/Download/${file.name}';
  }

  @override
  Future<void> deleteFile(DriveFile file) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _files.removeWhere((f) => f.id == file.id);
  }

  @override
  Future<DriveFolder> createFolder(String name) async {
    await Future.delayed(const Duration(seconds: 1));
    final folder = DriveFolder(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}',
      title: name,
      telegramChannelId: '-100${_random.nextInt(900000000) + 100000000}',
      createdAt: DateTime.now(),
      fileCount: 0,
    );
    _folders.add(folder);
    return folder;
  }

  @override
  Future<void> deleteFolder(DriveFolder folder) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _folders.removeWhere((f) => f.id == folder.id);
    _files.removeWhere((f) => f.folderId == folder.id);
  }

  @override
  Future<List<DriveFile>> searchFiles(String query, {String? folderId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return _files.where((f) {
      final matchesName = f.name.toLowerCase().contains(q);
      final matchesFolder = folderId == null || f.folderId == folderId;
      return matchesName && matchesFolder;
    }).toList();
  }

  DriveFileType _guessType(String name) {
    final ext = name.split('.').last.toLowerCase();
    const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'];
    const videoExts = ['mp4', 'mov', 'avi', 'mkv'];
    const audioExts = ['mp3', 'wav', 'aac', 'flac', 'm4a', 'ogg'];
    const pdfExts = ['pdf'];
    const docExts = ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'];
    const archiveExts = ['zip', 'rar', '7z', 'tar', 'gz'];

    if (imageExts.contains(ext)) return DriveFileType.image;
    if (videoExts.contains(ext)) return DriveFileType.video;
    if (audioExts.contains(ext)) return DriveFileType.audio;
    if (pdfExts.contains(ext)) return DriveFileType.pdf;
    if (docExts.contains(ext)) return DriveFileType.document;
    if (archiveExts.contains(ext)) return DriveFileType.archive;
    return DriveFileType.other;
  }
}
