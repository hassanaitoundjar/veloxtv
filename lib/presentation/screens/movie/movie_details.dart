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

                        const Spacer(),

                        // Title
                        Text(
                          _movie.name ?? "Unknown Movie",
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
                        if (_detail?.info?.plot != null)
                          Text(
                            _detail!.info!.plot!,
                            style: Get.textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 24),

                        // Action Buttons
                        _buildActionButtons(),

                        const SizedBox(height: 20),

                        // Cast/Director Info
                        if (_detail?.info?.director != null ||
                            _detail?.info?.cast != null)
                          _buildCredits(),

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
        if (_movie.rating != null && _movie.rating!.isNotEmpty)
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
                  _movie.rating!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

        // Year
        if (_detail?.info?.releaseDate != null)
          Text(
            _detail!.info!.releaseDate!.split('-').first,
            style: Get.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),

        // Genre
        if (_detail?.info?.genre != null)
          Text(
            _detail!.info!.genre!.split(',').first.trim(),
            style: Get.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Play Button
        Expanded(
          flex: 2,
          child: FocusableCard(
            onTap: () {
              if (_detail != null) {
                Get.toNamed(screenPlayer, arguments: _detail);
              }
            },
            autoFocus: true,
            scale: 1.02,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, color: Colors.black, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Play",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
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
                      colorText: Colors.white);
                } else {
                  context.read<FavoritesCubit>().addMovie(_movie);
                  Get.snackbar("Added", "Added to My List",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.grey.shade900,
                      colorText: Colors.white);
                }
              },
              scale: 1.05,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white30),
                ),
                child: Icon(
                  isFav ? Icons.check : Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
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
                const Icon(Icons.share_outlined, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildCredits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_detail?.info?.director != null) ...[
          RichText(
            text: TextSpan(
              text: "Director: ",
              style: Get.textTheme.bodyMedium?.copyWith(color: Colors.white54),
              children: [
                TextSpan(
                  text: _detail!.info!.director!,
                  style:
                      Get.textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (_detail?.info?.cast != null)
          RichText(
            text: TextSpan(
              text: "Cast: ",
              style: Get.textTheme.bodyMedium?.copyWith(color: Colors.white54),
              children: [
                TextSpan(
                  text: _detail!.info!.cast!.length > 100
                      ? "${_detail!.info!.cast!.substring(0, 100)}..."
                      : _detail!.info!.cast!,
                  style:
                      Get.textTheme.bodyMedium?.copyWith(color: Colors.white),
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
