// This screen is part of a larger screens library defined in screens.dart
part of '../screens.dart';

// Import EpgTimelineScreen (assuming it's exported in screens.dart or defined locally)
// If not exported, I need to add import. Since this is a part file, I cannot add imports here.
// I must add import to `lib/presentation/screens.dart`.
// BUT `screens.dart` is the library.
// Let's assume `EpgTimelineScreen` is NOT part of `screens.dart` yet.
// Wait, `LiveTvScreen` is `part of '../screens.dart'`.
// So I should modify `lib/presentation/screens.dart` to include `epg_timeline.dart` or export it.

// Check `screens.dart` content first.

/// LiveTvScreen is the main entry point for the Live TV section of the app.
/// It supports being used as a picker (e.g., when selecting a channel for a dashboard).
class LiveTvScreen extends StatefulWidget {
  final bool
      isPicker; // If true, tapping a channel returns it instead of playing
  const LiveTvScreen({super.key, this.isPicker = false});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  // State variables for selected category and channel
  CategoryModel? _selectedCategory;
  ChannelLive? _selectedChannel;

  // Future for EPG results to use with FutureBuilder
  Future<List<EpgModel>>? _epgFuture;

  // Search state management
  final _searchController = TextEditingController();
  late FocusNode _searchFocusNode;
  String _searchQuery = "";

  // Video playback controller (using media_kit)
  late final Player _previewPlayer;
  late final VideoController _previewVideoController;

