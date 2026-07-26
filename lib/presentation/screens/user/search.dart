part of '../screens.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late FocusNode _searchFocusNode;
  String _query = "";
  bool _isLoading = false;

  // Data
  List<ChannelLive> _allLive = [];
  List<ChannelMovie> _allMovies = [];
  List<ChannelSerie> _allSeries = [];

  // Filtered
  List<ChannelLive> _liveResults = [];
  List<ChannelMovie> _movieResults = [];
  List<ChannelSerie> _seriesResults = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          FocusScope.of(context).focusInDirection(TraversalDirection.right);
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    });

    _tabController = TabController(length: 4, vsync: this);
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    final api = IpTvApi();
    try {
      // Parallel fetch
      final results = await Future.wait([
        api.getLiveChannels(null),
        api.getMovieChannels(null),
        api.getSeriesChannels(null),
      ]);

      if (mounted) {
        setState(() {
          _allLive = results[0] as List<ChannelLive>;
          _allMovies = results[1] as List<ChannelMovie>;
          _allSeries = results[2] as List<ChannelSerie>;
          _isLoading = false;
        });
        _performSearch(_controller.text);
      }
    } catch (e) {
      debugPrint("Search Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _liveResults = [];
        _movieResults = [];
        _seriesResults = [];
        _query = "";
      });
      return;
    }

    final lower = query.toLowerCase();
    setState(() {
      _query = query;
      _liveResults = _allLive
          .where((e) => (e.name?.toLowerCase().contains(lower) ?? false))
          .toList();
      _movieResults = _allMovies
          .where((e) => (e.name?.toLowerCase().contains(lower) ?? false))
          .toList();
      _seriesResults = _allSeries
          .where((e) => (e.name?.toLowerCase().contains(lower) ?? false))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _SearchSizes.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("Global Search"),
      ),
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Column(
          children: [
            SizedBox(
              height: 12.h + 30,
            ),
            // Top padding for AppBar + bottom margin
            // Search Bar Area
            Container(
              width: sizes.searchBarMaxWidth,
              padding: EdgeInsets.symmetric(horizontal: sizes.searchPadding),
              child: FocusableCard(
                onTap: () {},
                scale: 1.02,
                showFocusBorder:
                    false, // We'll handle borders differently or keep it clean
                builder: (context, isFocused) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isFocused ? Colors.white : Colors.white24,
                      width: isFocused ? 2 : 1,
                    ),
                    boxShadow: isFocused
                        ? [
                            BoxShadow(
                              color: const Color(0xFF265eb4)
                                  .withValues(alpha: 0.6),
                              blurRadius: 0,
                              spreadRadius: 0,
                            )
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TvTextField(
                        focusNode: _searchFocusNode,
                        controller: _controller,
                        autofocus: true,
                        onChanged: _performSearch,
                        style: Get.textTheme.titleLarge?.copyWith(
                            fontSize: sizes.searchFontSize,
                            color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search Movies, Series, Channels...",
                          hintStyle: TextStyle(
                              color: Colors.white54,
                              fontSize: sizes.searchFontSize),
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 8.0),
                            child: Icon(Icons.search,
                                size: sizes.searchIconSize,
                                color: Colors.white70),
                          ),
                          filled: false,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: sizes.searchPadding,
                            horizontal: sizes.searchPadding,
                          ),
                          suffixIcon: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tabs
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                return SizedBox(
                  height: sizes.tabHeight,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        EdgeInsets.symmetric(horizontal: sizes.searchPadding),
                    children: [
                      _buildTab(0, "All", sizes),
                      const SizedBox(width: 15),
                      _buildTab(1, "Live TV (${_liveResults.length})", sizes),
                      const SizedBox(width: 15),
                      _buildTab(2, "Movies (${_movieResults.length})", sizes),
                      const SizedBox(width: 15),
                      _buildTab(3, "Series (${_seriesResults.length})", sizes),
                    ],
                  ),
                );
              },
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllView(),
                  _buildLiveList(),
                  _buildMovieList(),
                  _buildSeriesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, _SearchSizes sizes) {
    bool isSelected = _tabController.index == index;
    return FocusableCard(
      onTap: () => _tabController.animateTo(index),
      scale: 1.05,
      showFocusBorder: false,
      builder: (context, isFocused) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: sizes.tabPaddingH, vertical: sizes.tabPaddingV),
        decoration: BoxDecoration(
          gradient: isSelected || isFocused
              ? const LinearGradient(
                  colors: [
                    Color(0xFF265eb4),
                    Color(0xFF1b222c),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )
              : null,
          color: isSelected || isFocused
              ? null
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isFocused ? Colors.white : Colors.transparent,
            width: isFocused ? 2 : 0,
          ),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: const Color(0xFF265eb4).withValues(alpha: 0.6),
                    blurRadius: 15,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: sizes.tabFontSize,
          ),
        ),
      ),
    );
  }

  Widget _buildAllView() {
    if (_query.isEmpty) {
      return Center(
          child: Text("Type to search...", style: Get.textTheme.titleLarge));
    }
    final sizes = _SearchSizes.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(sizes.searchPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_liveResults.isNotEmpty) ...[
            _sectionTitle("Live TV", sizes),
            _horizontalList(_liveResults, (e) => _onLiveTap(e), sizes),
          ],
          if (_movieResults.isNotEmpty) ...[
            _sectionTitle("Movies", sizes),
            _horizontalList(_movieResults, (e) => _onMovieTap(e), sizes),
          ],
          if (_seriesResults.isNotEmpty) ...[
            _sectionTitle("Series", sizes),
            _horizontalList(_seriesResults, (e) => _onSeriesTap(e), sizes),
          ],
          if (_liveResults.isEmpty &&
              _movieResults.isEmpty &&
              _seriesResults.isEmpty)
            Center(
                child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Text("No results found", style: Get.textTheme.titleMedium),
            )),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, _SearchSizes sizes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Get.textTheme.titleMedium?.copyWith(
            color: kColorPrimary,
            fontWeight: FontWeight.bold,
            fontSize: sizes.sectionTitleFont),
      ),
    );
  }

  Widget _horizontalList<T>(
      List<T> items, Function(T) onTap, _SearchSizes sizes) {
    return SizedBox(
      height: sizes.horizontalListHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          String name = "";
          String icon = "";
          if (item is ChannelLive) {
            name = item.name ?? "";
            icon = item.streamIcon ?? "";
          } else if (item is ChannelMovie) {
            name = item.name ?? "";
            icon = item.streamIcon ?? "";
          } else if (item is ChannelSerie) {
            name = item.name ?? "";
            icon = item.cover ?? "";
          }

          return FocusableCard(
            onTap: () => onTap(item),
            scale: 1.05,
            showFocusBorder: false,
            builder: (context, isFocused) => Container(
              width: sizes.horizontalCardWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFocused ? Colors.white : Colors.transparent,
                  width: isFocused ? 2 : 0,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: const Color(0xFF265eb4).withValues(alpha: 0.6),
                          blurRadius: 15,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
                image: DecorationImage(
                  image: CachedNetworkImageProvider(icon),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
                color: Colors.black45,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: [0.0, 0.5],
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: sizes.cardTitleFont,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveList() => _gridList(_liveResults, _onLiveTap);
  Widget _buildMovieList() => _gridList(_movieResults, _onMovieTap);
  Widget _buildSeriesList() => _gridList(_seriesResults, _onSeriesTap);

  Widget _gridList<T>(List<T> items, Function(T) onTap) {
    if (items.isEmpty) return const Center(child: Text("No results"));
    final sizes = _SearchSizes.of(context);
    return GridView.builder(
      padding: EdgeInsets.all(sizes.searchPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: sizes.gridCrossAxisCount,
        childAspectRatio: sizes.gridChildAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        String name = "";
        String icon = "";
        if (item is ChannelLive) {
          name = item.name ?? "";
          icon = item.streamIcon ?? "";
        } else if (item is ChannelMovie) {
          name = item.name ?? "";
          icon = item.streamIcon ?? "";
        } else if (item is ChannelSerie) {
          name = item.name ?? "";
          icon = item.cover ?? "";
        }
        return FocusableCard(
          onTap: () => onTap(item),
          scale: 1.05,
          showFocusBorder: false,
          builder: (context, isFocused) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused ? Colors.white : Colors.transparent,
                width: isFocused ? 2 : 0,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: const Color(0xFF265eb4).withValues(alpha: 0.6),
                        blurRadius: 15,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
              image: DecorationImage(
                image: CachedNetworkImageProvider(icon),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
              color: Colors.black45,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.5],
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: sizes.cardTitleFont,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onLiveTap(ChannelLive channel) {
    // Navigate to player with single channel context?
    // MediaKitPlayerScreen usually takes a link.
    // We can use helper or just construct url.
    // Or simpler: Navigate to LiveCategoriesScreen but that's complex to pre-select.
    // Let's open player directly.
    _openPlayer(
        channel.streamId.toString(), channel.name ?? "", "live", channel);
  }

  void _onMovieTap(ChannelMovie movie) {
    Get.toNamed(screenMovieDetails, arguments: movie);
  }

  void _onSeriesTap(ChannelSerie serie) {
    Get.toNamed(screenSeriesDetails, arguments: serie);
  }

  void _openPlayer(
      String streamId, String name, String type, ChannelLive channel) async {
    final user = await LocaleApi.getUser();
    if (user == null) return;

    // Build URL respecting the user-preferred stream format
    final format = GetStorage().read('stream_format') ?? 'default';
    final base =
        "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/$streamId";
    final url = format == 'default' ? base : "$base.$format";

    ExternalPlayerService.play(
      context: context,
      url: url,
      title: name,
      openBuiltIn: () {
        Get.to(() => MediaKitPlayerScreen(
              title: name,
              link: url,
              isLive: true,
              channel: channel,
            ));
      },
    );
  }
}

/// Responsive size tokens for the Search screen across all device classes.
class _SearchSizes {
  final double searchIconSize;
  final double searchFontSize;
  final double searchPadding;
  final double tabHeight;
  final double tabFontSize;
  final double tabPaddingH;
  final double tabPaddingV;
  final double searchBarMaxWidth;
  final int gridCrossAxisCount;
  final double gridChildAspectRatio;
  final double horizontalListHeight;
  final double horizontalCardWidth;
  final double cardTitleFont;
  final double sectionTitleFont;

  const _SearchSizes({
    required this.searchIconSize,
    required this.searchFontSize,
    required this.searchPadding,
    required this.tabHeight,
    required this.tabFontSize,
    required this.tabPaddingH,
    required this.tabPaddingV,
    required this.searchBarMaxWidth,
    required this.gridCrossAxisCount,
    required this.gridChildAspectRatio,
    required this.horizontalListHeight,
    required this.horizontalCardWidth,
    required this.cardTitleFont,
    required this.sectionTitleFont,
  });

  factory _SearchSizes.of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTvDevice = isTv(context);

    // --- Small phone (< 360) ---
    if (width < 360) {
      return const _SearchSizes(
        searchIconSize: 20.0,
        searchFontSize: 14.0,
        searchPadding: 12.0,
        tabHeight: 40.0,
        tabFontSize: 12.0,
        tabPaddingH: 16.0,
        tabPaddingV: 6.0,
        searchBarMaxWidth: double.infinity,
        gridCrossAxisCount: 2,
        gridChildAspectRatio: 0.65,
        horizontalListHeight: 140.0,
        horizontalCardWidth: 90.0,
        cardTitleFont: 10.0,
        sectionTitleFont: 14.0,
      );
    }
    // --- Standard phone (360 - 599) ---
    if (width < 600) {
      return const _SearchSizes(
        searchIconSize: 24.0,
        searchFontSize: 16.0,
        searchPadding: 16.0,
        tabHeight: 45.0,
        tabFontSize: 14.0,
        tabPaddingH: 24.0,
        tabPaddingV: 8.0,
        searchBarMaxWidth: double.infinity,
        gridCrossAxisCount: 3,
        gridChildAspectRatio: 0.65,
        horizontalListHeight: 160.0,
        horizontalCardWidth: 100.0,
        cardTitleFont: 11.0,
        sectionTitleFont: 16.0,
      );
    }
    // --- Tablet portrait (600 - 899) ---
    if (width < 900) {
      return const _SearchSizes(
        searchIconSize: 25.0,
        searchFontSize: 16.0,
        searchPadding: 18.0,
        tabHeight: 50.0,
        tabFontSize: 16.0,
        tabPaddingH: 32.0,
        tabPaddingV: 10.0,
        searchBarMaxWidth: 700,
        gridCrossAxisCount: 4,
        gridChildAspectRatio: 0.7,
        horizontalListHeight: 180.0,
        horizontalCardWidth: 120.0,
        cardTitleFont: 12.0,
        sectionTitleFont: 18.0,
      );
    }
    // --- Tablet landscape / small desktop (900 - 1279) ---
    if (width < 1280) {
      return const _SearchSizes(
        searchIconSize: 32.0,
        searchFontSize: 22.0,
        searchPadding: 20.0,
        tabHeight: 55.0,
        tabFontSize: 18.0,
        tabPaddingH: 40.0,
        tabPaddingV: 12.0,
        searchBarMaxWidth: 700.0,
        gridCrossAxisCount: 5,
        gridChildAspectRatio: 0.75,
        horizontalListHeight: 200.0,
        horizontalCardWidth: 140.0,
        cardTitleFont: 14.0,
        sectionTitleFont: 22.0,
      );
    }
    // --- TV / large desktop (>= 1280) ---
    return _SearchSizes(
      searchIconSize: 36.0,
      searchFontSize: 26.0,
      searchPadding: 24.0,
      tabHeight: 60.0,
      tabFontSize: 20.0,
      tabPaddingH: 50.0,
      tabPaddingV: 14.0,
      searchBarMaxWidth: 900.0,
      gridCrossAxisCount: isTvDevice ? 7 : 6,
      gridChildAspectRatio: 0.75,
      horizontalListHeight: 240.0,
      horizontalCardWidth: 160.0,
      cardTitleFont: 16.0,
      sectionTitleFont: 26.0,
    );
  }
}
