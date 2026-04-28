import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../drive/domain/entities/drive_file.dart';

class SearchResultItem extends StatelessWidget {
  final DriveFile file;
  const SearchResultItem({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fileTypeColor(FileUtils.getFileTypeLabel(file.type).toLowerCase());

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_getIcon(file.type), color: color, size: 22),
      ),
      title: Text(file.name, overflow: TextOverflow.ellipsis, maxLines: 1),
      subtitle: Text(
        '${SizeFormatter.format(file.size)} • ${DateFormatter.formatRelative(file.uploadedAt)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          FileUtils.getFileTypeLabel(file.type),
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      onTap: () => _openFile(context, file),
    );
  }

  void _openFile(BuildContext context, DriveFile file) {
    switch (file.type) {
      case DriveFileType.image:
        context.push('/preview/image/${file.id}');
      case DriveFileType.video:
        context.push('/preview/video/${file.id}');
      case DriveFileType.audio:
        context.push('/preview/audio/${file.id}');
      case DriveFileType.pdf:
        context.push('/preview/pdf/${file.id}');
      default:
        context.push('/file/${file.id}');
    }
  }

  IconData _getIcon(DriveFileType type) {
    switch (type) {
      case DriveFileType.image: return Icons.image_rounded;
      case DriveFileType.video: return Icons.movie_rounded;
      case DriveFileType.audio: return Icons.music_note_rounded;
      case DriveFileType.pdf: return Icons.picture_as_pdf_rounded;
      case DriveFileType.document: return Icons.description_rounded;
      case DriveFileType.archive: return Icons.archive_rounded;
      case DriveFileType.other: return Icons.insert_drive_file_rounded;
    }
  }
}
