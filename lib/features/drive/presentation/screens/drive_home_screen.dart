import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/drive_file.dart';
import '../providers/drive_provider.dart';
import '../widgets/file_grid_item.dart';
import '../widgets/file_list_item.dart';
import '../widgets/storage_selector.dart';
import '../widgets/upload_progress_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

    if (!mounted) return;

    final driveState = ref.read(driveProvider);
    final currentFolderId = driveState.currentFolderId;

    // If user is already in a specific folder, upload directly without asking
    if (currentFolderId != 'saved_messages') {
      for (final file in result.files) {
        if (file.path != null) {
          ref.read(uploadProvider.notifier).uploadFile(
                localPath: file.path!,
                fileName: file.name,
                folderId: currentFolderId,
              );
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppText.uploadingN} ${result.files.length} ${AppText.uploadingFilesSuffix}')),
      );
      return;
    }

    // On the home/Saved Messages view, ask which folder to upload to
    _showUploadDestinationSheet(result.files, driveState);
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
    await SharePlus.instance
        .share(ShareParams(files: [XFile(path)], text: file.name));
  }

  void _showUploadDestinationSheet(
      List<PlatformFile> files, DriveState driveState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xs,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.gapXS,
            Text('Upload ${files.length} file(s) to...',
                style: Theme.of(ctx).textTheme.titleMedium),
            AppSpacing.gapMD,
            ...driveState.folders.map((folder) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      folder.isSavedMessages
                          ? 'assets/icons/ic_av_savedmessages.svg'
                          : 'assets/icons/folder_filled.svg',
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                      width: 20,
                      height: 20,
                    ),
                  ),
                  title: Text(folder.title),
                  subtitle:
                      Text('${folder.fileCount} ${AppText.fileCountSuffix}'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                      SnackBar(
                          content: Text(
                              '${AppText.uploadingN} ${files.length} ${AppText.uploadingFilesSuffix}')),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _deleteFiles(List<DriveFile> files) {
    if (files.isEmpty) return;

    final notifier = ref.read(driveProvider.notifier);
    bool undone = false;

    // Instantly remove from UI — no waiting
    notifier.hideFilesPendingDeletion(files);
    ScaffoldMessenger.of(context).clearSnackBars();

    final label = files.length == 1
        ? '"${files.first.name}" ${AppText.willBeDeleted}'
        : '${files.length} ${AppText.filesWillBeDeleted}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            undone = true;
            notifier.undoDeletion(files);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );

    // After 5 seconds, if not undone, confirm deletion and dismiss the snackbar
    Future.delayed(const Duration(seconds: 5), () {
      if (!undone && mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        notifier.confirmDeletion(files);
      }
    });
  }

  void _handleFileTap(DriveFile file) {
    final state = ref.read(driveProvider);
    if (state.isSelectionMode) {
      ref.read(driveProvider.notifier).toggleFileSelection(file.id);
    } else {
      _openFile(file);
    }
  }

  void _handleFileLongPress(DriveFile file) {
    final state = ref.read(driveProvider);
    if (!state.isSelectionMode) {
      ref.read(driveProvider.notifier).toggleSelectionMode();
      ref.read(driveProvider.notifier).toggleFileSelection(file.id);
    }
  }

  void _showCreateFolderDialog() {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppText.createFolder),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppText.createFolderTelegramNote,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            AppSpacing.gapMD,
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: AppText.folderNameHint,
                prefixIcon: Icon(Icons.folder_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppText.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(driveProvider.notifier).createFolder(ctrl.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
            child: const Text(AppText.create),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<DriveState>(driveProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
      body: RefreshIndicator(
        onRefresh: () => ref.read(driveProvider.notifier).loadAll(),
        color: AppColors.primary,
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(driveState, isDark),
            SliverToBoxAdapter(
                child: StorageSelector(
              folders: driveState.folders,
              selectedId: driveState.currentFolderId,
              onSelected: (id) =>
                  ref.read(driveProvider.notifier).switchFolder(id),
            )),
            if (uploadState.hasActiveTasks)
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  0,
                ),
                child: UploadProgressCard(tasks: uploadState.tasks),
              )),
            _buildFilterBar(driveState),
            if (driveState.isLoadingFiles)
              const SliverFillRemaining(
                  child: LoadingView(message: AppText.loadingFiles))
            else if (files.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.cloud_upload_outlined,
                  title: AppText.noFilesYet,
                  subtitle: AppText.uploadFirstFile,
                  actionLabel: AppText.upload,
                  onAction: _pickAndUpload,
                ),
              )
            else if (driveState.viewMode == ViewMode.grid)
              _buildGridView(files, driveState)
            else
              _buildListView(files, driveState),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      floatingActionButton: driveState.isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _pickAndUpload,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload_rounded),
              label: const Text(AppText.upload),
              elevation: 4,
            ),
    );
  }

  Widget _buildSliverAppBar(DriveState driveState, bool isDark) {
    if (driveState.isSelectionMode) {
      return SliverAppBar(
        floating: true,
        snap: true,
        elevation: 0,
        backgroundColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => ref.read(driveProvider.notifier).clearSelection(),
        ),
        title: Text(
          '${driveState.selectedFileIds.length} ${AppText.selected}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            onPressed: () {
              final selectedFiles = driveState.files
                  .where((f) => driveState.selectedFileIds.contains(f.id))
                  .toList();
              _deleteFiles(selectedFiles);
            },
            tooltip: AppText.tooltipDeleteSelected,
          ),
        ],
      );
    }

    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
      surfaceTintColor: Colors.transparent,
      title: Text(
        AppText.appTitle,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : AppColors.cardDark,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => context.push(AppRoutes.search),
          tooltip: AppText.tooltipSearch,
        ),
        IconButton(
          icon: Icon(driveState.viewMode == ViewMode.grid
              ? Icons.window_outlined
              : Icons.list_outlined),
          onPressed: () => ref.read(driveProvider.notifier).toggleViewMode(),
          tooltip: AppText.tooltipToggleView,
        ),
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: _showCreateFolderDialog,
          tooltip: AppText.tooltipCreateFolder,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () => context.push(AppRoutes.settings),
          tooltip: AppText.tooltipSettings,
        ),
      ],
    );
  }

  Widget _buildFilterBar(DriveState driveState) {
    final types = [null, ...DriveFileType.values];

    final labels = {
      null: AppText.filterAll,
      DriveFileType.image: AppText.filterImages,
      DriveFileType.video: AppText.filterVideos,
      DriveFileType.audio: AppText.filterAudio,
      DriveFileType.pdf: AppText.filterPdf,
      DriveFileType.document: AppText.filterDocs,
      DriveFileType.archive: AppText.filterArchives,
      DriveFileType.other: AppText.filterOther,
    };

    final icons = {
      DriveFileType.image: 'assets/icons/gallery_filled.svg',
      DriveFileType.video: 'assets/icons/video_filled.svg',
      DriveFileType.audio: 'assets/icons/music.svg',
      DriveFileType.pdf: 'assets/icons/file_filled.svg',
      DriveFileType.document: 'assets/icons/edit.svg',
      DriveFileType.archive: 'assets/icons/badgefolder.svg',
      DriveFileType.other: 'assets/icons/ic_voicesharing.svg',
    };

    return SliverToBoxAdapter(
      child: Padding(
        padding: AppSpacing.vXS,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.hMD,
                child: Row(
                  children: types.map((type) {
                    final isSelected = driveState.filterType == type;

                    return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: FilterChip(
                          showCheckmark: false,
                          avatar: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  )
                                : SvgPicture.asset(
                                    icons[type] ?? 'assets/icons/d.svg',
                                    width: 14,
                                    height: 14,
                                  ),
                          ),
                          label: Text(
                            labels[type] ?? AppText.filterOther,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : AppColors.primary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) =>
                              ref.read(driveProvider.notifier).setFilter(type),
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primary,
                        ));
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

  Widget _buildGridView(List<DriveFile> files, DriveState state) {
    return SliverPadding(
      padding: AppSpacing.hMD,
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => FileGridItem(
            file: files[i],
            isSelectionMode: state.isSelectionMode,
            isSelected: state.selectedFileIds.contains(files[i].id),
            onTap: () => _handleFileTap(files[i]),
            onLongPress: () => _handleFileLongPress(files[i]),
            onDelete: () => _deleteFiles([files[i]]),
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

  Widget _buildListView(List<DriveFile> files, DriveState state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => FileListItem(
          file: files[i],
          isSelectionMode: state.isSelectionMode,
          isSelected: state.selectedFileIds.contains(files[i].id),
          onTap: () => _handleFileTap(files[i]),
          onLongPress: () => _handleFileLongPress(files[i]),
          onDelete: () => _deleteFiles([files[i]]),
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
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: PopupMenuButton<SortOption>(
        icon: const Icon(Icons.sort_rounded, size: 22),
        tooltip: AppText.tooltipSearch,
        onSelected: onChanged,
        itemBuilder: (_) => const [
          PopupMenuItem(
              value: SortOption.newest, child: Text(AppText.sortNewest)),
          PopupMenuItem(
              value: SortOption.oldest, child: Text(AppText.sortOldest)),
          PopupMenuItem(
              value: SortOption.nameAZ, child: Text(AppText.sortNameAZ)),
          PopupMenuItem(
              value: SortOption.nameZA, child: Text(AppText.sortNameZA)),
          PopupMenuItem(
              value: SortOption.sizeDesc, child: Text(AppText.sortLargest)),
          PopupMenuItem(
              value: SortOption.sizeAsc, child: Text(AppText.sortSmallest)),
        ],
      ),
    );
  }
}
