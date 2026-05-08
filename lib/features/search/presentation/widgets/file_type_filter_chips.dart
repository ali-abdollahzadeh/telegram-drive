import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../drive/domain/entities/drive_file.dart';

class FileTypeFilterChips extends StatelessWidget {
  final DriveFileType? selected;
  final ValueChanged<DriveFileType?> onSelected;

  const FileTypeFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final types = [null, ...DriveFileType.values];

    final labels = {
      null: 'All',
      DriveFileType.image: 'Images',
      DriveFileType.video: 'Videos',
      DriveFileType.audio: 'Audio',
      DriveFileType.pdf: 'PDF',
      DriveFileType.document: 'Docs',
      DriveFileType.archive: 'Archives',
      DriveFileType.other: 'Other',
    };

    final icons = {
      DriveFileType.image: 'assets/icons/gallery_filled.svg',
      DriveFileType.video: 'assets/icons/video_filled.svg',
      DriveFileType.audio: 'assets/icons/music.svg',
      DriveFileType.pdf: 'assets/icons/file_filled.svg',
      DriveFileType.document: 'assets/icons/edit.svg',
      DriveFileType.archive: 'assets/icons/badgefolder.svg',
      DriveFileType.other: 'assets/icons/ic_voicesharing.svg',
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
              avatar: SvgPicture.asset(
                icons[type] ?? 'assets/icons/badgefolder.svg',
                width: 18,
                height: 18,
              ),
              label: Text(labels[type] ?? 'Other'),
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
