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
          FocusScope.of(context).nextFocus();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          FocusScope.of(context).previousFocus();
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
            SizedBox(height: 12.h), // Top padding for AppBar
            // Search Bar Area
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: FocusableCard(
                onTap: () {},
                scale: 1.02,
                child: TextField(
                  focusNode: _searchFocusNode,
                  controller: _controller,
                  autofocus: true,
                  onChanged: _performSearch,
                  style: Get.textTheme.titleLarge,
                  decoration: InputDecoration(
                    hintText: "Search Movies, Series, Channels...",
                    prefixIcon: const Icon(Icons.search, size: 30),
                    filled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
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
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    children: [
                      _buildTab(0, "All"),
                      const SizedBox(width: 15),
                      _buildTab(1, "Live TV (${_liveResults.length})"),
                      const SizedBox(width: 15),
                      _buildTab(2, "Movies (${_movieResults.length})"),
                      const SizedBox(width: 15),
                      _buildTab(3, "Series (${_seriesResults.length})"),
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

  Widget _buildTab(int index, String label) {
    bool isSelected = _tabController.index == index;
    return FocusableCard(
      onTap: () => _tabController.animateTo(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kColorPrimary : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_liveResults.isNotEmpty) ...[
            _sectionTitle("Live TV"),
            _horizontalList(_liveResults, (e) => _onLiveTap(e)),
          ],
          if (_movieResults.isNotEmpty) ...[
            _sectionTitle("Movies"),
            _horizontalList(_movieResults, (e) => _onMovieTap(e)),
          ],
          if (_seriesResults.isNotEmpty) ...[
            _sectionTitle("Series"),
            _horizontalList(_seriesResults, (e) => _onSeriesTap(e)),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Get.textTheme.titleMedium
            ?.copyWith(color: kColorPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _horizontalList<T>(List<T> items, Function(T) onTap) {
    return SizedBox(
      height: 180,
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
            child: SizedBox(
              width: 120,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(icon),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        ),
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
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
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(icon),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
                    color: Colors.black45,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
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
    if (user != null) {
      final url =
          "${user.serverInfo!.serverUrl}/live/${user.userInfo!.username}/${user.userInfo!.password}/$streamId.ts";
      Get.to(() => MediaKitPlayerScreen(
            title: name,
            link: url,
            isLive: true,
          ));
    }
  }
}
