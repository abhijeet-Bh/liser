import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/data/models/playlist.dart';
import 'package:liser/features/library/presentation/bloc/library_bloc.dart';
import 'package:liser/features/player/presentation/bloc/player_bloc.dart';
import 'package:liser/app/theme/app_colors.dart';
import 'package:liser/app/widgets/frosted_background.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';
import 'package:liser/core/constants/layout_constants.dart';

import 'package:liser/core/utils/app_snackbar.dart';
import 'package:liser/core/constants/app_constants.dart';
import 'package:liser/features/library/presentation/pages/song_info_page.dart';

class AllTracksPage extends StatefulWidget {
  final String? artistFilter;
  const AllTracksPage({super.key, this.artistFilter});

  @override
  State<AllTracksPage> createState() => _AllTracksPageState();
}

enum TrackSortOption { newest, mostPlayed, titleAsc, titleDesc }

class _AllTracksPageState extends State<AllTracksPage> {
  String _searchQuery = '';
  TrackSortOption _sortOption = TrackSortOption.newest;
  bool _isSelectionMode = false;
  final Set<String> _selectedSongIds = {};

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: CupertinoSearchTextField(
              placeholder: 'Search songs or artists...',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              itemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: AppRadius.circularSm,
            ),
            child: IconButton(
              icon: const Icon(CupertinoIcons.slider_horizontal_3, size: 20),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () => _showSortOptions(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.xmark),
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              setState(() {
                _isSelectionMode = false;
                _selectedSongIds.clear();
              });
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_selectedSongIds.length} Selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: AppRadius.circularSm,
            ),
            child: IconButton(
              icon: Icon(CupertinoIcons.trash, size: 20, color: Theme.of(context).colorScheme.error),
              onPressed: () => _showDeleteConfirmationDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: AppRadius.circularXl,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: AppPadding.allXl,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: AppPadding.allLg,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.trash, color: Theme.of(context).colorScheme.error, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Delete Songs',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to delete ${_selectedSongIds.length} selected songs?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.circularLg),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteSelectedSongs();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Theme.of(context).colorScheme.onError,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.circularLg),
                            ),
                            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteSelectedSongs() {
    final bloc = context.read<LibraryBloc>();
    final songs = bloc.state.songs.where((s) => _selectedSongIds.contains(s.id)).toList();
    for (final song in songs) {
      bloc.add(RemoveSong(song));
    }
    setState(() {
      _isSelectionMode = false;
      _selectedSongIds.clear();
    });
    AppSnackBar.show(context, '${songs.length} songs deleted', type: SnackBarType.error);
  }

  Future<bool> _confirmSingleDelete(Song song) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: AppRadius.circularXl,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: AppPadding.allXl,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: AppPadding.allLg,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.trash, color: Theme.of(context).colorScheme.error, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Delete Song',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to delete "${song.title}"?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.circularLg),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Theme.of(context).colorScheme.onError,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.circularLg),
                            ),
                            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }



  void _showSongQuickActions(BuildContext context, Song song) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(song.title),
        message: Text(song.artist),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (!_isSelectionMode) {
                  _isSelectionMode = true;
                }
                _selectedSongIds.add(song.id);
              });
            },
            child: const Text('Select'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongInfoPage(song: song),
                ),
              );
            },
            child: const Text('Song Info'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          isDefaultAction: true,
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sort Tracks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildSortOption(context, 'Newest', TrackSortOption.newest, CupertinoIcons.time),
                          const SizedBox(height: 8),
                          _buildSortOption(context, 'Most Played', TrackSortOption.mostPlayed, CupertinoIcons.play_circle),
                          const SizedBox(height: 8),
                          _buildSortOption(context, 'Title (A-Z)', TrackSortOption.titleAsc, CupertinoIcons.sort_down),
                          const SizedBox(height: 8),
                          _buildSortOption(context, 'Title (Z-A)', TrackSortOption.titleDesc, CupertinoIcons.sort_up),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildSortOption(BuildContext context, String title, TrackSortOption option, IconData icon) {
    final isSelected = _sortOption == option;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _sortOption = option);
          Navigator.pop(context);
        },
        borderRadius: AppRadius.circularLg,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: AppRadius.circularLg,
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: AppPadding.allSm,
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(CupertinoIcons.checkmark_alt_circle_fill, color: Theme.of(context).colorScheme.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context, Song song) {
    if (song.title.isEmpty) return const Icon(CupertinoIcons.music_note, color: Colors.grey);
    return Center(
      child: Text(
        song.title[0].toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StreamBuilder<List<Playlist>>(
          stream: sl<LibraryRepository>().watchPlaylists(),
          builder: (context, snapshot) {
            final playlists = snapshot.data ?? [];
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      padding: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 48,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                          Text(
                            'Add to Playlist',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 24),
                      if (playlists.isEmpty)
                        const Padding(
                          padding: AppPadding.allXxl,
                          child: Text('No playlists created yet.'),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: playlists.length,
                            itemBuilder: (context, index) {
                              final playlist = playlists[index];
                              final isAlreadyAdded = playlist.songIds.contains(song.id);
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: AppRadius.circularLg,
                                    onTap: () {
                                      if (isAlreadyAdded) {
                                        context.read<LibraryBloc>().add(RemoveSongFromPlaylist(playlist, song));
                                      } else {
                                        context.read<LibraryBloc>().add(AddSongToPlaylist(playlist, song));
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: AppDurations.fast,
                                      padding: AppPadding.allMd,
                                      decoration: BoxDecoration(
                                        color: isAlreadyAdded ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                                        borderRadius: AppRadius.circularLg,
                                        border: Border.all(
                                          color: isAlreadyAdded ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: isAlreadyAdded ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                                              borderRadius: AppRadius.circularMd,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                )
                                              ],
                                            ),
                                            child: Icon(
                                              CupertinoIcons.music_note_list,
                                              color: isAlreadyAdded ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  playlist.name,
                                                  style: TextStyle(
                                                    fontWeight: isAlreadyAdded ? FontWeight.w700 : FontWeight.w600,
                                                    fontSize: 16,
                                                    color: isAlreadyAdded ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${playlist.songIds.length} songs',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isAlreadyAdded)
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 16),
                                            )
                                          else
                                            Icon(CupertinoIcons.add_circled, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), size: 28),
                                        ],
                                      ),
                                    ),
                                    ),
                                  ),
                                );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FrostedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            children: [
              Text(widget.artistFilter ?? 'All Tracks', style: const TextStyle(fontWeight: FontWeight.w700)),
              BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  final filteredSongs = widget.artistFilter != null ? state.songs.where((s) => s.artist == widget.artistFilter).toList() : state.songs;
                  if (state.status == LibraryStatus.loaded && filteredSongs.isNotEmpty) {
                    return Text(
                      '${filteredSongs.length} Tracks',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: _isSelectionMode ? _buildSelectionBar() : _buildSearchBar(),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SafeArea(
            bottom: false,
            child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, libraryState) {
                switch (libraryState.status) {
                  case LibraryStatus.initial:
                  case LibraryStatus.loading:
                    return const Center(child: CircularProgressIndicator());

                  case LibraryStatus.failure:
                    return Center(child: Text(libraryState.error ?? 'Unknown error'));

                  case LibraryStatus.loaded:
                    final baseSongs = widget.artistFilter != null ? libraryState.songs.where((s) => s.artist == widget.artistFilter).toList() : libraryState.songs.toList();
                    final filteredSongs = _searchQuery.isEmpty 
                      ? baseSongs 
                      : baseSongs.where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase()) || s.artist.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                    switch (_sortOption) {
                      case TrackSortOption.newest:
                        filteredSongs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
                        break;
                      case TrackSortOption.mostPlayed:
                        filteredSongs.sort((a, b) => b.playCount.compareTo(a.playCount));
                        break;
                      case TrackSortOption.titleAsc:
                        filteredSongs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
                        break;
                      case TrackSortOption.titleDesc:
                        filteredSongs.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
                        break;
                    }

                    return CustomScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        if (filteredSongs.isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(CupertinoIcons.music_note_list, size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text('No songs found', style: Theme.of(context).textTheme.titleLarge),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: LayoutConstants.standardListPadding,
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index.isOdd) {
                                    return const Divider(
                                      height: 1, 
                                      thickness: 1, 
                                      indent: 84, // Align with text (16 padding + 48 image + 16 spacing = 80 + 4)
                                      endIndent: 24,
                                      color: Colors.white10
                                    );
                                  }
                                  
                                  final songIndex = index ~/ 2;
                                  final song = filteredSongs[songIndex];
                                  // Captured from the Builder inside the Slidable so
                                  // confirmDismiss can close the pane after acting.
                                  SlidableController? slidableController;

                                  return Slidable(
                                    key: ValueKey(song.id),
                                    startActionPane: ActionPane(
                                      motion: const StretchMotion(),
                                      // Auto-trigger when swiped past 50% of the item width.
                                      dismissible: DismissiblePane(
                                        dismissThreshold: 0.5,
                                        onDismissed: () {},
                                        confirmDismiss: () async {
                                          context.read<PlayerBloc>().add(AddSongToEnd(song));
                                          AppSnackBar.show(context, '${song.title} added to queue', type: SnackBarType.success);
                                          // Snap closed instead of staying in the open state.
                                          Future.microtask(() => slidableController?.close());
                                          return false;
                                        },
                                      ),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            context.read<PlayerBloc>().add(AddSongToEnd(song));
                                            AppSnackBar.show(context, '${song.title} added to queue', type: SnackBarType.success);
                                          },
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          icon: CupertinoIcons.text_insert,
                                        ),
                                      ],
                                    ),
                                    endActionPane: ActionPane(
                                      motion: const StretchMotion(),
                                      // Auto-trigger delete when swiped past 50%.
                                      dismissible: DismissiblePane(
                                        dismissThreshold: 0.5,
                                        onDismissed: () {},
                                        confirmDismiss: () async {
                                          final confirm = await _confirmSingleDelete(song);
                                          if (confirm) {
                                            if (context.mounted) {
                                              context.read<LibraryBloc>().add(RemoveSong(song));
                                            }
                                            return true;
                                          }
                                          Future.microtask(() => slidableController?.close());
                                          return false;
                                        },
                                      ),
                                      children: [
                                        SlidableAction(
                                          onPressed: (slidableContext) async {
                                            final confirm = await _confirmSingleDelete(song);
                                            if (confirm) {
                                              if (context.mounted) {
                                                context.read<LibraryBloc>().add(RemoveSong(song));
                                              }
                                            }
                                          },
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          icon: CupertinoIcons.trash,
                                        ),
                                      ],
                                    ),
                                      child: Builder(
                                        builder: (context) {
                                          // Capture the controller so the DismissiblePane
                                          // confirmDismiss can close it programmatically.
                                          slidableController = Slidable.of(context);
                                          Widget listItem = Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onLongPress: Platform.isIOS ? null : () => _showSongQuickActions(context, song),
                                              onTap: () {
                                                if (_isSelectionMode) {
                                                  setState(() {
                                                    if (_selectedSongIds.contains(song.id)) {
                                                      _selectedSongIds.remove(song.id);
                                                      if (_selectedSongIds.isEmpty) {
                                                        _isSelectionMode = false;
                                                      }
                                                    } else {
                                                      _selectedSongIds.add(song.id);
                                                    }
                                                  });
                                                } else {
                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                  context.read<PlayerBloc>().add(
                                                        PlaySong(song: song, queue: filteredSongs),
                                                      );
                                                }
                                              },
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width,
                                                child: AnimatedContainer(
                                                  duration: AppDurations.fast,
                                          color: _selectedSongIds.contains(song.id) ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Row(
                                          children: [
                                            if (_isSelectionMode)
                                              Padding(
                                                padding: const EdgeInsets.only(right: 12),
                                                child: Icon(
                                                  _selectedSongIds.contains(song.id) 
                                                    ? CupertinoIcons.checkmark_circle_fill 
                                                    : CupertinoIcons.circle,
                                                  color: _selectedSongIds.contains(song.id)
                                                    ? Theme.of(context).colorScheme.primary 
                                                    : Theme.of(context).dividerColor,
                                                  size: 22,
                                                ),
                                              ),
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Container(
                                                    width: 48,
                                                    height: 48,
                                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                    child: song.artworkPath != null
                                                        ? Image.file(
                                                            File(song.artworkPath!),
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(context, song),
                                                          )
                                                        : _buildFallbackIcon(context, song),
                                                  ),
                                                ),
                                                if (song.isLossless)
                                                  Positioned(
                                                    bottom: -2,
                                                    right: -2,
                                                    child: Container(
                                                      decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      padding: const EdgeInsets.all(2),
                                                      child: const Icon(CupertinoIcons.star_fill, color: Color(0xFF10B981), size: 10),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    song.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    song.artist,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                song.favorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                                color: song.favorite ? Colors.red : Theme.of(context).textTheme.bodySmall?.color,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                context.read<LibraryBloc>().add(LibraryToggleFavorite(song));
                                              },
                                            ),
                                            PopupMenuButton<String>(
                                              icon: Icon(CupertinoIcons.ellipsis, color: Theme.of(context).textTheme.bodySmall?.color, size: 20),
                                              shape: RoundedRectangleBorder(borderRadius: AppRadius.circularLg),
                                              color: Theme.of(context).colorScheme.surface,
                                              elevation: 8,
                                              onSelected: (value) {
                                                if (value == 'play_next') {
                                                  context.read<PlayerBloc>().add(AddSongNext(song));
                                                } else if (value == 'add_to_last') {
                                                  context.read<PlayerBloc>().add(AddSongToEnd(song));
                                                } else if (value == 'add_to_playlist') {
                                                  _showAddToPlaylistSheet(context, song);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'play_next',
                                                  child: Row(
                                                    children: [
                                                      Icon(CupertinoIcons.arrow_right_to_line, size: 20),
                                                      SizedBox(width: 12),
                                                      Text('Play Next'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'add_to_last',
                                                  child: Row(
                                                    children: [
                                                      Icon(CupertinoIcons.text_append, size: 20),
                                                      SizedBox(width: 12),
                                                      Text('Add to Last'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'add_to_playlist',
                                                  child: Row(
                                                    children: [
                                                      Icon(CupertinoIcons.music_note_list, size: 20),
                                                      SizedBox(width: 12),
                                                      Text('Add to Playlist'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );

                                if (Platform.isIOS) {
                                  return CupertinoContextMenu.builder(
                                    builder: (context, animation) {
                                      return FittedBox(
                                        fit: BoxFit.cover,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16 * animation.value),
                                          child: Container(
                                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: animation.value),
                                            child: listItem,
                                          ),
                                        ),
                                      );
                                    },
                                    actions: [
                                      Builder(
                                        builder: (actionContext) => CupertinoContextMenuAction(
                                          onPressed: () {
                                            Navigator.pop(actionContext);
                                            Future.delayed(const Duration(milliseconds: 300), () {
                                              if (mounted) {
                                                setState(() {
                                                  if (!_isSelectionMode) {
                                                    _isSelectionMode = true;
                                                  }
                                                  _selectedSongIds.add(song.id);
                                                });
                                              }
                                            });
                                          },
                                          child: const Text('Select'),
                                        ),
                                      ),
                                      Builder(
                                        builder: (actionContext) => CupertinoContextMenuAction(
                                          onPressed: () {
                                            Navigator.pop(actionContext);
                                            Future.delayed(const Duration(milliseconds: 300), () {
                                              if (context.mounted) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SongInfoPage(song: song),
                                                  ),
                                                );
                                              }
                                            });
                                          },
                                          child: const Text('Song Info'),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return listItem;
                              },
                            ),
                          );
                                },
                                childCount: filteredSongs.isEmpty ? 0 : filteredSongs.length * 2 - 1,
                              ),
                            ),
                          ),
                      ],
                    );
                }
                return const SizedBox.shrink();
              },
            ), // End of SafeArea
          ), // End of GestureDetector
        ), // End of Scaffold
      ), // End of FrostedBackground
    );
  }
}
