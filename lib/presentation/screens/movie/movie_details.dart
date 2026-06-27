part of '../screens.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({super.key});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late ChannelMovie _movie;
  MovieDetail? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is ChannelMovie) {
      _movie = Get.arguments as ChannelMovie;
      _fetchDetails();
    }
  }

  Future<void> _fetchDetails() async {
    try {
      final detail = await IpTvApi.getMovieDetails(_movie.streamId!);
      if (mounted) {
        setState(() {
          _detail = detail;
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
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;

    return Scaffold(
      backgroundColor: kColorBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _movie.streamIcon ?? "",
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
                    kColorBackground.withOpacity(0.9),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Side - Info
                Expanded(
                  flex: isPhone ? 2 : 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isPhone ? 2.w : 4.w,
                        vertical: isPhone ? 2.h : 3.h),
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

                        const Spacer(),

                        // Title
                        Text(
                          _movie.name ?? "Unknown Movie",
                          style: (isPhone
                                  ? Get.textTheme.headlineSmall
                                  : Get.textTheme.displaySmall)
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 16),

                        // Meta Row
                        _buildMetaRow(isPhone),

                        SizedBox(height: isPhone ? 10 : 20),

                        // Plot
                        if (_detail?.info?.plot != null)
                          Text(
                            _detail!.info!.plot!,
                            style: (isPhone
                                    ? Get.textTheme.bodyMedium
                                    : Get.textTheme.bodyLarge)
                                ?.copyWith(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                            maxLines: isPhone ? 3 : 4,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 24),

                        // Action Buttons
                        _buildActionButtons(isPhone),

                        SizedBox(height: isPhone ? 10 : 20),

                        // Cast/Director Info
                        if (_detail?.info?.director != null ||
                            _detail?.info?.cast != null)
                          _buildCredits(isPhone),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                // Right Side - Poster
                Expanded(
                  flex: isPhone ? 1 : 3,
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: isPhone ? 2.w : 4.w,
                        top: isPhone ? 2.h : 3.h,
                        bottom: isPhone ? 2.h : 3.h),
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

  Widget _buildMetaRow(bool isPhone) {
    return Wrap(
      spacing: isPhone ? 8 : 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Rating
        if (_movie.rating != null && _movie.rating!.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isPhone ? 6 : 10, vertical: isPhone ? 2 : 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.black, size: isPhone ? 14 : 16),
                SizedBox(width: isPhone ? 2 : 4),
                Text(
                  _movie.rating!,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: isPhone ? 11 : 13,
                  ),
                ),
              ],
            ),
          ),

        // Year
        if (_detail?.info?.releaseDate != null)
          Text(
            _detail!.info!.releaseDate!.split('-').first,
            style:
                (isPhone ? Get.textTheme.bodyMedium : Get.textTheme.bodyLarge)
                    ?.copyWith(color: Colors.white70),
          ),

        // Duration
        if (_detail?.info?.duration != null &&
            _detail!.info!.duration!.isNotEmpty)
          Text(
            _detail!.info!.duration!.contains(':')
                ? _detail!.info!.duration!
                : '${_detail!.info!.duration} min',
            style:
                (isPhone ? Get.textTheme.bodyMedium : Get.textTheme.bodyLarge)
                    ?.copyWith(color: Colors.white70),
          ),

        // Genre
        if (_detail?.info?.genre != null)
          Text(
            _detail!.info!.genre!.split(',').first.trim(),
            style:
                (isPhone ? Get.textTheme.bodyMedium : Get.textTheme.bodyLarge)
                    ?.copyWith(color: Colors.white70),
          ),
      ],
    );
  }

  Widget _buildActionButtons(bool isPhone) {
    return Row(
      children: [
        // Play Button
        Expanded(
          flex: 2,
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is! AuthSuccess) return const SizedBox();
              final userAuth = state.user;

              return FocusableCard(
                onTap: () {
                  if (_detail == null || _detail!.movieData == null) return;

                  final link =
                      "${userAuth.serverInfo!.serverUrl}/movie/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${_detail!.movieData!.streamId}.${_detail!.movieData!.containerExtension}";
                  debugPrint("Link: $link");
                  Get.to(() => MediaKitPlayerScreen(
                            link: link,
                            title: _detail!.movieData!.name ?? "",
                            isLive: false,
                          ))!
                      .then((slider) {
                    if (slider != null && slider is List && slider.isNotEmpty) {
                      var model = WatchingModel(
                        sliderValue: slider[0],
                        durationStrm: slider[1] ?? 0.0,
                        stream: link,
                        title: _movie.name ?? "",
                        image: _movie.streamIcon ?? "",
                        streamId: _movie.streamId.toString(),
                      );
                      context.read<WatchingCubit>().addMovie(model);
                    }
                  });
                },
                autoFocus: true,
                scale: 1.02,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: isPhone ? 10 : 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow,
                          color: Colors.black, size: isPhone ? 20 : 28),
                      SizedBox(width: isPhone ? 4 : 8),
                      Text(
                        "Watch Now",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: isPhone ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        // Favorite Button
        BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favState) {
            final isFav = favState is FavoritesSuccess &&
                favState.movies.any((m) => m.streamId == _movie.streamId);
            return FocusableCard(
              onTap: () {
                if (isFav) {
                  context
                      .read<FavoritesCubit>()
                      .removeMovie(_movie.streamId ?? "");
                  Get.snackbar("Removed", "Removed from My List",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.grey.shade900,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 1));
                } else {
                  context.read<FavoritesCubit>().addMovie(_movie);
                  Get.snackbar("Added", "Added to My List",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.grey.shade900,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 1));
                }
              },
              scale: 1.05,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 16 : 24, vertical: isPhone ? 10 : 12),
                decoration: BoxDecoration(
                  color: isFav
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    isFav ? Icons.check : Icons.add,
                    color: isFav ? Colors.black : Colors.white,
                    size: isPhone ? 16 : 20,
                  ),
                  SizedBox(width: isPhone ? 4 : 8),
                  Text(isFav ? "My List" : "Add Favorite",
                      style: TextStyle(
                          color: isFav ? Colors.black : Colors.white,
                          fontSize: isPhone ? 12 : 14,
                          fontWeight: FontWeight.bold))
                ]),
              ),
            );
          },
        ),

        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildCredits(bool isPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_detail?.info?.director != null) ...[
          RichText(
            text: TextSpan(
              text: "Director: ",
              style:
                  (isPhone ? Get.textTheme.bodySmall : Get.textTheme.bodyMedium)
                      ?.copyWith(color: Colors.white54),
              children: [
                TextSpan(
                  text: _detail!.info!.director!,
                  style: (isPhone
                          ? Get.textTheme.bodySmall
                          : Get.textTheme.bodyMedium)
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: isPhone ? 4 : 8),
        ],
        if (_detail?.info?.cast != null)
          RichText(
            text: TextSpan(
              text: "Cast: ",
              style:
                  (isPhone ? Get.textTheme.bodySmall : Get.textTheme.bodyMedium)
                      ?.copyWith(color: Colors.white54),
              children: [
                TextSpan(
                  text: _detail!.info!.cast!.length > 100
                      ? "${_detail!.info!.cast!.substring(0, 100)}..."
                      : _detail!.info!.cast!,
                  style: (isPhone
                          ? Get.textTheme.bodySmall
                          : Get.textTheme.bodyMedium)
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPoster() {
    return Hero(
      tag: _movie.streamId ?? "hero",
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
            imageUrl: _movie.streamIcon ?? "",
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
