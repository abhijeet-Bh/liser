import re

with open('lib/features/library/presentation/pages/all_tracks_page.dart', 'r') as f:
    content = f.read()

# We need to add the Scaffold.appBar back and remove the SliverAppBars
app_bar_code = """
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
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CupertinoSearchTextField(
              placeholder: 'Search songs or artists...',
              style: const TextStyle(color: Colors.white),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              itemColor: Colors.white54,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              onChanged: (value) {
                // This is inside a StatefulWidget but we don't have access to setState inside the appBar builder directly... wait we do, it's just in the build method.
              },
            ),
          ),
        ),
      ),
"""

# Actually, doing this with a python script might be slightly messy because of `setState(() { _searchQuery = value; })`. Let's do it cleanly by replacing `extendBodyBehindAppBar: true,\n      body: FrostedBackground(` with the AppBar.

old_scaffold_start = """    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FrostedBackground("""
      
new_scaffold_start = """    return Scaffold(
      extendBodyBehindAppBar: true,
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: CupertinoSearchTextField(
              placeholder: 'Search songs or artists...',
              style: const TextStyle(color: Colors.white),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              itemColor: Colors.white54,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: FrostedBackground("""

content = content.replace(old_scaffold_start, new_scaffold_start)

# Now remove the two SliverAppBars from CustomScrollView
old_sliver_appbars = """                        SliverAppBar(
                          pinned: true,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          centerTitle: true,
                          flexibleSpace: ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(color: Colors.black.withValues(alpha: 0.1)),
                            ),
                          ),
                          title: Column(
                            children: [
                              Text(widget.artistFilter ?? 'All Tracks', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                              if (filteredSongs.isNotEmpty)
                                Text(
                                  '${filteredSongs.length} Tracks',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SliverAppBar(
                          floating: true,
                          snap: true,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          automaticallyImplyLeading: false,
                          titleSpacing: 16,
                          toolbarHeight: 52,
                          title: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: CupertinoSearchTextField(
                                placeholder: 'Search songs or artists...',
                                style: const TextStyle(color: Colors.white),
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                itemColor: Colors.white54,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),"""

content = content.replace(old_sliver_appbars, "")

# And we should also replace CustomScrollView with a Column + Expanded > ListView? Or just keep CustomScrollView and SliverList since we don't have slivers anymore, but CustomScrollView needs to just have SliverList. That's fine! CustomScrollView works perfectly fine with just a SliverList, or we can use ListView. Let's just leave it as CustomScrollView with the remaining Slivers, but add `padding: const EdgeInsets.only(top: 16)` or something.
# Wait, if we use Scaffold.appBar, the body will go behind it. We should add top padding to the SliverList or CustomScrollView padding. Wait, CustomScrollView doesn't have padding, SliverPadding does. It's already there!

# Actually, the user had an issue with CustomScrollView > Expanded before. If we change it to Column + Expanded > ListView, it might be cleaner. Let's just use ListView!
content = content.replace("CustomScrollView(\n                      slivers: [", "Column(\n                      children: [")

# Wait, `SliverFillRemaining` needs to be removed
content = content.replace("SliverFillRemaining(", "Expanded(")
content = content.replace("SliverPadding(\n                            padding: const EdgeInsets.only(top: 8, bottom: 150),\n                            sliver: SliverList(", "Expanded(\n                            child: ListView.builder(\n                              padding: const EdgeInsets.only(top: 8, bottom: 150),")
content = content.replace("delegate: SliverChildBuilderDelegate(", "itemBuilder: (context, index) {")
content = content.replace("childCount: filteredSongs.isEmpty ? 0 : filteredSongs.length * 2 - 1,\n                              ),", "itemCount: filteredSongs.isEmpty ? 0 : filteredSongs.length * 2 - 1,\n                            ),")

# Wait, the `itemBuilder` function replacement:
# old: delegate: SliverChildBuilderDelegate(\n                                (context, index) {
# new: itemBuilder: (context, index) {
# It works, but the closing parenthesis for `SliverChildBuilderDelegate` is at `childCount: ... ),`. Let's just use regex.

# We will just write a python script to reconstruct the file. 

with open('lib/features/library/presentation/pages/all_tracks_page.dart', 'w') as f:
    f.write(content)
