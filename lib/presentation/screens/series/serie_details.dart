part of '../screens.dart';

class SeriesDetailsScreen extends StatefulWidget {
  const SeriesDetailsScreen({super.key});

  @override
  State<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen> {
  late ChannelSerie _serie;
  SerieDetails? _details;
  bool _isLoading = true;
  int _selectedSeasonIndex = 0;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is ChannelSerie) {
      _serie = Get.arguments as ChannelSerie;
      _fetchDetails();
    }
  }

  Future<void> _fetchDetails() async {
    try {
      final details = await IpTvApi.getSerieDetails(_serie.seriesId!);
      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _serie.cover ?? "",
              fit: BoxFit.cover,
              color: Colors.black54,
              colorBlendMode: BlendMode.darken,
              errorWidget: (_, __, ___) => Container(color: kColorBackground),
            ),
          ),

          // Gradient Overlays
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    kColorBackground.withOpacity(0.8),
                    kColorBackground,
                  ],
                  stops: const [0.0, 0.4, 0.7],
                ),
              ),
            ),
          ),

          // Left gradient for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    kColorBackground.withOpacity(0.95),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Side - Info & Episodes
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        FocusableCard(
                          onTap: () => Get.back(),
                          scale: 1.1,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 20),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title
                        Text(
                          _serie.name ?? "Unknown Series",
                          style: Get.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 16),

                        // Meta Row
                        _buildMetaRow(),

                        const SizedBox(height: 20),

                        // Plot
                        if (_details?.info?.plot != null)
                          Text(
                            _details!.info!.plot!,
                            style: Get.textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 24),

                        // Action Buttons
                        _buildActionButtons(),

                        const SizedBox(height: 24),

                        // Seasons & Episodes Area
                        if (!_isLoading &&
                            _details != null &&
                            _details!.seasons != null)
                          Expanded(
                            child: _buildSeasonsAndEpisodes(),
                          )
                        else
                          const Spacer(),
                      ],
                    ),
                  ),
                ),

                // Right Side - Poster
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(right: 4.w, top: 3.h, bottom: 3.h),
                    child: _buildPoster(),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: kColorPrimary,
                  size: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Rating
        if (_serie.rating != null &&
            _serie.rating!.isNotEmpty &&
            _serie.rating != "0")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.black, size: 16),
                const SizedBox(width: 4),
                Text(
                  _serie.rating!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

        // Release Date
        if (_details?.info?.releaseDate != null)
          Text(
            _details!.info!.releaseDate!.split('-').first,
            style: Get.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),

        // Genre
        if (_details?.info?.genre != null)
          Text(
            _details!.info!.genre!.split(',').first.trim(),
            style: Get.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Favorite Button
        BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favState) {
            final isFav = favState is FavoritesSuccess &&
                favState.series.any((s) => s.seriesId == _serie.seriesId);
            return FocusableCard(
              onTap: () {
                if (isFav) {
                  context
                      .read<FavoritesCubit>()
                      .removeSeries(_serie.seriesId ?? "");
                  Get.snackbar("Removed", "Removed from My List",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.grey.shade900,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 1));
                } else {
                  context.read<FavoritesCubit>().addSeries(_serie);
                  Get.snackbar("Added", "Added to My List",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.grey.shade900,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 1));
                }
              },
              scale: 1.05,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isFav ? Colors.white : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    isFav ? Icons.check : Icons.add,
                    color: isFav ? Colors.black : Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(isFav ? "My List" : "Add to List",
                      style: TextStyle(
                          color: isFav ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold))
                ]),
              ),
            );
          },
        ),

        const SizedBox(width: 12),

        // Share/More Button
        FocusableCard(
          onTap: () {},
          scale: 1.05,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white30),
            ),
            child:
                const Icon(Icons.share_outlined, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonsAndEpisodes() {
    return Container(
      decoration: BoxDecoration(
          color: kColorCardLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          // Seasons List (Left Panel of the box)
          Container(
            width: 180,
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("Seasons",
                      style: Get.textTheme.titleSmall
                          ?.copyWith(color: kColorTextSecondary)),
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: _details!.seasons!.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final season = _details!.seasons![index];
                    final isSelected = _selectedSeasonIndex == index;
                    return FocusableCard(
                      onTap: () => setState(() => _selectedSeasonIndex = index),
                      scale: 1.0,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          color: isSelected
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  season.name ??
                                      "Season ${season.seasonNumber}",
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white60,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.arrow_right,
                                    color: kColorPrimary, size: 16)
                            ],
                          )),
                    );
                  },
                ))
              ],
            ),
          ),

          // Episodes List (Right Panel of the box)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                      "${_details!.seasons![_selectedSeasonIndex].name} Episodes",
                      style: Get.textTheme.titleSmall
                          ?.copyWith(color: kColorTextSecondary)),
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: _details!
                          .episodes?[_details!
                              .seasons![_selectedSeasonIndex].seasonNumber
                              .toString()]
                          ?.length ??
                      0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  itemBuilder: (context, index) {
                    final seasonNum = _details!
                        .seasons![_selectedSeasonIndex].seasonNumber
                        .toString();
                    final episode = _details!.episodes?[seasonNum]?[index];

                    if (episode == null) return const SizedBox();

                    return BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is! AuthSuccess) return const SizedBox();
                        final userAuth = state.user;

                        return FocusableCard(
                          onTap: () {
                            if (episode == null) return;
                            final link =
                                "${userAuth.serverInfo!.serverUrl}/series/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${episode.id}.${episode.containerExtension}";

                            Get.to(() => MediaKitPlayerScreen(
                                      link: link,
                                      title: episode.title ?? "",
                                    ))!
                                .then((slider) {
                              if (slider != null &&
                                  slider is List &&
                                  slider.isNotEmpty) {
                                var model = WatchingModel(
                                  sliderValue: slider[0],
                                  durationStrm: slider[1] ?? 0.0,
                                  stream: link,
                                  title: episode.title ?? "",
                                  image: _details!.info!.cover ?? "",
                                  streamId: episode.id.toString(),
                                );
                                context.read<WatchingCubit>().addSerie(model);
                              }
                            });
                          },
                          scale: 1.01,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.play_circle_outline,
                                    color: Colors.white70, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      episode.title ??
                                          "Episode ${episode.episodeNum}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (episode.duration != null &&
                                        episode.duration! > 0)
                                      Text(
                                        "${(episode.duration! / 60).toStringAsFixed(0)} min",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white54),
                                      )
                                  ],
                                ))
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPoster() {
    return Hero(
      tag: _serie.seriesId ?? "hero",
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(-10, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: _serie.cover ?? "",
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: kColorCardLight,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              color: kColorCardLight,
              child: const Icon(Icons.movie, size: 80, color: Colors.white24),
            ),
          ),
        ),
      ),
    );
  }
}
