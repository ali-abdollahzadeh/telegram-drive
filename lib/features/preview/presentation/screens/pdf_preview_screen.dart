import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../drive/domain/entities/drive_file.dart';
import '../../../drive/presentation/providers/drive_provider.dart';

class PdfPreviewScreen extends ConsumerStatefulWidget {
  final String fileId;
  const PdfPreviewScreen({super.key, required this.fileId});

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  int _currentPage = 0;
  int _totalPages = 0;
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
        const SnackBar(content: Text('PDF downloaded.')),
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
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], text: file.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(driveProvider);
    final file = driveState.files.where((f) => f.id == widget.fileId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(file?.name ?? 'PDF Viewer', overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(_isDownloading ? Icons.downloading_rounded : Icons.download_rounded),
            onPressed: file == null || _isDownloading ? null : () => _download(file),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: file == null ? null : () => _share(file),
          ),
        ],
      ),
      body: file == null ? const Center(child: Text('PDF file not found')) : _buildPdfBody(context, file),
    );
  }

  Widget _buildPdfBody(BuildContext context, DriveFile file) {
    final localPath = _downloadedPath ?? file.localPath;
    if (localPath == null || localPath.isEmpty || !File(localPath).existsSync()) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.filePdf.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.filePdf, size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                file.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Download this PDF first, then tap Open in App.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isDownloading ? null : () => _download(file),
                icon: Icon(_isDownloading ? Icons.downloading_rounded : Icons.download_rounded),
                label: Text(_isDownloading ? 'Downloading...' : 'Download'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        PDFView(
          filePath: localPath,
          autoSpacing: true,
          enableSwipe: true,
          swipeHorizontal: false,
          pageSnap: true,
          onRender: (pages) {
            if (!mounted) return;
            setState(() => _totalPages = pages ?? 0);
          },
          onPageChanged: (page, _) {
            if (!mounted) return;
            setState(() => _currentPage = page ?? 0);
          },
          onError: (_) {},
          onPageError: (_, __) {},
        ),
        if (_totalPages > 0)
          Positioned(
            right: 12,
            bottom: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
