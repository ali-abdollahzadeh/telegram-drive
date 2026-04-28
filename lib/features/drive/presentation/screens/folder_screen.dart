import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/common_widgets.dart';
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
          ? const LoadingView(message: 'Loading files...')
          : files.isEmpty
              ? EmptyState(
                  icon: Icons.folder_open_rounded,
                  title: 'Folder is empty',
                  subtitle: 'Upload files to ${widget.folderName}',
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
                          onTap: () {},
                          onDelete: () => ref.read(driveProvider.notifier).deleteFile(files[i]),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (_, i) => FileListItem(
                        file: files[i],
                        onTap: () {},
                        onDelete: () => ref.read(driveProvider.notifier).deleteFile(files[i]),
                      ),
                    ),
    );
  }
}
