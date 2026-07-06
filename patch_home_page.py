import re

with open('lib/features/home/presentation/pages/home_page.dart', 'r') as f:
    content = f.read()

# Add Scaffold.appBar
old_scaffold_start = """    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FrostedBackground("""
      
new_scaffold_start = """    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'LISER',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 32,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
        toolbarHeight: 80,
        actions: [
          BlocBuilder<AppBloc, AppState>(
            builder: (context, appState) {
              final photoPath = appState.settings?.userPhotoPath;
              return GestureDetector(
                onTap: () => context.push('/profile'),
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: ProfilePictureWidget(photoPath: photoPath, size: 40),
                ),
              );
            },
          ),
        ],
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

# Remove the two SliverAppBars
old_sliver_appbars = """                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    toolbarHeight: 80,
                    flexibleSpace: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(color: Colors.black.withValues(alpha: 0.1)),
                      ),
                    ),
                    title: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'LISER',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    actions: [
                      BlocBuilder<AppBloc, AppState>(
                        builder: (context, appState) {
                          final photoPath = appState.settings?.userPhotoPath;
                          return GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24),
                              child: ProfilePictureWidget(photoPath: photoPath, size: 40),
                            ),
                          );
                        },
                      ),
                    ],
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

content = content.replace("CustomScrollView(\n                slivers: [", "Column(\n                children: [")
content = content.replace("SliverFillRemaining(", "Expanded(")
content = content.replace("SliverPadding(\n                        padding: const EdgeInsets.only(bottom: 150),\n                        sliver: SliverList(", "Expanded(\n                        child: ListView.builder(\n                          padding: const EdgeInsets.only(bottom: 150),")
content = content.replace("delegate: SliverChildBuilderDelegate(", "itemBuilder: (context, index) {")
content = content.replace("childCount: filteredSongs.isEmpty ? 0 : filteredSongs.length * 2 - 1,\n                          ),", "itemCount: filteredSongs.isEmpty ? 0 : filteredSongs.length * 2 - 1,\n                        ),")
content = content.replace("sliver: SliverList.list(\n                        children: [", "child: ListView(\n                          padding: const EdgeInsets.only(bottom: 150),\n                          children: [")

with open('lib/features/home/presentation/pages/home_page.dart', 'w') as f:
    f.write(content)
