import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/drive_file.dart';

class FileListItem extends StatelessWidget {
  final DriveFile file;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;

  const FileListItem({
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

    return Padding(
      padding: AppSpacing.hMdVXxs,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppRadius.mdBR,
        child: Container(
          padding: AppSpacing.hMdVSm,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : (isDark ? AppColors.cardDark : Colors.white),
            borderRadius: AppRadius.mdBR,
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.textHintDark,
                  ),
                ),
              // Icon
              IconBadge(
                icon: _getIcon(file.type),
                color: color,
                size: AppDimensions.listIconSize,
                iconSize: AppDimensions.iconLG,
                borderRadius: AppRadius.md,
              ),
              const SizedBox(width: AppSpacing.md),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${SizeFormatter.format(file.size)} • ${DateFormatter.formatRelative(file.uploadedAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (file.isUploading) ...[
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: file.uploadProgress,
                        color: AppColors.primary,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              if (!isSelectionMode)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (v) {
                    if (v == 'download') onDownload?.call();
                    if (v == 'share') onShare?.call();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'download', child: Text(AppText.download)),
                    PopupMenuItem(value: 'share', child: Text(AppText.share)),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(AppText.delete,
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
            ],
          ),
        ),
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
