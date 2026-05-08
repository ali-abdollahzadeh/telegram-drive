import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/drive_file.dart';
import '../providers/drive_provider.dart';

class FileDetailsScreen extends ConsumerStatefulWidget {
  final String fileId;

  const FileDetailsScreen({
    super.key,
    required this.fileId,
  });

  @override
  ConsumerState<FileDetailsScreen> createState() => _FileDetailsScreenState();
}

class _FileDetailsScreenState extends ConsumerState<FileDetailsScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _downloadedPath;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driveState = ref.read(driveProvider);

      final file = driveState.files
          .where((file) => file.id == widget.fileId)
          .firstOrNull;

      if (file != null && file.localPath != null && file.isDownloaded) {
        setState(() => _downloadedPath = file.localPath);
      }
    });
  }

  Future<void> _handleDownload(DriveFile file) async {
    if (_isDownloading) return;

    final existingPath = _downloadedPath ?? file.localPath;

    if (existingPath != null && existingPath.isNotEmpty) {
      await _openFile(file, existingPath);
      return;
    }

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

      ref.read(driveProvider.notifier).updateFileLocalPath(file.id, path);

      await _openFile(file, path);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppText.downloadFailed}$e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _openFile(DriveFile file, String path) async {
    if (path.isEmpty) {
      _showMessage(AppText.noPreviewAvailable);
      return;
    }

    final exists = await File(path).exists();

    if (!exists) {
      _showMessage('File not found on device.');
      return;
    }

    switch (file.type) {
      case DriveFileType.image:
        context.push(AppRoutes.previewImage.replaceFirst(':fileId', file.id));
        return;

      case DriveFileType.video:
        context.push(AppRoutes.previewVideo.replaceFirst(':fileId', file.id));
        return;

      case DriveFileType.audio:
        context.push(AppRoutes.previewAudio.replaceFirst(':fileId', file.id));
        return;

      case DriveFileType.pdf:
        context.push(AppRoutes.previewPdf.replaceFirst(':fileId', file.id));
        return;

      case DriveFileType.document:
      case DriveFileType.archive:
      case DriveFileType.other:
        final result = await OpenFilex.open(path);

        if (!mounted) return;

        if (result.type != ResultType.done) {
          _showMessage(
            result.message.isNotEmpty
                ? result.message
                : 'No app found to open this file.',
          );
        }

        return;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(driveProvider);

    final file =
        driveState.files.where((file) => file.id == widget.fileId).firstOrNull;

    if (file == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppText.fileDetails)),
        body: const Center(child: Text(AppText.fileNotFound)),
      );
    }

    final alreadyDownloaded = _downloadedPath != null ||
        (file.localPath != null && file.isDownloaded);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          file.name,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.fileTypeColor(
                    FileUtils.getFileTypeLabel(file.type).toLowerCase(),
                  ).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  _fileIcon(file.type),
                  color: AppColors.fileTypeColor(
                    FileUtils.getFileTypeLabel(file.type).toLowerCase(),
                  ),
                  size: 56,
                ),
              ),
            ),
            AppSpacing.gapXXL,
            Center(
              child: Text(
                file.name,
                style: AppTextStyles.titleLarge(context),
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.gapXS,
            Center(
              child: Text(
                FileUtils.getFileTypeLabel(file.type),
                style: AppTextStyles.bodyMedium(context),
              ),
            ),
            AppSpacing.gapXXL,
            InfoRow(
              label: AppText.infoLabelSize,
              value: SizeFormatter.format(file.size),
            ),
            InfoRow(
              label: AppText.infoLabelUploaded,
              value: DateFormatter.formatFull(file.uploadedAt),
            ),
            InfoRow(
              label: AppText.infoLabelType,
              value: FileUtils.getFileTypeLabel(file.type),
            ),
            InfoRow(
              label: AppText.infoLabelMessageId,
              value: file.telegramMessageId,
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
              ),
              const SizedBox(height: 8),
              Text(
                _downloadProgress > 0
                    ? '${AppText.downloadingPercent} ${(100 * _downloadProgress).toStringAsFixed(0)}%'
                    : AppText.startingDownload,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            AppSpacing.gapXXL,
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isDownloading ? null : () => _handleDownload(file),
                    icon: Icon(
                      alreadyDownloaded
                          ? Icons.open_in_new_rounded
                          : _isDownloading
                              ? Icons.downloading_rounded
                              : Icons.download_rounded,
                    ),
                    label: Text(
                      alreadyDownloaded
                          ? AppText.open
                          : _isDownloading
                              ? AppText.downloading
                              : AppText.download,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(driveProvider.notifier).deleteFile(file);
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                    label: const Text(
                      AppText.delete,
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
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
