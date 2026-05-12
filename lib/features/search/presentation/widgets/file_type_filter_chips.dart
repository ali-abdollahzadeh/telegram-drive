import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_text.dart';
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
                showCheckmark: false,
                avatar: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.primary,
                        )
                      : SvgPicture.asset(
                          icons[type] ?? 'assets/icons/d.svg',
                          width: 14,
                          height: 14,
                        ),
                ),
                label: Text(
                  labels[type] ?? AppText.filterOther,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onSelected(type),
                backgroundColor: Colors.white,
                selectedColor: AppColors.primary,
              ));
        }).toList(),
      ),
    );
  }
}
