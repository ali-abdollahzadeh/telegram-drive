enum DriveFileType { image, video, audio, pdf, document, archive, other }

class DriveFile {
  final String id;
  final String telegramMessageId;
  final String folderId;
  final String name;
  final DriveFileType type;
  final int size;
  final DateTime uploadedAt;
  final String? localPath;
  final String? thumbnailUrl;
  final bool isDownloaded;
  final bool isUploading;
  final double uploadProgress;

  const DriveFile({
    required this.id,
    required this.telegramMessageId,
    required this.folderId,
    required this.name,
    required this.type,
    required this.size,
    required this.uploadedAt,
    this.localPath,
    this.thumbnailUrl,
    this.isDownloaded = false,
    this.isUploading = false,
    this.uploadProgress = 0,
  });

  DriveFile copyWith({
    String? id,
    String? telegramMessageId,
    String? folderId,
    String? name,
    DriveFileType? type,
    int? size,
    DateTime? uploadedAt,
    String? localPath,
    String? thumbnailUrl,
    bool? isDownloaded,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return DriveFile(
      id: id ?? this.id,
      telegramMessageId: telegramMessageId ?? this.telegramMessageId,
      folderId: folderId ?? this.folderId,
      name: name ?? this.name,
      type: type ?? this.type,
      size: size ?? this.size,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      localPath: localPath ?? this.localPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}
