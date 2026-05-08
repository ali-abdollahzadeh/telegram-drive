import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../../core/constants/app_text.dart';
import '../../../drive/presentation/providers/drive_provider.dart';

class VideoPreviewScreen extends ConsumerStatefulWidget {
  final String fileId;
  const VideoPreviewScreen({super.key, required this.fileId});

  @override
  ConsumerState<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends ConsumerState<VideoPreviewScreen> {
  VideoPlayerController? _vpController;
  ChewieController? _chewieController;
  bool _isDownloading = false;
  String? _downloadedPath;

  Future<void> _download() async {
    final file = ref.read(driveProvider).files.where((f) => f.id == widget.fileId).firstOrNull;
    if (file == null || _isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final path = await ref.read(driveRepositoryProvider).downloadFile(file: file);
      await _initPlayer(path);
      if (!mounted) return;
      setState(() => _downloadedPath = path);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppText.videoDownloaded)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppText.downloadFailed}$e')));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _share() async {
    final file = ref.read(driveProvider).files.where((f) => f.id == widget.fileId).firstOrNull;
    if (file == null) return;
    final path = _downloadedPath ?? file.localPath;
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppText.downloadFirst)));
      return;
    }
    await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: file.name));
  }

  Future<void> _initPlayer(String path) async {
    if (path.isEmpty || !File(path).existsSync()) return;
    _chewieController?.dispose();
    _vpController?.dispose();
    final vp = VideoPlayerController.file(File(path));
    await vp.initialize();
    if (!mounted) {
      vp.dispose();
      return;
    }
    final chewie = ChewieController(videoPlayerController: vp, autoPlay: false, looping: false);
    setState(() {
      _vpController = vp;
      _chewieController = chewie;
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _vpController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(driveProvider);
    final file = driveState.files.where((f) => f.id == widget.fileId).firstOrNull;
    final existingPath = _downloadedPath ?? file?.localPath;
    if (_chewieController == null &&
        existingPath != null &&
        existingPath.isNotEmpty &&
        File(existingPath).existsSync()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initPlayer(existingPath);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          file?.name ?? AppText.videoPreview,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(_isDownloading ? Icons.downloading_rounded : Icons.download_rounded, color: Colors.white),
            onPressed: _isDownloading ? null : _download,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: _share,
          ),
        ],
      ),
      body: Center(
        child: _chewieController != null
            ? AspectRatio(
                aspectRatio: _vpController?.value.aspectRatio ?? (16 / 9),
                child: Chewie(controller: _chewieController!),
              )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_rounded, color: Colors.white54, size: 80),
            const SizedBox(height: 24),
            Text(
              file?.name ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              AppText.downloadToPlayVideo,
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isDownloading ? null : _download,
              icon: Icon(_isDownloading ? Icons.downloading_rounded : Icons.download_rounded),
              label: Text(_isDownloading ? AppText.downloading : AppText.downloadToPlay),
            ),
          ],
        ),
      ),
    );
  }
}
