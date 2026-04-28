import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../drive/domain/entities/drive_file.dart';
import '../../../drive/presentation/providers/drive_provider.dart';
import '../widgets/file_type_filter_chips.dart';
import '../widgets/search_result_item.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchFilterProvider = StateProvider<DriveFileType?>((ref) => null);
final searchSortProvider = StateProvider<SortOption>((ref) => SortOption.newest);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DriveFile> _getResults() {
    final query = ref.watch(searchQueryProvider).toLowerCase();
    final filter = ref.watch(searchFilterProvider);
    final sort = ref.watch(searchSortProvider);
    final allFiles = ref.watch(driveProvider).files;

    var results = allFiles.where((f) {
      final matchesQuery = query.isEmpty || f.name.toLowerCase().contains(query);
      final matchesFilter = filter == null || f.type == filter;
      return matchesQuery && matchesFilter;
    }).toList();

    switch (sort) {
      case SortOption.newest:
        results.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      case SortOption.oldest:
        results.sort((a, b) => a.uploadedAt.compareTo(b.uploadedAt));
      case SortOption.nameAZ:
        results.sort((a, b) => a.name.compareTo(b.name));
      case SortOption.nameZA:
        results.sort((a, b) => b.name.compareTo(a.name));
      case SortOption.sizeDesc:
        results.sort((a, b) => b.size.compareTo(a.size));
      case SortOption.sizeAsc:
        results.sort((a, b) => a.size.compareTo(b.size));
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final results = _getResults();
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search files...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchCtrl.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          style: Theme.of(context).textTheme.titleMedium,
          onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
        ),
      ),
      body: Column(
        children: [
          FileTypeFilterChips(
            selected: ref.watch(searchFilterProvider),
            onSelected: (t) => ref.read(searchFilterProvider.notifier).state = t,
          ),
          const Divider(height: 1),
          Expanded(
            child: query.isEmpty && results.isEmpty
                ? EmptyState(
                    icon: Icons.search_rounded,
                    title: 'Search your files',
                    subtitle: 'Type to search across all your Telegram Drive files',
                  )
                : results.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No results found',
                        subtitle: 'Try a different search term or filter',
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (_, i) => SearchResultItem(file: results[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
