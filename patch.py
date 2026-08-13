import re

with open('lib/features/library/presentation/pages/all_tracks_page.dart', 'r') as f:
    code = f.read()

# 1. Replace ellipsis with trash in bulk actions
code = code.replace(
'''            child: IconButton(
              icon: const Icon(CupertinoIcons.ellipsis, size: 20),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () => _showBulkActionsSheet(context),
            ),''',
'''            child: IconButton(
              icon: const Icon(CupertinoIcons.trash, size: 20),
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _showDeleteConfirmationDialog(context),
            ),'''
)

# 2. Replace _showBulkActionsSheet with new dialogs
bulk_sheet_regex = re.compile(r'  void _showBulkActionsSheet\(BuildContext context\) \{.*?      }\n    \);\n  }', re.DOTALL)
new_methods = '''  void _showSongQuickActions(BuildContext context, Song song) {
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
  }'''
code = bulk_sheet_regex.sub(new_methods, code)

# 3. Add onLongPress for Android
code = code.replace(
'''                                              onLongPress: () {
                                                if (!_isSelectionMode) {
                                                  setState(() {
                                                    _isSelectionMode = true;
                                                    _selectedSongIds.add(song.id);
                                                  });
                                                }
                                              },''',
'''                                              onLongPress: Platform.isIOS ? null : () => _showSongQuickActions(context, song),'''
)

# 4. Wrap AnimatedContainer in LayoutBuilder
code = code.replace(
'''                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width,
                                                child: AnimatedContainer(
                                                  duration: AppDurations.fast,
                                                  color: _selectedSongIds.contains(song.id) ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  child: Row(
                                                    children: [''',
'''                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  final double width = constraints.maxWidth == double.infinity 
                                                      ? MediaQuery.of(context).size.width - 32
                                                      : constraints.maxWidth;
                                                  return SizedBox(
                                                    width: width,
                                                    child: AnimatedContainer(
                                                      duration: AppDurations.fast,
                                                      color: _selectedSongIds.contains(song.id) ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      child: Row(
                                                        children: ['''
)

# 5. Remove song info from popup menu
song_info_popup_regex = re.compile(r"                                                \} else if \(value == 'song_info'\) \{.*?                                                \n                                              \},", re.DOTALL)
code = song_info_popup_regex.sub(r'''                                                }
                                              },''', code)

song_info_item_regex = re.compile(r"                                                const PopupMenuItem\(\n                                                  value: 'song_info'.*?                                                \),", re.DOTALL)
code = song_info_item_regex.sub('', code)

# 6. Apply CupertinoContextMenu.builder with 500ms delay and close LayoutBuilder correctly
end_of_list_item = '''                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );'''
new_end_of_list_item = '''                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );

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
                                return listItem;'''

code = code.replace(
'''                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );''', new_end_of_list_item)


with open('lib/features/library/presentation/pages/all_tracks_page.dart', 'w') as f:
    f.write(code)
