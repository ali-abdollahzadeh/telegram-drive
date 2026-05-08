import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/drive_folder.dart';

class FolderCard extends StatelessWidget {
  final DriveFolder folder;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const FolderCard({
    super.key,
    required this.folder,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.teledriveBlue
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.teledriveBlue : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    folder.isSavedMessages ? Icons.bookmark_rounded : Icons.folder_rounded,
                    color: isSelected ? Colors.white : AppColors.primary,
                    size: 22,
                  ),
                ),
                const Spacer(),
                if (!folder.isSavedMessages)
                  GestureDetector(
                    onTap: () => _showMenu(context),
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: isSelected ? Colors.white70 : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              folder.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? Colors.white : null,
                    fontWeight: FontWeight.w700,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              '${folder.fileCount} files',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white70 : null,
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
            leading: const Icon(Icons.open_in_new_rounded),
            title: const Text('Open Folder'),
            onTap: () {
              Navigator.pop(context);
              context.push('/folder/${folder.id}?name=${Uri.encodeComponent(folder.title)}');
            },
          ),
          if (onDelete != null)
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('Delete Folder', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                onDelete!();
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
