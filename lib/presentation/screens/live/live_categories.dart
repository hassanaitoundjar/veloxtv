part of '../screens.dart';

class LiveCategoriesScreen extends StatefulWidget {
  final bool isPicker;
  const LiveCategoriesScreen({super.key, this.isPicker = false});

  @override
  State<LiveCategoriesScreen> createState() => _LiveCategoriesScreenState();
}

class _LiveCategoriesScreenState extends State<LiveCategoriesScreen> {
  CategoryModel? _selectedCategory;
  ChannelLive? _selectedChannel;
  Future<List<EpgModel>>? _epgFuture;
  final _searchController = TextEditingController();
  late FocusNode _searchFocusNode;
  String _searchQuery = "";

  late final Player _previewPlayer;
  late final VideoController _previewVideoController;

  String _decodeText(String? text) {
    if (text == null || text.isEmpty) return "";
    try {
      return utf8.decode(base64.decode(text));
    } catch (e) {
      return text;
    }
  }

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
    MediaKit.ensureInitialized();

    _previewPlayer = Player();
    _previewVideoController = VideoController(_previewPlayer);

    final catState = context.read<LiveCatyBloc>().state;
    if (catState is LiveCatySuccess && catState.categories.isNotEmpty) {
      // Find first safe category
      final firstSafe = catState.categories.firstWhere(
        (c) => !_isRestricted(c),
        orElse: () => catState.categories.first,
      );

      // Only select if safe
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

  Future<void> _initializePlayer(ChannelLive channel) async {
    final user = await LocaleApi.getUser();
    if (user == null || channel.streamId == null) return;

    final url =
        "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/${channel.streamId}";

    await _previewPlayer.open(
      Media(url),
      play: true,
    );
  }

  void _selectCategory(CategoryModel category) {
    setState(() {
      _selectedCategory = category;
    });
    context
        .read<ChannelsBloc>()
        .add(GetChannels(category.categoryId!, TypeCategory.live));
  }

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

  bool _isRestricted(CategoryModel category) {
    if (!_isRestrictedName(category.categoryName)) return false;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return true;
    final userId = authState.user.id;
    final storage = GetStorage("settings");
    final enabled = storage.read("parental_control_enabled_$userId") ?? true;
    return enabled;
  }

  void _checkChannelAccess(ChannelLive channel, VoidCallback onAllowed) {
    // If unrestricted, allow immediately
    if (!_isRestrictedName(channel.name)) {
      onAllowed();
      return;
    }

    // Check if enabled for user
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return; // Should not happen
    final userId = authState.user.id;
    final storage = GetStorage("settings");
    final enabled = storage.read("parental_control_enabled_$userId") ?? true;

    if (!enabled) {
      onAllowed();
      return;
    }

    Get.dialog(
      ParentalControlWidget(
        userId: userId,
        mode: ParentalMode.verify,
        onVerifySuccess: onAllowed,
      ),
    );
  }

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
        decoration: kDecorBackground,
        child: Column(
          children: [
            // Global Header
            const AppBarLive(),

            // Main Content (Tri-Pane)
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
                            padding: EdgeInsets.fromLTRB(
                                16, 1.h, 16, 2.h), // Adjusted padding
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Search Bar
                                Container(
                                  height: 40,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    focusNode: _searchFocusNode,
                                    controller:
                                        _searchController, // No usage error now
                                    onChanged: (val) =>
                                        setState(() => _searchQuery = val),
                                    decoration: const InputDecoration(
                                      hintText: "Search in categories",
                                      prefixIcon: Icon(Icons.search, size: 18),
                                      border: InputBorder.none,
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
                                  final filtered = state.categories
                                      .where((e) =>
                                          e.categoryName
                                              ?.toLowerCase()
                                              .contains(
                                                  _searchQuery.toLowerCase()) ??
                                          true)
                                      .toList();

                                  // Auto-select first if none selected
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
                                              // Count placeholder (API doesn't return count in this model yet)
                                              // Text("0", style: TextStyle(color: isSelected ? Colors.white70 : Colors.white24, fontSize: 12)),
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
                          // Header (Just Category Name now)
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

                          // Content
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

                                  return BlocBuilder<FavoritesCubit,
                                      FavoritesState>(
                                    builder: (context, favState) {
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
                                            onTap: () {
                                              _checkChannelAccess(channel, () {
                                                if (widget.isPicker) {
                                                  Get.back(result: channel);
                                                  return;
                                                }
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

                  // PANE 3: PREVIEW (Flex 5)
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.black, // Dark background for preview area
                      child: Column(
                        children: [
                          // Mini Player Area (Top)
                          FocusableCard(
                            onTap: () {
                              if (_selectedChannel != null) {
                                _checkChannelAccess(_selectedChannel!,
                                    () async {
                                  final user = await LocaleApi.getUser();
                                  if (user != null) {
                                    final link =
                                        "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/${_selectedChannel!.streamId}";

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
                                    if (_selectedChannel != null)
                                      Video(
                                        controller: _previewVideoController,
                                        fit: BoxFit.cover,
                                        controls: NoVideoControls,
                                      )
                                    else ...[
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
                                  // Channel Header
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

                                  // EPG Section Title
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

                                  // EPG List
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

                                                  // Use raw strings as model likely provides them directly
                                                  // or we can add base64 decode if we see garbage.
                                                  final start = epg.start ?? "";
                                                  final end = epg.end ?? "";
                                                  final title =
                                                      _decodeText(epg.title);
                                                  final desc = _decodeText(
                                                      epg.description);

                                                  // Check if decoding is needed (naive check or just try raw)
                                                  // Given azul_iptv didn't decode, we try raw.

                                                  // Format times:
                                                  // If they follow typical structure (e.g. 20230208143000 +0000)
                                                  // we might want to substring them?
                                                  // For now, raw.

                                                  // 1. Try to use startDt and endDt if available (parsed below)
                                                  // 2. Fallback to substring if string format is standard
                                                  // 3. Last resort: raw string

                                                  String timeDisplay =
                                                      "$start\n$end"; // Default fallback

                                                  // Improved Time Parsing (Optional, based on expected format)
                                                  // If startTimestamp is available, use it?
                                                  // Model: String? startTimestamp;

                                                  if (epg.start != null &&
                                                      epg.end != null &&
                                                      epg.start!.length > 10) {
                                                    // Try to be smarter if formats are standard
                                                    // But safe fallback is just returning what API gave.
                                                  }

                                                  final isCurrent = index == 0;

                                                  // Catch-up Access
                                                  bool hasArchive =
                                                      _selectedChannel!
                                                              .tvArchive ==
                                                          1;
                                                  final now = DateTime.now();

                                                  // Parse Start Time (Assuming API returns various formats, try to safe parse)
                                                  // Often EPG start is YYYYMMDDHHMMSS +0000 or timestamp
                                                  // We need duration and start timestamp for the URL.
                                                  // EpgModel has startTimestamp and stopTimestamp as String?
                                                  // Let's rely on them if available, else derive?
                                                  DateTime? startDt;
                                                  DateTime? endDt;

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

                                                  // Format time for display if we have dates
                                                  if (startDt != null &&
                                                      endDt != null) {
                                                    // Helper to format HH:mm
                                                    String fmt(DateTime dt) =>
                                                        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                                                    timeDisplay =
                                                        "${fmt(startDt)}\n${fmt(endDt)}";
                                                  } else {
                                                    // Try to parse from string if YYYY-MM-DD HH:MM:SS
                                                    try {
                                                      // Check if start looks like 2026-02-14 21:40:00
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
                                                      }
                                                    } catch (_) {}
                                                  }

                                                  // Helper to determine status
                                                  bool isPast = endDt != null &&
                                                      endDt.isBefore(now);
                                                  // isCurrent already defined roughly by index==0 but let's use time if available
                                                  bool isNow = startDt !=
                                                          null &&
                                                      endDt != null &&
                                                      startDt.isBefore(now) &&
                                                      endDt.isAfter(now);

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
                                                        // Archive Actions
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
                                                              // Determine duration in minutes
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
                                                                // Construct URL
                                                                // Construct URL
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
                                                                      "${startDt!.millisecondsSinceEpoch ~/ 1000}", // Unix seconds - fixed unnecessary braces
                                                                  duration:
                                                                      durationMin
                                                                          .toString(),
                                                                );

                                                                // Open Player
                                                                // Reuse preview controller setup?
                                                                // If we want seamless transition, we should use the same controller.
                                                                // But we are changing the source (Media).
                                                                // When we change source, we can still use the same controller instance,
                                                                // but we must _player.open() the new media.
                                                                // MediaKitPlayerScreen does _player.open in initState.
                                                                // If we pass an EXISTING controller/player to it, it skips open?
                                                                // NO, looking at previous edit:
                                                                // if (widget.player != null) { ... _isExternalController = true; } else { ... _player.open(...) }
                                                                // Use the existing player but we must OPEN the new media on it!
                                                                // So we should probably open the media HERE before navigating?
                                                                // OR MediaKitPlayerScreen should handle opening if link changes?
                                                                // The current logic in MediaKitPlayerScreen:
                                                                // It does NOT open media if external controller is passed.
                                                                // So we must open it here.

                                                                await _previewPlayer
                                                                    .open(
                                                                  Media(
                                                                      catchUpUrl),
                                                                  play: true,
                                                                );

                                                                Get.to(() =>
                                                                    MediaKitPlayerScreen(
                                                                      title:
                                                                          "${title} (Catch-up)",
                                                                      link:
                                                                          catchUpUrl,
                                                                      isLive:
                                                                          false, // Important for seek bar
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
