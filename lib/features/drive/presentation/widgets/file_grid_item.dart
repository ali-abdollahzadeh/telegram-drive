import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../domain/entities/drive_file.dart';

class FileGridItem extends StatelessWidget {
  final DriveFile file;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;

  const FileGridItem({
    super.key,
    required this.file,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    this.onDownload,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fileTypeColor(
        FileUtils.getFileTypeLabel(file.type).toLowerCase());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF1C1C1E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(_getIcon(file.type), color: color, size: 44),
                    if (file.isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: file.uploadProgress,
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    // Type badge
                    if (!isSelectionMode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            FileUtils.getFileTypeLabel(file.type).toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    if (isSelectionMode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Info area
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        SizeFormatter.format(file.size),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const Spacer(),
                      if (!isSelectionMode)
                        GestureDetector(
                          onTap: () => _showMenu(context),
                          child: const Icon(Icons.more_vert_rounded, size: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('Download'),
            onTap: () {
              Navigator.pop(context);
              onDownload?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              onShare?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            title:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  IconData _getIcon(DriveFileType type) {
    switch (type) {
      case DriveFileType.image:
        return Icons.image_rounded;
      case DriveFileType.video:
        return Icons.movie_rounded;
      case DriveFileType.audio:
        return Icons.music_note_rounded;
      case DriveFileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case DriveFileType.document:
        return Icons.description_rounded;
      case DriveFileType.archive:
        return Icons.archive_rounded;
      case DriveFileType.other:
        return Icons.insert_drive_file_rounded;
    }
  }
}
