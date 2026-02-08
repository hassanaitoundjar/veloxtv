part of '../screens.dart';

class LiveCategoriesScreen extends StatefulWidget {
  const LiveCategoriesScreen({super.key});

  @override
  State<LiveCategoriesScreen> createState() => _LiveCategoriesScreenState();
}

class _LiveCategoriesScreenState extends State<LiveCategoriesScreen> {
  CategoryModel? _selectedCategory;
  ChannelLive? _selectedChannel;
  Future<List<EpgModel>>? _epgFuture;
  final _searchController = TextEditingController();
  String _searchQuery = "";

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
    // Trigger category load if not already loaded (handled by WelcomeScreen usually but good to be safe)
    final catState = context.read<LiveCatyBloc>().state;
    if (catState is LiveCatySuccess && catState.categories.isNotEmpty) {
      _selectCategory(catState.categories.first);
    }
  }

  void _selectCategory(CategoryModel category) {
    setState(() {
      _selectedCategory = category;
    });
    context
        .read<ChannelsBloc>()
        .add(GetChannels(category.categoryId!, TypeCategory.live));
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
                                        onTap: () => _selectCategory(cat),
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

                                  return ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: channels.length,
                                    itemBuilder: (context, index) {
                                      final channel = channels[index];
                                      return ListChannelItem(
                                        title: channel.name ??
                                            "Channel ${channel.num}",
                                        icon: channel.streamIcon,
                                        epg: "No Program Info",
                                        isFocus: _selectedChannel?.streamId ==
                                            channel.streamId,
                                        onTap: () {
                                          setState(() {
                                            _selectedChannel = channel;
                                            if (channel.streamId != null) {
                                              _epgFuture =
                                                  IpTvApi.getEPGbyStreamId(
                                                      channel.streamId!);
                                            } else {
                                              _epgFuture = null;
                                            }
                                          });
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
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              color: Colors.black,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (_selectedChannel?.streamIcon != null &&
                                      _selectedChannel!.streamIcon!.isNotEmpty)
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
                                                      color: Colors.white24)),
                                        ),
                                      ),
                                    ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        iconSize: 64,
                                        icon: Icon(Icons.play_circle_fill,
                                            color:
                                                kColorPrimary.withOpacity(0.8)),
                                        onPressed: () {
                                          if (_selectedChannel != null) {
                                            Get.toNamed(screenPlayer,
                                                arguments: _selectedChannel);
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      const Text("Preview",
                                          style:
                                              TextStyle(color: Colors.white54)),
                                    ],
                                  ),
                                ],
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
                                  Text(
                                    "TV GUIDE",
                                    style: Get.textTheme.titleMedium?.copyWith(
                                      color: kColorTextSecondary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
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
                                                      _decodeText(epg.title) ??
                                                          "No Title";
                                                  final desc = _decodeText(
                                                      epg.description ?? "");

                                                  // Check if decoding is needed (naive check or just try raw)
                                                  // Given azul_iptv didn't decode, we try raw.

                                                  // Format times:
                                                  // If they follow typical structure (e.g. 20230208143000 +0000)
                                                  // we might want to substring them?
                                                  // For now, raw.

                                                  String timeDisplay =
                                                      "$start\n$end";

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

                                                  return Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12,
                                                        horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: isCurrent
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
                                                              color: isCurrent
                                                                  ? kColorPrimary
                                                                  : kColorTextSecondary,
                                                              fontWeight: isCurrent
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
                                                                  color: isCurrent
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .white70,
                                                                  fontWeight: isCurrent
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
