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
    final detail = await IpTvApi.getMovieDetails(_movie.streamId!);
    if (mounted) {
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(_movie.streamIcon ?? ""),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
          color: kColorBackground,
        ),
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    kColorBackground.withOpacity(0.8),
                    kColorBackground,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: getTvSafeMargins(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  Expanded(
                    flex: 2,
                    child: Hero(
                      tag: _movie.streamId ?? "hero",
                      child: Container(
                        height: 60.h,
                        decoration: kDecorCard.copyWith(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(_movie.streamIcon ?? ""),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  
                  // Info
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _movie.name ?? "Unknown Movie",
                          style: Get.textTheme.displaySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        
                        // Action Buttons
                        Row(
                          children: [
                            FocusableCard(
                              onTap: () {
                                if (_detail != null) {
                                  Get.toNamed(screenPlayer, arguments: _detail); 
                                }
                              },
                              autoFocus: true,
                              scale: 1.05,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                decoration: BoxDecoration(
                                  color: kColorPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.play_arrow, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text("PLAY", style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            FocusableCard(
                              onTap: () {
                                // Add to favorites logic
                                context.read<FavoritesCubit>().addMovie(_movie);
                                Get.snackbar("Favorites", "Added to favorites", 
                                  snackPosition: SnackPosition.BOTTOM, 
                                  backgroundColor: kColorSuccess, 
                                  colorText: Colors.white);
                              },
                              scale: 1.05,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: kColorCardLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.favorite_border, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        if (_isLoading)
                          LoadingAnimationWidget.staggeredDotsWave(color: kColorPrimary, size: 40)
                        else if (_detail != null)
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow("Rating", _detail!.info?.rating ?? "N/A"),
                                  _buildInfoRow("Genre", _detail!.info?.genre ?? "N/A"),
                                  _buildInfoRow("Released", _detail!.info?.releaseDate ?? "N/A"),
                                  _buildInfoRow("Director", _detail!.info?.director ?? "N/A"),
                                  _buildInfoRow("Cast", _detail!.info?.cast ?? "N/A"),
                                  const SizedBox(height: 24),
                                  Text(
                                    "Plot",
                                    style: Get.textTheme.titleMedium?.copyWith(color: kColorPrimary),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _detail!.info?.plot ?? "No plot available.",
                                    style: Get.textTheme.bodyLarge?.copyWith(height: 1.5, color: kColorTextSecondary),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: kColorTextSecondary),
          children: [
            TextSpan(
              text: value,
              style: Get.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
