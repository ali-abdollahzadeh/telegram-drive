class DriveFolder {
  final String id;
  final String title;
  final String telegramChannelId;
  final DateTime createdAt;
  final int fileCount;
  final String? thumbnailUrl;
  final bool isSavedMessages;

  const DriveFolder({
    required this.id,
    required this.title,
    required this.telegramChannelId,
    required this.createdAt,
    required this.fileCount,
    this.thumbnailUrl,
    this.isSavedMessages = false,
  });

  DriveFolder copyWith({
    String? id,
    String? title,
    String? telegramChannelId,
    DateTime? createdAt,
    int? fileCount,
    String? thumbnailUrl,
    bool? isSavedMessages,
  }) {
    return DriveFolder(
      id: id ?? this.id,
      title: title ?? this.title,
      telegramChannelId: telegramChannelId ?? this.telegramChannelId,
      createdAt: createdAt ?? this.createdAt,
      fileCount: fileCount ?? this.fileCount,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isSavedMessages: isSavedMessages ?? this.isSavedMessages,
    );
  }
}