  /// Utility to decode base64 encoded text (common in some IPTV EPG data)
  String _decodeText(String? text) {
    if (text == null || text.isEmpty) return "";
    try {
      // Attempt to decode as base64 and then utf8
      return utf8.decode(base64.decode(text));
    } catch (e) {
      // If fails (not base64), return original text
      return text;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize focus node with keyboard navigation handling (important for Android TV)
    _searchFocusNode = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        // Handle D-Pad down
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          FocusScope.of(context).nextFocus();
          return KeyEventResult.handled;
        }
        // Handle D-Pad up
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          FocusScope.of(context).previousFocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    });

    // Ensure media_kit is ready
    MediaKit.ensureInitialized();

    // Setup the preview player and its controller
    _previewPlayer = Player();
    _previewVideoController = VideoController(_previewPlayer);

    // Initial category selection logic
    final catState = context.read<LiveCatyBloc>().state;
    if (catState is LiveCatySuccess && catState.categories.isNotEmpty) {
      // Find the first category that is not restricted by parental controls
      final firstSafe = catState.categories.firstWhere(
        (c) => !_isRestricted(c),
        orElse: () => catState.categories.first,
      );

      // Select it automatically if it's safe to view
      if (!_isRestricted(firstSafe)) {
        _selectCategory(firstSafe);
      }
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _previewPlayer.dispose();
    super.dispose();
  }

  /// Starts playback for a specific channel in the preview window
  Future<void> _initializePlayer(ChannelLive channel) async {
    // Get user credentials to construct the stream URL
    final user = await LocaleApi.getUser();
    if (user == null || channel.streamId == null) return;

    // Construct the stream URL using server URL, username, password, and stream ID
    final url =
        "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/${channel.streamId}";

    // Open the media in the preview player
    await _previewPlayer.open(
      Media(url),
      play: true,
    );
  }

  /// Updates the UI when a category is selected and fetches its channels
  void _selectCategory(CategoryModel category) {
    setState(() {
      _selectedCategory = category;
    });
    // Trigger the ChannelsBloc to load live channels for this category
    context
        .read<ChannelsBloc>()
        .add(GetChannels(category.categoryId!, TypeCategory.live));
  }

  /// Checks if a name contains keywords that should trigger parental controls
  bool _isRestrictedName(String? name) {
    if (name == null) return false;
    final lower = name.toLowerCase();
    return lower.contains("adult") ||
        lower.contains("porn") ||
        lower.contains("xxx") ||
        lower.contains("18+") ||
        lower.contains("sex") ||
        lower.contains("xx ");
  }

  /// Checks if a category is restricted AND if parental control is currently ACTIVE for this user
  bool _isRestricted(CategoryModel category) {
    if (!_isRestrictedName(category.categoryName)) return false;

    // Parental control setting is stored per-user in GetStorage
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return true;
    final userId = authState.user.id;
    final storage = GetStorage("settings");
    final enabled = storage.read("parental_control_enabled_$userId") ?? true;
    return enabled;
  }

  /// Middleware to check channel access. If a channel is restricted, it prompts for a PIN.
  void _checkChannelAccess(ChannelLive channel, VoidCallback onAllowed) {
    // If the channel name doesn't contain restricted keywords, allow access
    if (!_isRestrictedName(channel.name)) {
      onAllowed();
      return;
    }

    // Check if parental controls are enabled for the current user
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;
    final userId = authState.user.id;
    final storage = GetStorage("settings");
    final enabled = storage.read("parental_control_enabled_$userId") ?? true;

    // If setting is disabled, allow access even if name is suspicious
    if (!enabled) {
      onAllowed();
      return;
    }

    // Show parental control PIN verification dialog
    Get.dialog(
      ParentalControlWidget(
        userId: userId,
        mode: ParentalMode.verify,
        onVerifySuccess: onAllowed,
      ),
    );
  }

  /// Middleware to check category access. If a category is restricted, it prompts for a PIN.
  void _checkParentalControl(CategoryModel category, VoidCallback onAllowed) {
    if (_isRestricted(category)) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthSuccess) return;
      Get.dialog(
        ParentalControlWidget(
          userId: authState.user.id,
          mode: ParentalMode.verify,
          onVerifySuccess: onAllowed,
        ),
      );
    } else {
      onAllowed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground, // Global background decoration
        child: Column(
          children: [
            // Top Navigation & Search Bar
            AppBarLive(
              // Update category filter when searching via the AppBar
              onSearch: (val) => setState(() => _searchQuery = val),

              // Handle EPG Timeline navigation
              onTimeline: () async {
                final channels = context.read<ChannelsBloc>().state
                        is ChannelsSuccess
                    ? (context.read<ChannelsBloc>().state as ChannelsSuccess)
                        .channels
                        .cast<ChannelLive>()
                    : <ChannelLive>[];

                if (channels.isNotEmpty) {
                  await _previewPlayer
                      .stop(); // Stop background playback before moving to timeline

                  // Navigate to the EPG Timeline Screen
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EpgTimelineScreen(
                                channels: channels,
                                initialChannelId: _selectedChannel?.streamId ??
                                    channels.first.streamId.toString(),
                              )));

                  // Resume playback if we had a selected channel when we return
                  if (_selectedChannel != null) {
                    _initializePlayer(_selectedChannel!);
                  }
                } else {
                  // Show snackbar if no channels are available to display in timeline
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("No channels available for timeline")));
                }
              },
            ),

            // Main Content Area using a Tri-Pane layout (Categories | Channels | Preview/Info)
            Expanded(
              child: Row(
                children: [
                  // PANE 1: CATEGORIES (Flex 3)
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: kColorPanel,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 1.h, 16, 2.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Inline Search Bar for categories
                                Container(
                                  height: 40,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    focusNode: _searchFocusNode,
                                    controller: _searchController,
                                    onChanged: (val) =>
                                        setState(() => _searchQuery = val),
                                    decoration: const InputDecoration(
                                      hintText: "Search in categories",
                                      prefixIcon: Icon(Icons.search, size: 18),
                                      border: InputBorder.none,
                                      filled: false,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: BlocBuilder<LiveCatyBloc, LiveCatyState>(
                              builder: (context, state) {
                                if (state is LiveCatyLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (state is LiveCatySuccess) {
                                  // Filter categories based on search query
                                  final filtered = state.categories
                                      .where((e) =>
                                          e.categoryName
                                              ?.toLowerCase()
                                              .contains(
                                                  _searchQuery.toLowerCase()) ??
                                          true)
                                      .toList();

                                  // Auto-select the first category if none is currently selected
                                  if (_selectedCategory == null &&
                                      filtered.isNotEmpty) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _selectCategory(filtered.first);
                                    });
                                  }

                                  return ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final cat = filtered[index];
                                      final isSelected =
                                          _selectedCategory?.categoryId ==
                                              cat.categoryId;

                                      return FocusableCard(
                                        onTap: () {
                                          // Check parental controls before switching categories
                                          _checkParentalControl(cat, () {
                                            _selectCategory(cat);
                                          });
                                        },
                                        scale: 1.02,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? kColorPrimary
                                                : Colors.transparent,
                                            border: isSelected
                                                ? null
                                                : const Border(
                                                    bottom: BorderSide(
                                                        color: Colors.white10)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  cat.categoryName ?? "Unknown",
                                                  style: Get
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : kColorTextSecondary,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else if (state is LiveCatyFailed) {
                                  return Center(child: Text(state.message));
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // PANE 2: CHANNELS (Flex 4)
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: kColorPanel,
                      child: Column(
                        children: [
                          // Header showing the currently selected category name
                          Container(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.centerLeft,
                            color: kColorCardDark,
                            child: Text(
                              _selectedCategory?.categoryName ??
                                  "Select Category",
                              style: Get.textTheme.titleMedium?.copyWith(
                                  color: kColorPrimary,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Channel List Content
                          Expanded(
                            child: BlocBuilder<ChannelsBloc, ChannelsState>(
                              builder: (context, state) {
                                if (_selectedCategory == null) {
                                  return const Center(
                                      child: Text("Select a category"));
                                }

                                if (state is ChannelsLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (state is ChannelsSuccess) {
                                  final channels =
                                      state.channels.cast<ChannelLive>();

                                  if (channels.isEmpty) {
                                    return const Center(
                                        child: Text("No channels"));
                                  }

                                  // Favorites management using FavoritesCubit
                                  return BlocBuilder<FavoritesCubit,
                                      FavoritesState>(
                                    builder: (context, favState) {
                                      // Create a set of favorite stream IDs for efficient lookup
                                      final favoriteIds =
                                          favState is FavoritesSuccess
                                              ? favState.live
                                                  .map((c) => c.streamId)
                                                  .toSet()
                                              : <String?>{};
                                      return ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: channels.length,
                                        itemBuilder: (context, index) {
                                          final channel = channels[index];
                                          final isFav = favoriteIds
                                              .contains(channel.streamId);
                                          return ListChannelItem(
                                            title: channel.name ??
                                                "Channel ${channel.num}",
                                            icon: channel.streamIcon,
                                            epg: "No Program Info",
                                            isFocus:
                                                _selectedChannel?.streamId ==
                                                    channel.streamId,
                                            isFavorite: isFav,
                                            // Handle favorite toggling
                                            onFavoriteToggle: () {
                                              if (isFav) {
                                                context
                                                    .read<FavoritesCubit>()
                                                    .removeLive(
                                                        channel.streamId ?? "");
                                              } else {
                                                context
                                                    .read<FavoritesCubit>()
                                                    .addLive(channel);
                                              }
                                            },
                                            // Handle channel selection
                                            onTap: () {
                                              _checkChannelAccess(channel, () {
                                                // If in picker mode, return the channel result and close
                                                if (widget.isPicker) {
                                                  Get.back(result: channel);
                                                  return;
                                                }
                                                // Update state and load EPG for the selected channel
                                                setState(() {
                                                  _selectedChannel = channel;
                                                  if (channel.streamId !=
                                                      null) {
                                                    _epgFuture = IpTvApi
                                                        .getEPGbyStreamId(
                                                            channel.streamId!);
                                                    _initializePlayer(channel);
                                                  } else {
                                                    _epgFuture = null;
                                                  }
                                                });
                                              });
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                } else if (state is ChannelsFailed) {
                                  return Center(child: Text(state.message));
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // PANE 3: PREVIEW & EPG (Flex 5)
                  Expanded(
                    flex: 5,
                    child: Container(
                      color:
                          Colors.black, // Dark background for the preview area
                      child: Column(
                        children: [
                          // MINI PLAYER AREA (Top section of the third pane)
                          FocusableCard(
                            onTap: () {
                              // If a channel is selected, verify access and open a full-screen player
                              if (_selectedChannel != null) {
                                _checkChannelAccess(_selectedChannel!,
                                    () async {
                                  final user = await LocaleApi.getUser();
                                  if (user != null) {
                                    // Use the user-preferred stream format (defaults to .ts)
                                    final format =
                                        GetStorage().read('stream_format') ??
                                            'ts';
                                    final link =
                                        "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/${_selectedChannel!.streamId}.$format";

                                    // Navigate to the dedicated player screen
                                    Get.to(() => MediaKitPlayerScreen(
                                          title: _selectedChannel!.name ??
                                              "Live TV",
                                          link: link,
                                          isLive: true,
                                          player: _previewPlayer,
                                          videoController:
                                              _previewVideoController,
                                        ));
                                  }
                                });
                              }
                            },
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Render the video if a channel is selected
                                    if (_selectedChannel != null)
                                      Video(
                                        controller: _previewVideoController,
                                        fit: BoxFit.cover,
                                        controls:
                                            NoVideoControls, // No controls in preview mode
                                      )
                                    else ...[
                                      // If no channel is selected, show a dimmed channel icon or placeholder
                                      if (_selectedChannel?.streamIcon !=
                                              null &&
                                          _selectedChannel!
                                              .streamIcon!.isNotEmpty)
                                        SizedBox.expand(
                                          child: Opacity(
                                            opacity: 0.3,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  _selectedChannel!.streamIcon!,
                                              fit: BoxFit.cover,
                                              errorWidget: (_, __, ___) =>
                                                  const Center(
                                                      child: Icon(Icons.tv,
                                                          size: 48,
                                                          color:
                                                              Colors.white24)),
                                            ),
                                          ),
                                        ),
                                      // Overlay buttons for selection when no video is playing
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (widget.isPicker)
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                if (_selectedChannel != null) {
                                                  Get.back(
                                                      result: _selectedChannel);
                                                }
                                              },
                                              icon: const Icon(Icons.check,
                                                  color: Colors.white),
                                              label: Text("Select Channel",
                                                  style: GoogleFonts.outfit(
                                                      color: Colors.white)),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      kColorPrimary),
                                            )
                                          else
                                            const Icon(Icons.play_circle_fill,
                                                size: 64,
                                                color: Colors.white54),
                                          const SizedBox(height: 8),
                                          const Text("Preview",
                                              style: TextStyle(
                                                  color: Colors.white54)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Channel Info & EPG (Bottom)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              color: kColorBackground,
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Channel Header (Name, Icon, and Type)
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              _selectedChannel?.streamIcon ??
                                                  "",
                                          errorWidget: (_, __, ___) =>
                                              const Icon(Icons.tv,
                                                  size: 30,
                                                  color: Colors.white24),
                                          placeholder: (_, __) => const Center(
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2)),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedChannel?.name ??
                                                  "Select a Channel",
                                              style: Get.textTheme.titleLarge
                                                  ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Live Stream",
                                              style: Get.textTheme.bodyMedium
                                                  ?.copyWith(
                                                      color: kColorPrimary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // EPG Section Header with Catch-up shortcut
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "EPG (Electronic Program Guide)",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      // Only show "View All Catch-up" if the channel supports archiving
                                      if (_selectedChannel != null &&
                                          _selectedChannel!.tvArchive == 1)
                                        TextButton.icon(
                                          icon: const Icon(Icons.history,
                                              color: kColorPrimary, size: 18),
                                          label: const Text("View All Catch-up",
                                              style: TextStyle(
                                                  color: kColorPrimary)),
                                          onPressed: () {
                                            Get.to(() => CatchUpScreen(
                                                channel: _selectedChannel!));
                                          },
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // EPG List with FutureBuilder to handle async data fetching
                                  Expanded(
                                    child: _selectedChannel == null
                                        ? const Center(
                                            child: Text(
                                                "Select a channel to see EPG",
                                                style: TextStyle(
                                                    color: Colors.white24)))
                                        : FutureBuilder<List<EpgModel>>(
                                            future: _epgFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return const Center(
                                                    child: Text(
                                                        "Error loading EPG",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .redAccent)));
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return const Center(
                                                    child: Text(
                                                        "No Program Information Available",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white24)));
                                              }

                                              final epgList = snapshot.data!;

                                              return ListView.builder(
                                                itemCount: epgList.length,
                                                itemBuilder: (context, index) {
                                                  final epg = epgList[index];

                                                  // Data usually comes as base64 or raw strings
                                                  final start = epg.start ?? "";
                                                  final end = epg.end ?? "";
                                                  final title =
                                                      _decodeText(epg.title);
                                                  final desc = _decodeText(
                                                      epg.description);

                                                  // Default time display if parsing fails
                                                  String timeDisplay =
                                                      "$start\n$end";

                                                  DateTime? startDt;
                                                  DateTime? endDt;

                                                  // Try to parse Unix timestamps if available from the API
                                                  if (epg.startTimestamp !=
                                                          null &&
                                                      epg.stopTimestamp !=
                                                          null) {
                                                    try {
                                                      startDt = DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(epg
                                                                      .startTimestamp!) *
                                                                  1000);
                                                      endDt = DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(epg
                                                                      .stopTimestamp!) *
                                                                  1000);
                                                    } catch (_) {}
                                                  }

                                                  // Format time display as HH:mm if we have valid DateTime objects
                                                  if (startDt != null &&
                                                      endDt != null) {
                                                    String fmt(DateTime dt) =>
                                                        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                                                    timeDisplay =
                                                        "${fmt(startDt)}\n${fmt(endDt)}";
                                                  } else {
                                                    // Fallback: Try to parse formatted strings (e.g., YYYY-MM-DD HH:MM:SS)
                                                    try {
                                                      if (start.length >= 16) {
                                                        final s =
                                                            DateTime.parse(
                                                                start);
                                                        final e =
                                                            DateTime.parse(end);
                                                        String fmt(
                                                                DateTime dt) =>
                                                            "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                                                        timeDisplay =
                                                            "${fmt(s)}\n${fmt(e)}";

                                                        // Update DateTime objects for status checks below
                                                        startDt = s;
                                                        endDt = e;
                                                      }
                                                    } catch (_) {}
                                                  }

                                                  final now = DateTime.now();

                                                  // Determine program status relative to current time
                                                  bool isPast = endDt != null &&
                                                      endDt.isBefore(now);

                                                  // 'isNow' identifies the currently airing program
                                                  bool isNow = startDt !=
                                                          null &&
                                                      endDt != null &&
                                                      startDt.isBefore(now) &&
                                                      endDt.isAfter(now);

                                                  // isCurrent is a naive check based on list order (usually first is current)
                                                  final isCurrent = index == 0;

                                                  // Check if the channel supports catch-up (archive)
                                                  bool hasArchive =
                                                      _selectedChannel!
                                                              .tvArchive ==
                                                          1;

                                                  return Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12,
                                                        horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: (isCurrent ||
                                                              isNow)
                                                          ? kColorPrimary
                                                              .withOpacity(0.1)
                                                          : null,
                                                      border: const Border(
                                                          bottom: BorderSide(
                                                              color: Colors
                                                                  .white10)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 100,
                                                          child: Text(
                                                            timeDisplay,
                                                            style: TextStyle(
                                                              color: (isCurrent ||
                                                                      isNow)
                                                                  ? kColorPrimary
                                                                  : kColorTextSecondary,
                                                              fontWeight:
                                                                  (isCurrent ||
                                                                          isNow)
                                                                      ? FontWeight
                                                                          .bold
                                                                      : FontWeight
                                                                          .normal,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 16),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                title,
                                                                style:
                                                                    TextStyle(
                                                                  color: (isCurrent ||
                                                                          isNow)
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .white70,
                                                                  fontWeight: (isCurrent ||
                                                                          isNow)
                                                                      ? FontWeight
                                                                          .bold
                                                                      : FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                              if (desc
                                                                  .isNotEmpty)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              4.0),
                                                                  child: Text(
                                                                    desc,
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white54,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        // ARCHIVE ACTIONS (Catch-up / Replay)
                                                        if (hasArchive &&
                                                            (isPast || isNow) &&
                                                            startDt != null &&
                                                            endDt != null)
                                                          IconButton(
                                                            icon: Icon(
                                                              isNow
                                                                  ? Icons.replay
                                                                  : Icons
                                                                      .play_circle_outline,
                                                              color:
                                                                  kColorPrimary,
                                                            ),
                                                            tooltip: isNow
                                                                ? "Restart"
                                                                : "Play Catch-up",
                                                            onPressed:
                                                                () async {
                                                              // Calculate program duration in minutes for the API request
                                                              final durationMin =
                                                                  endDt!
                                                                      .difference(
                                                                          startDt!)
                                                                      .inMinutes;

                                                              final user =
                                                                  await LocaleApi
                                                                      .getUser();
                                                              if (user !=
                                                                  null) {
                                                                // Construct the specific Catch-up URL
                                                                final catchUpUrl =
                                                                    IpTvApi
                                                                        .constructCatchUpUrl(
                                                                  baseUrl: user
                                                                      .serverInfo!
                                                                      .serverUrl!,
                                                                  username: user
                                                                      .userInfo!
                                                                      .username!,
                                                                  password: user
                                                                      .userInfo!
                                                                      .password!,
                                                                  streamId:
                                                                      _selectedChannel!
                                                                          .streamId!,
                                                                  startTimestamp:
                                                                      "${startDt!.millisecondsSinceEpoch ~/ 1000}", // Unix seconds
                                                                  duration:
                                                                      durationMin
                                                                          .toString(),
                                                                );

                                                                // Open the catch-up stream in the preview player
                                                                await _previewPlayer
                                                                    .open(
                                                                  Media(
                                                                      catchUpUrl),
                                                                  play: true,
                                                                );

                                                                // Navigate to the player screen in non-live mode (to allow seeking)
                                                                Get.to(() =>
                                                                    MediaKitPlayerScreen(
                                                                      title:
                                                                          "${title} (Catch-up)",
                                                                      link:
                                                                          catchUpUrl,
                                                                      isLive:
                                                                          false,
                                                                      player:
                                                                          _previewPlayer,
                                                                      videoController:
                                                                          _previewVideoController,
                                                                    ));
                                                              }
                                                            },
                                                          ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
