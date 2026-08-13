import os

filepath = 'lib/features/library/presentation/pages/all_tracks_page.dart'
with open(filepath, 'r') as f:
    code = f.read()

# Replace Toast with SnackBar
code = code.replace('AppToast', 'AppSnackBar')
code = code.replace('app_toast.dart', 'app_snackbar.dart')

# 1. Bulk Actions Button
s1 = """            child: IconButton(
              icon: const Icon(CupertinoIcons.ellipsis, size: 20),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () => _showBulkActionsSheet(context),
            ),"""
r1 = """            child: IconButton(
              icon: const Icon(CupertinoIcons.trash, size: 20),
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _showDeleteConfirmationDialog(context),
            ),"""
code = code.replace(s1, r1)

# 2. Sheet to Dialogs
s2 = """  void _showBulkActionsSheet(BuildContext context) {
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
                      'Bulk Actions',
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
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _deleteSelectedSongs();
                              },
                              borderRadius: AppRadius.circularLg,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.circularLg,
                                ),
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.trash, color: Theme.of(context).colorScheme.error),
                                    const SizedBox(width: 16),
                                    Text('Delete ${_selectedSongIds.length} songs', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: LayoutConstants.pageBottomPadding.bottom),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }"""
r2 = """  void _showSongQuickActions(BuildContext context, Song song) {
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
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
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
                    Text('Delete Tracks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text('Are you sure you want to delete ${_selectedSongIds.length} tracks?', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)), textAlign: TextAlign.center),
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
                            child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteSelectedSongs();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.circularLg),
                              elevation: 0,
                            ),
                            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  }"""
code = code.replace(s2, r2)

# 3. Slidable start wrap
s3 = """                                  return Slidable("""
r3 = """                                  return Builder(
                                    builder: (context) {
                                      Widget listItem = Slidable("""
code = code.replace(s3, r3)

# 4. Slidable end wrap
s4 = """                                      ),
                                    ),
                                  );
                                },
                                childCount: filteredSongs.isEmpty ? 0 : filteredSongs.length * 2 - 1,
                              ),"""
r4 = """                                      ),
                                    ),
                                  ); // End of PopupMenuButton
                                }, // End of LayoutBuilder builder
                              ), // End of LayoutBuilder
                            ); // End of SizedBox? Wait... no, this is replacing the end of InkWell.
"""

# Actually, replacing the exact text of the end of the list item:
s5 = """                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: filteredSongs.isEmpty ? 0 : filteredSongs.length * 2 - 1,
                              ),"""
r5 = """                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ); // End LayoutBuilder builder's return SizedBox
                                },
                              ), // End LayoutBuilder
                            ); // End child of InkWell

                                if (Platform.isIOS) {
                                  return CupertinoContextMenu.builder(
                                    builder: (context, animation) {
                                      return listItem;
                                    },
                                    actions: [
                                      Builder(
                                        builder: (actionContext) => CupertinoContextMenuAction(
                                          onPressed: () {
                                            Navigator.pop(actionContext);
                                            Future.delayed(const Duration(milliseconds: 500), () {
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
                                            Future.delayed(const Duration(milliseconds: 500), () {
                                              if (mounted) {
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
                                  );
                                },
                                childCount: filteredSongs.isEmpty ? 0 : filteredSongs.length * 2 - 1,
                              ),"""
code = code.replace(s5, r5)

# 5. Remove song info popup item and logic
s6 = """                                                } else if (value == 'song_info') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => SongInfoPage(song: song),
                                                    ),
                                                  );
                                                }
                                              },"""
r6 = """                                                }
                                              },"""
code = code.replace(s6, r6)

s7 = """                                                const PopupMenuItem(
                                                  value: 'song_info',
                                                  child: Row(
                                                    children: [
                                                      Icon(CupertinoIcons.info_circle, size: 20),
                                                      SizedBox(width: 12),
                                                      Text('Song Info'),
                                                    ],
                                                  ),
                                                ),"""
code = code.replace(s7, "")

# 6. Replace onLongPress
s8 = """                                        onLongPress: () {
                                          if (!_isSelectionMode) {
                                            setState(() {
                                              _isSelectionMode = true;
                                              _selectedSongIds.add(song.id);
                                            });
                                          }
                                        },"""
r8 = """                                        onLongPress: Platform.isIOS ? null : () => _showSongQuickActions(context, song),"""
code = code.replace(s8, r8)

# 7. Add LayoutBuilder
s9 = """                                        child: AnimatedContainer(
                                          duration: AppDurations.fast,
                                          color: _selectedSongIds.contains(song.id) ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Row(
                                          children: ["""
r9 = """                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final double width = constraints.maxWidth == double.infinity ? MediaQuery.of(context).size.width - 32 : constraints.maxWidth;
                                            return SizedBox(
                                              width: width,
                                              child: AnimatedContainer(
                                                duration: AppDurations.fast,
                                                color: _selectedSongIds.contains(song.id) ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                child: Row(
                                                children: ["""
code = code.replace(s9, r9)


with open(filepath, 'w') as f:
    f.write(code)

