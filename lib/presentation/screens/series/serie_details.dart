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
    final details = await IpTvApi.getSerieDetails(_serie.seriesId!);
    if (mounted) {
      setState(() {
        _details = details;
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
            image: CachedNetworkImageProvider(_serie.cover ?? ""),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
          color: kColorBackground,
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    kColorBackground.withOpacity(0.9),
                    kColorBackground,
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: getTvSafeMargins(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Row(
                    children: [
                      Container(
                        height: 150,
                        width: 100,
                        decoration: kDecorCard.copyWith(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(_serie.cover ?? ""),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _serie.name ?? "Unknown Series",
                              style: Get.textTheme.displaySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            if (_details != null)
                              Text(
                                "Rating: ${_details!.info?.rating} | Genre: ${_details!.info?.genre}",
                                style: Get.textTheme.bodyMedium?.copyWith(color: kColorTextSecondary),
                              ),
                            const SizedBox(height: 16),
                            FocusableCard(
                              onTap: () {
                                context.read<FavoritesCubit>().addSeries(_serie);
                                Get.snackbar("Favorites", "Added to favorites", 
                                  backgroundColor: kColorSuccess, colorText: Colors.white);
                              },
                              scale: 1.05,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: kColorCardLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.favorite_border, size: 20, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Add to Favorites"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Seasons & Episodes
                  if (_isLoading)
                     Expanded(child: Center(child: LoadingAnimationWidget.staggeredDotsWave(color: kColorPrimary, size: 40)))
                  else if (_details != null && _details!.seasons != null)
                    Expanded(
                      child: Row(
                        children: [
                          // Seasons List
                          Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: kColorPanel.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text("Seasons", style: Get.textTheme.titleMedium),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _details!.seasons!.length,
                                    itemBuilder: (context, index) {
                                      final season = _details!.seasons![index];
                                      final isSelected = _selectedSeasonIndex == index;
                                      return FocusableCard(
                                        onTap: () {
                                          setState(() => _selectedSeasonIndex = index);
                                        },
                                        scale: 1.02,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          color: isSelected ? kColorPrimary.withOpacity(0.2) : null,
                                          child: Text(
                                            season.name ?? "Season ${season.seasonNumber}",
                                            style: TextStyle(
                                              color: isSelected ? kColorPrimary : Colors.white,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Episodes List
                          Expanded(
                            child: ListView.separated(
                              itemCount: _details!.episodes?[_details!.seasons![_selectedSeasonIndex].seasonNumber.toString()]?.length ?? 0,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final seasonNum = _details!.seasons![_selectedSeasonIndex].seasonNumber.toString();
                                final episode = _details!.episodes?[seasonNum]?[index];
                                
                                if (episode == null) return const SizedBox();
                                
                                return FocusableCard(
                                  onTap: () {
                                    Get.toNamed(screenPlayer, arguments: episode);
                                  },
                                  scale: 1.02,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: kDecorCard.copyWith(color: kColorCardLight),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: kColorCardDark,
                                            border: Border.all(color: kColorPrimary.withOpacity(0.5)),
                                          ),
                                          child: const Icon(Icons.play_arrow, color: kColorPrimary),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                episode.title ?? "Episode ${episode.episodeNum}",
                                                style: Get.textTheme.titleMedium,
                                              ),
                                              if (episode.duration != null)
                                                Text(
                                                  "${(episode.duration! / 60).toStringAsFixed(0)} min",
                                                  style: Get.textTheme.bodySmall?.copyWith(color: kColorTextSecondary),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
}
