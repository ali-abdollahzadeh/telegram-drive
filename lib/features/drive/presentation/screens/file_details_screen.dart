import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../domain/entities/drive_file.dart';
import '../providers/drive_provider.dart';

class FileDetailsScreen extends ConsumerWidget {
  final String fileId;
  const FileDetailsScreen({super.key, required this.fileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driveState = ref.watch(driveProvider);
    final file = driveState.files.where((f) => f.id == fileId).firstOrNull;

    if (file == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('File Details')),
        body: const Center(child: Text('File not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(file.name, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File icon / thumbnail
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.fileTypeColor(FileUtils.getFileTypeLabel(file.type).toLowerCase())
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  _fileIcon(file.type),
                  color: AppColors.fileTypeColor(FileUtils.getFileTypeLabel(file.type).toLowerCase()),
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                file.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                FileUtils.getFileTypeLabel(file.type),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 32),
            _InfoRow('Size', SizeFormatter.format(file.size)),
            _InfoRow('Uploaded', DateFormatter.formatFull(file.uploadedAt)),
            _InfoRow('Type', FileUtils.getFileTypeLabel(file.type)),
            _InfoRow('Message ID', file.telegramMessageId),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ref.read(driveProvider.notifier).deleteFile(file),
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _fileIcon(DriveFileType type) => switch (type) {
    DriveFileType.image => Icons.image_rounded,
    DriveFileType.video => Icons.movie_rounded,
    DriveFileType.audio => Icons.music_note_rounded,
    DriveFileType.pdf => Icons.picture_as_pdf_rounded,
    DriveFileType.document => Icons.description_rounded,
    DriveFileType.archive => Icons.archive_rounded,
    DriveFileType.other => Icons.insert_drive_file_rounded,
  };
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            )),
          ),
        ],
      ),
    );
  }
}
