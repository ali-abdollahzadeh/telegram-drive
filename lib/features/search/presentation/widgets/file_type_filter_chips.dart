import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../drive/domain/entities/drive_file.dart';

class FileTypeFilterChips extends StatelessWidget {
  final DriveFileType? selected;
  final ValueChanged<DriveFileType?> onSelected;

  const FileTypeFilterChips({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final types = [null, ...DriveFileType.values];
    final labels = {
      null: 'All',
      DriveFileType.image: '🖼 Images',
      DriveFileType.video: '🎬 Videos',
      DriveFileType.audio: '🎵 Audio',
      DriveFileType.pdf: '📄 PDF',
      DriveFileType.document: '📝 Docs',
      DriveFileType.archive: '🗜 Archives',
      DriveFileType.other: '📎 Other',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: types.map((type) {
          final isSelected = selected == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(labels[type] ?? 'All'),
              selected: isSelected,
              onSelected: (_) => onSelected(type),
              selectedColor: AppColors.primary.withValues(alpha: 0.18),
              checkmarkColor: AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }
}
