import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../drive/domain/entities/drive_file.dart';
import '../../../drive/presentation/providers/drive_provider.dart';

class ImagePreviewScreen extends ConsumerStatefulWidget {
  final String fileId;
  const ImagePreviewScreen({super.key, required this.fileId});

  @override
  ConsumerState<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends ConsumerState<ImagePreviewScreen> {
  bool _isDownloading = false;
  String? _downloadedPath;

  Future<void> _download(DriveFile file) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final path = await ref.read(driveRepositoryProvider).downloadFile(file: file);
      if (!mounted) return;
      setState(() => _downloadedPath = path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image downloaded.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _share(DriveFile file) async {
    final path = _downloadedPath ?? file.localPath;
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download first, then share.')),
      );
      return;
    }
    await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: file.name));
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(driveProvider);
    final file = driveState.files.where((f) => f.id == widget.fileId).firstOrNull;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          file?.name ?? 'Image Preview',
          style: const TextStyle(color: Colors.white, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(_isDownloading ? Icons.downloading_rounded : Icons.download_rounded, color: Colors.white),
            onPressed: file == null || _isDownloading ? null : () => _download(file),
            tooltip: 'Download',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: file == null ? null : () => _share(file),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Center(
        child: file == null
            ? const Text('Image not found', style: TextStyle(color: Colors.white))
            : _buildImageBody(file),
      ),
    );
  }

  Widget _buildImageBody(DriveFile file) {
    final localPath = _downloadedPath ?? file.localPath;
    if (localPath == null || localPath.isEmpty || !File(localPath).existsSync()) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported_rounded, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(
            file.name,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Download this image first, then tap Open in App.',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isDownloading ? null : () => _download(file),
            icon: Icon(_isDownloading ? Icons.downloading_rounded : Icons.download_rounded),
            label: Text(_isDownloading ? 'Downloading...' : 'Download'),
          ),
        ],
      );
    }

    return PhotoView(
      imageProvider: FileImage(File(localPath)),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 4,
      heroAttributes: PhotoViewHeroAttributes(tag: file.id),
      loadingBuilder: (_, __) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
