import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../../core/constants/app_text.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/drive_file.dart';
import '../providers/drive_provider.dart';
import '../widgets/file_grid_item.dart';
import '../widgets/file_list_item.dart';

class FolderScreen extends ConsumerStatefulWidget {
  final String folderId;
  final String folderName;
  const FolderScreen({super.key, required this.folderId, required this.folderName});

  @override
  ConsumerState<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends ConsumerState<FolderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driveProvider.notifier).loadFiles(folderId: widget.folderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(driveProvider);
    final files = driveState.filteredFiles;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: Icon(driveState.viewMode == ViewMode.grid
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded),
            onPressed: () => ref.read(driveProvider.notifier).toggleViewMode(),
          ),
        ],
      ),
      body: driveState.isLoadingFiles
          ? const LoadingView(message: AppText.loadingFiles)
          : files.isEmpty
              ? EmptyState(
                  icon: Icons.folder_open_rounded,
                  title: AppText.folderIsEmpty,
                  subtitle: '${AppText.uploadFilesToFolder}${widget.folderName}',
                )
              : driveState.viewMode == ViewMode.grid
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: files.length,
                        itemBuilder: (_, i) => FileGridItem(
                          file: files[i],
                          isSelectionMode: false,
                          isSelected: false,
                          onTap: () {},
                          onLongPress: () {},
                          onDelete: () => ref.read(driveProvider.notifier).deleteFile(files[i]),
                          onDownload: () => _downloadFile(files[i]),
                          onShare: () => _shareFile(files[i]),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (_, i) => FileListItem(
                        file: files[i],
                        isSelectionMode: false,
                        isSelected: false,
                        onTap: () {},
                        onLongPress: () {},
                        onDelete: () => ref.read(driveProvider.notifier).deleteFile(files[i]),
                        onDownload: () => _downloadFile(files[i]),
                        onShare: () => _shareFile(files[i]),
                      ),
                    ),
    );
  }

  Future<void> _downloadFile(DriveFile file) async {
    try {
      await ref.read(driveRepositoryProvider).downloadFile(file: file);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${file.name} ${AppText.downloadedSnack}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppText.downloadFailed}$e')),
      );
    }
  }

  Future<void> _shareFile(DriveFile file) async {
    var path = file.localPath;
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      try {
        path = await ref.read(driveRepositoryProvider).downloadFile(file: file);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppText.shareFailed}$e')),
        );
        return;
      }
    }
    await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: file.name));
  }
}
