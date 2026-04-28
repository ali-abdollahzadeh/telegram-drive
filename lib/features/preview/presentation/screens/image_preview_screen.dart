import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../drive/presentation/providers/drive_provider.dart';

class ImagePreviewScreen extends ConsumerWidget {
  final String fileId;
  const ImagePreviewScreen({super.key, required this.fileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driveState = ref.watch(driveProvider);
    final file = driveState.files.where((f) => f.id == fileId).firstOrNull;

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
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () {},
            tooltip: 'Download',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {},
            tooltip: 'Share',
          ),
        ],
      ),
      body: Center(
        child: file == null
            ? const Text('Image not found', style: TextStyle(color: Colors.white))
            : PhotoView(
                // In real app: use NetworkImage or MemoryImage from Telegram
                imageProvider: const AssetImage('assets/images/placeholder.png'),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                heroAttributes: PhotoViewHeroAttributes(tag: file.id),
                loadingBuilder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                errorBuilder: (_, __, ___) => Column(
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
                      'Download to view this image',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
