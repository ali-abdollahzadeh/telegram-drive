import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../drive/presentation/providers/drive_provider.dart';

class PdfPreviewScreen extends ConsumerWidget {
  final String fileId;
  const PdfPreviewScreen({super.key, required this.fileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driveState = ref.watch(driveProvider);
    final file = driveState.files.where((f) => f.id == fileId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(file?.name ?? 'PDF Viewer', overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.download_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
        ],
      ),
      body: Center(
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
                file?.name ?? '',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Download the PDF to view it inside the app.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download & Open PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
