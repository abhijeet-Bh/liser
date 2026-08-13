import re

with open('lib/features/library/presentation/pages/all_tracks_page.dart', 'r') as f:
    code = f.read()

# 1. Replace bulk actions with trash
code = code.replace('''            child: IconButton(
              icon: const Icon(CupertinoIcons.ellipsis, size: 20),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () => _showBulkActionsSheet(context),
            ),''', '''            child: IconButton(
              icon: const Icon(CupertinoIcons.trash, size: 20),
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _showDeleteConfirmationDialog(context),
            ),''')

# 2. Add dialogs
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

# 3. Setup LayoutBuilder, update onLongPress, remove song_info from popup menu, wrap Slidable
# Let's extract the whole Slidable widget and modify it.
slidable_regex = re.compile(r'( *return )Slidable\(.*?\n( *) childCount:', re.DOTALL)
match = slidable_regex.search(code)
if match:
    slidable_code = match.group(0)
    
    # 3a. Update onLongPress
    on_long_press_re = re.compile(r'onLongPress: \(\) \{.*?\}', re.DOTALL)
    slidable_code = on_long_press_re.sub('onLongPress: Platform.isIOS ? null : () => _showSongQuickActions(context, song)', slidable_code)
    
    # 3b. Wrap AnimatedContainer in LayoutBuilder
    animated_container_re = re.compile(r'( *)child: AnimatedContainer\(\n.*?duration: AppDurations.fast,.*?color: _selectedSongIds\.contains.*?child: Row\(', re.DOTALL)
    def repl(m):
        indent = m.group(1)
        return indent + 'child: LayoutBuilder(\n' + \
               indent + '  builder: (context, constraints) {\n' + \
               indent + '    final double width = constraints.maxWidth == double.infinity ? MediaQuery.of(context).size.width - 32 : constraints.maxWidth;\n' + \
               indent + '    return SizedBox(\n' + \
               indent + '      width: width,\n' + \
               indent + '      child: AnimatedContainer(\n' + \
               indent + '        duration: AppDurations.fast,\n' + \
               indent + '        color: _selectedSongIds.contains(song.id) ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,\n' + \
               indent + '        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),\n' + \
               indent + '        child: Row('
    slidable_code = animated_container_re.sub(repl, slidable_code)
    
    # 3c. Close LayoutBuilder correctly by inserting it before `), // end of InkWell` which is before `, childCount:`
    # Wait, Slidable structure: Slidable ( ... child: InkWell( ... child: LayoutBuilder( ... ) ) )
    # Let's just find the end of the popup menu and close LayoutBuilder
    popup_menu_re = re.compile(r'                                            \),\n                                          \],\n                                        \),\n                                      \),\n                                    \),', re.DOTALL)
    slidable_code = popup_menu_re.sub(r'''                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ); // end SizedBox
                                }, // end builder
                              ), // end LayoutBuilder
                                    ),''', slidable_code)
    
    # 3d. Remove song_info popup items
    song_info_re = re.compile(r"                                                  } else if \(value == 'song_info'\) \{.*?                                                  \}", re.DOTALL)
    slidable_code = song_info_re.sub('                                                  }', slidable_code)
    song_info_item_re = re.compile(r"                                                    const PopupMenuItem\(\n                                                      value: 'song_info'.*?                                                    \),", re.DOTALL)
    slidable_code = song_info_item_re.sub('', slidable_code)
    
    # 3e. Wrap the whole Slidable in Builder and CupertinoContextMenu if iOS
    # Replace `return Slidable(` with `Widget listItem = Slidable(`
    slidable_code = slidable_code.replace(match.group(1) + 'Slidable(', match.group(1) + 'Builder(builder: (context) { Widget listItem = Slidable(')
    
    # At the end of the match (which ends with `\n( *) childCount:`), insert the return logic
    end_of_slidable = match.group(2) + '  childCount:'
    replacement_end = '''
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
                                  });
                                },
''' + end_of_slidable
    
    # We must remove the existing `                                },\n                                childCount:` because we just rewrote it
    slidable_code = slidable_code.rsplit('                                },\n', 1)[0] + replacement_end
    
    code = code[:match.start()] + slidable_code + code[match.end():]

with open('lib/features/library/presentation/pages/all_tracks_page.dart', 'w') as f:
    f.write(code)

