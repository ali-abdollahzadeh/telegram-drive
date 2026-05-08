import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../domain/entities/drive_file.dart';
import '../providers/drive_provider.dart';

class FileDetailsScreen extends ConsumerStatefulWidget {
  final String fileId;
  const FileDetailsScreen({super.key, required this.fileId});

  @override
  ConsumerState<FileDetailsScreen> createState() => _FileDetailsScreenState();
}

class _FileDetailsScreenState extends ConsumerState<FileDetailsScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _downloadedPath;

  Future<void> _handleDownload(DriveFile file) async {
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final path = await ref.read(driveRepositoryProvider).downloadFile(
        file: file,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => _downloadProgress = progress.clamp(0, 1));
        },
      );

      if (!mounted) return;
      setState(() => _downloadedPath = path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download complete. You can open it now.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _openInApp(DriveFile file) {
    switch (file.type) {
      case DriveFileType.image:
        context.push(AppRoutes.previewImage.replaceFirst(':fileId', file.id));
      case DriveFileType.video:
        context.push(AppRoutes.previewVideo.replaceFirst(':fileId', file.id));
      case DriveFileType.audio:
        context.push(AppRoutes.previewAudio.replaceFirst(':fileId', file.id));
      case DriveFileType.pdf:
        context.push(AppRoutes.previewPdf.replaceFirst(':fileId', file.id));
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _downloadedPath == null
                  ? 'File downloaded. In-app preview is not available for this file type.'
                  : 'File downloaded to: $_downloadedPath',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(driveProvider);
    final file = driveState.files.where((f) => f.id == widget.fileId).firstOrNull;

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
            if (_isDownloading) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _downloadProgress > 0 ? _downloadProgress : null),
              const SizedBox(height: 8),
              Text(
                _downloadProgress > 0
                    ? 'Downloading ${(100 * _downloadProgress).toStringAsFixed(0)}%'
                    : 'Starting download...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : () => _handleDownload(file),
                    icon: Icon(_isDownloading ? Icons.downloading_rounded : Icons.download_rounded),
                    label: Text(_isDownloading ? 'Downloading...' : 'Download'),
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
            if (_downloadedPath != null || file.isDownloaded) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openInApp(file),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open in App'),
                ),
              ),
            ],
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
