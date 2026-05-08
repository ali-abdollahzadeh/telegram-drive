import 'package:flutter/material.dart';
import '../../domain/entities/drive_folder.dart';

/// Horizontal scrollable storage location selector tabs
class StorageSelector extends StatelessWidget {
  final List<DriveFolder> folders;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const StorageSelector({
    super.key,
    required this.folders,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: folders.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final folder = folders[i];
          final isSelected = folder.id == selectedId;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final scheme = Theme.of(context).colorScheme;

          return GestureDetector(
            onTap: () => onSelected(folder.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? scheme.primary 
                    : (isDark ? const Color(0xFF1C1C1E) : Colors.white),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    folder.isSavedMessages ? Icons.bookmark_rounded : Icons.folder_rounded,
                    size: 14,
                    color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    folder.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
