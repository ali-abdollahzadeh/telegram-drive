import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../drive/presentation/providers/drive_provider.dart';

class AudioPreviewScreen extends ConsumerStatefulWidget {
  final String fileId;
  const AudioPreviewScreen({super.key, required this.fileId});

  @override
  ConsumerState<AudioPreviewScreen> createState() => _AudioPreviewScreenState();
}

class _AudioPreviewScreenState extends ConsumerState<AudioPreviewScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isDownloading = false;
  String? _downloadedPath;
  double _progress = 0.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() {
        _position = pos;
        _progress = _duration.inMilliseconds == 0
            ? 0
            : pos.inMilliseconds / _duration.inMilliseconds;
      });
    });
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);
    });
    _player.durationStream.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d ?? Duration.zero);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    final file = ref
        .read(driveProvider)
        .files
        .where((f) => f.id == widget.fileId)
        .firstOrNull;
    if (file == null || _isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final path =
          await ref.read(driveRepositoryProvider).downloadFile(file: file);
      if (!mounted) return;
      setState(() => _downloadedPath = path);
      await _player.setFilePath(path);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppText.audioDownloaded)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${AppText.downloadFailed}$e')));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _share() async {
    final file = ref
        .read(driveProvider)
        .files
        .where((f) => f.id == widget.fileId)
        .firstOrNull;
    if (file == null) return;
    final path = _downloadedPath ?? file.localPath;
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppText.downloadFirst)),
      );
      return;
    }
    await SharePlus.instance
        .share(ShareParams(files: [XFile(path)], text: file.name));
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(driveProvider);
    final file =
        driveState.files.where((f) => f.id == widget.fileId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: _share),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album art placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 48,
                    spreadRadius: 0,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: const Icon(Icons.music_note_rounded,
                  color: Colors.white, size: 80),
            ),
            const SizedBox(height: 40),
            Text(
              file?.name ?? '',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(AppText.audioFile,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 32),
            // Progress
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: _progress,
                onChanged: (v) {
                  final ms = (_duration.inMilliseconds * v).round();
                  _player.seek(Duration(milliseconds: ms));
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position),
                    style: Theme.of(context).textTheme.bodySmall),
                Text(_fmt(_duration),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 24),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 36),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () async {
                    final localPath = _downloadedPath ?? file?.localPath;
                    if (localPath == null ||
                        localPath.isEmpty ||
                        !File(localPath).existsSync()) {
                      await _download();
                      return;
                    }
                    if (_player.audioSource == null) {
                      await _player.setFilePath(localPath);
                    }
                    if (_isPlaying) {
                      await _player.pause();
                    } else {
                      await _player.play();
                    }
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 36),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isDownloading)
              const Text(AppText.downloadingLabel,
                  style: TextStyle(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
