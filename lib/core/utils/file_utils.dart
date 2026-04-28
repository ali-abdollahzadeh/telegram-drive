import 'package:mime/mime.dart';
import '../../features/drive/domain/entities/drive_file.dart';

class FileUtils {
  FileUtils._();

  static DriveFileType getFileType(String filename) {
    final ext = filename.split('.').last.toLowerCase();

    const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic', 'heif', 'tiff', 'svg'];
    const videoExts = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'flv', 'wmv', 'm4v', '3gp'];
    const audioExts = ['mp3', 'wav', 'aac', 'flac', 'm4a', 'ogg', 'opus', 'wma'];
    const pdfExts = ['pdf'];
    const docExts = ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'odt', 'ods', 'odp', 'rtf', 'csv', 'md'];
    const archiveExts = ['zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'iso'];

    if (imageExts.contains(ext)) return DriveFileType.image;
    if (videoExts.contains(ext)) return DriveFileType.video;
    if (audioExts.contains(ext)) return DriveFileType.audio;
    if (pdfExts.contains(ext)) return DriveFileType.pdf;
    if (docExts.contains(ext)) return DriveFileType.document;
    if (archiveExts.contains(ext)) return DriveFileType.archive;
    return DriveFileType.other;
  }

  static String getFileTypeLabel(DriveFileType type) => switch (type) {
    DriveFileType.image => 'Image',
    DriveFileType.video => 'Video',
    DriveFileType.audio => 'Audio',
    DriveFileType.pdf => 'PDF',
    DriveFileType.document => 'Document',
    DriveFileType.archive => 'Archive',
    DriveFileType.other => 'File',
  };

  static String getMimeType(String filename) {
    return lookupMimeType(filename) ?? 'application/octet-stream';
  }

  static String getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  static String getFileIcon(DriveFileType type) => switch (type) {
    DriveFileType.image => '🖼',
    DriveFileType.video => '🎬',
    DriveFileType.audio => '🎵',
    DriveFileType.pdf => '📄',
    DriveFileType.document => '📝',
    DriveFileType.archive => '🗜',
    DriveFileType.other => '📎',
  };

  static bool isPreviewable(DriveFileType type) {
    return type == DriveFileType.image ||
        type == DriveFileType.video ||
        type == DriveFileType.audio ||
        type == DriveFileType.pdf;
  }
}

class SizeFormatter {
  SizeFormatter._();

  static String format(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String formatMb(int mb) => format(mb * 1024 * 1024);
}

class DateFormatter {
  DateFormatter._();

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  static String formatFull(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
