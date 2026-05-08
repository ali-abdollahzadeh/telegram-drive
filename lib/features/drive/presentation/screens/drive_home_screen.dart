import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/drive_file.dart';
import '../providers/drive_provider.dart';
import '../widgets/file_grid_item.dart';
import '../widgets/file_list_item.dart';
import '../widgets/storage_selector.dart';
import '../widgets/upload_progress_card.dart';

class DriveHomeScreen extends ConsumerStatefulWidget {
  const DriveHomeScreen({super.key});

  @override
  ConsumerState<DriveHomeScreen> createState() => _DriveHomeScreenState();
}

class _DriveHomeScreenState extends ConsumerState<DriveHomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;

    final driveState = ref.read(driveProvider);

    if (!mounted) return;

    _showUploadDestinationSheet(result.files, driveState);
  }

  Future<void> _downloadFile(DriveFile file) async {
    try {
      await ref.read(driveRepositoryProvider).downloadFile(file: file);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${file.name} downloaded')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
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
          SnackBar(content: Text('Share failed: $e')),
        );
        return;
      }
    }
    await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: file.name));
  }

  void _showUploadDestinationSheet(List<PlatformFile> files, DriveState driveState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Upload ${files.length} file(s) to...', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...driveState.folders.map((folder) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      folder.isSavedMessages ? Icons.bookmark_rounded : Icons.folder_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(folder.title),
                  subtitle: Text('${folder.fileCount} files'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    for (final file in files) {
                      if (file.path != null) {
                        ref.read(uploadProvider.notifier).uploadFile(
                              localPath: file.path!,
                              fileName: file.name,
                              folderId: folder.id,
                            );
                      }
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Uploading ${files.length} file(s)...')),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            prefixIcon: Icon(Icons.folder_rounded),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(driveProvider.notifier).createFolder(ctrl.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(driveProvider);
    final uploadState = ref.watch(uploadProvider);
    final files = driveState.filteredFiles;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(driveProvider.notifier).loadAll(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(driveState),
            SliverToBoxAdapter(child: StorageSelector(
              folders: driveState.folders,
              selectedId: driveState.currentFolderId,
              onSelected: (id) => ref.read(driveProvider.notifier).switchFolder(id),
            )),
            if (uploadState.hasActiveTasks)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: UploadProgressCard(tasks: uploadState.tasks),
              )),
            _buildFilterBar(driveState),
            if (driveState.isLoadingFiles)
              const SliverFillRemaining(child: LoadingView(message: 'Loading files...'))
            else if (files.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.cloud_upload_outlined,
                  title: 'No files yet',
                  subtitle: 'Upload your first file to get started',
                  actionLabel: 'Upload',
                  onAction: _pickAndUpload,
                ),
              )
            else if (driveState.viewMode == ViewMode.grid)
              _buildGridView(files)
            else
              _buildListView(files),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndUpload,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_rounded),
        label: const Text('Upload'),
        elevation: 4,
      ),
    );
  }

  Widget _buildSliverAppBar(DriveState driveState) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      title: const Text('TeleDrive'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => context.push(AppRoutes.search),
          tooltip: 'Search',
        ),
        IconButton(
          icon: Icon(driveState.viewMode == ViewMode.grid
              ? Icons.view_list_rounded
              : Icons.grid_view_rounded),
          onPressed: () => ref.read(driveProvider.notifier).toggleViewMode(),
          tooltip: 'Toggle view',
        ),
        IconButton(
          icon: const Icon(Icons.create_new_folder_rounded),
          onPressed: _showCreateFolderDialog,
          tooltip: 'Create folder',
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () => context.push(AppRoutes.settings),
          tooltip: 'Settings',
        ),
      ],
    );
  }
Widget _buildFilterBar(DriveState driveState) {
  final types = [null, ...DriveFileType.values];

  final labels = {
    null: 'All',
    DriveFileType.image: 'Images',
    DriveFileType.video: 'Videos',
    DriveFileType.audio: 'Audio',
    DriveFileType.pdf: 'PDF',
    DriveFileType.document: 'Docs',
    DriveFileType.archive: 'Archives',
    DriveFileType.other: 'Other',
  };

  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: types.map((type) {
                  final isSelected = driveState.filterType == type;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(labels[type] ?? 'Other'),
                      selected: isSelected,
                      onSelected: (_) =>
                          ref.read(driveProvider.notifier).setFilter(type),
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.22),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          _SortButton(
            current: driveState.sortOption,
            onChanged: (s) => ref.read(driveProvider.notifier).setSort(s),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildGridView(List<DriveFile> files) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => FileGridItem(
            file: files[i],
            onTap: () => _openFile(files[i]),
            onDelete: () => ref.read(driveProvider.notifier).deleteFile(files[i]),
            onDownload: () => _downloadFile(files[i]),
            onShare: () => _shareFile(files[i]),
          ),
          childCount: files.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
      ),
    );
  }

  Widget _buildListView(List<DriveFile> files) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => FileListItem(
          file: files[i],
          onTap: () => _openFile(files[i]),
          onDelete: () => ref.read(driveProvider.notifier).deleteFile(files[i]),
          onDownload: () => _downloadFile(files[i]),
          onShare: () => _shareFile(files[i]),
        ),
        childCount: files.length,
      ),
    );
  }

  void _openFile(DriveFile file) {
    switch (file.type) {
      case DriveFileType.image:
        context.push('/preview/image/${file.id}');
      case DriveFileType.video:
        context.push('/preview/video/${file.id}');
      case DriveFileType.audio:
        context.push('/preview/audio/${file.id}');
      case DriveFileType.pdf:
        context.push('/preview/pdf/${file.id}');
      default:
        context.push('/file/${file.id}');
    }
  }
}

class _SortButton extends StatelessWidget {
  final SortOption current;
  final ValueChanged<SortOption> onChanged;
  const _SortButton({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<SortOption>(
        icon: const Icon(Icons.sort_rounded, size: 22),
        tooltip: 'Sort',
        onSelected: onChanged,
        itemBuilder: (_) => const [
          PopupMenuItem(value: SortOption.newest, child: Text('Newest first')),
          PopupMenuItem(value: SortOption.oldest, child: Text('Oldest first')),
          PopupMenuItem(value: SortOption.nameAZ, child: Text('Name A–Z')),
          PopupMenuItem(value: SortOption.nameZA, child: Text('Name Z–A')),
          PopupMenuItem(value: SortOption.sizeDesc, child: Text('Largest first')),
          PopupMenuItem(value: SortOption.sizeAsc, child: Text('Smallest first')),
        ],
      ),
    );
  }
}
