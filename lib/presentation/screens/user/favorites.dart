part of '../screens.dart';

/// Responsive size tokens for FavoriteScreen across all device classes.
class _FavSizes {
  final double liveCardWidth;
  final double liveCardHeight;
  final double movieCardWidth;
  final double movieCardHeight;
  final double seriesCardWidth;
  final double seriesCardHeight;
  final double itemSpacing;
  final double sectionSpacing;
  final double headingFontSize;
  final double clearAllFontSize;
  final double headingGap;

  const _FavSizes({
    required this.liveCardWidth,
    required this.liveCardHeight,
    required this.movieCardWidth,
    required this.movieCardHeight,
    required this.seriesCardWidth,
    required this.seriesCardHeight,
    required this.itemSpacing,
    required this.sectionSpacing,
    required this.headingFontSize,
    required this.clearAllFontSize,
    required this.headingGap,
  });

  factory _FavSizes.of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTvDevice = isTv(context);

    // --- Small phone (< 360) ---
    if (width < 360) {
      return const _FavSizes(
        liveCardWidth: 80,
        liveCardHeight: 80,
        movieCardWidth: 90,
        movieCardHeight: 130,
        seriesCardWidth: 90,
        seriesCardHeight: 130,
        itemSpacing: 8,
        sectionSpacing: 20,
        headingFontSize: 15,
        clearAllFontSize: 12,
        headingGap: 8,
      );
    }
    // --- Standard phone (360 - 599) ---
    if (width < 600) {
      return const _FavSizes(
        liveCardWidth: 80,
        liveCardHeight: 80,
        movieCardWidth: 100,
        movieCardHeight: 145,
        seriesCardWidth: 100,
        seriesCardHeight: 145,
        itemSpacing: 10,
        sectionSpacing: 24,
        headingFontSize: 16,
        clearAllFontSize: 13,
        headingGap: 10,
      );
    }
    // --- Tablet portrait (600 - 899) ---
    if (width < 900) {
      return const _FavSizes(
        liveCardWidth: 190,
        liveCardHeight: 160,
        movieCardWidth: 150,
        movieCardHeight: 215,
        seriesCardWidth: 150,
        seriesCardHeight: 215,
        itemSpacing: 16,
        sectionSpacing: 32,
        headingFontSize: 20,
        clearAllFontSize: 14,
        headingGap: 14,
      );
    }
    // --- Tablet landscape / small desktop (900 - 1279) ---
    if (width < 1280) {
      return const _FavSizes(
        liveCardWidth: 100,
        liveCardHeight: 100,
        movieCardWidth: 100,
        movieCardHeight: 100,
        seriesCardWidth: 100,
        seriesCardHeight: 100,
        itemSpacing: 18,
        sectionSpacing: 36,
        headingFontSize: 22,
        clearAllFontSize: 15,
        headingGap: 16,
      );
    }
    // --- TV / large desktop (>= 1280) ---
    return _FavSizes(
      liveCardWidth: isTvDevice ? 200 : 230,
      liveCardHeight: isTvDevice ? 200 : 190,
      movieCardWidth: isTvDevice ? 190 : 175,
      movieCardHeight: isTvDevice ? 270 : 250,
      seriesCardWidth: isTvDevice ? 190 : 175,
      seriesCardHeight: isTvDevice ? 270 : 250,
      itemSpacing: isTvDevice ? 24 : 20,
      sectionSpacing: isTvDevice ? 48 : 40,
      headingFontSize: isTvDevice ? 28 : 24,
      clearAllFontSize: isTvDevice ? 18 : 16,
      headingGap: 20,
    );
  }
}

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = _FavSizes.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites",
            style: TextStyle(fontSize: s.headingFontSize * 0.8)),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesSuccess) {
            if (state.live.isEmpty &&
                state.movies.isEmpty &&
                state.series.isEmpty) {
              return const Center(child: Text("No favorites yet."));
            }

            return SingleChildScrollView(
              padding: getTvSafeMargins(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.live.isNotEmpty) ...[
                    _buildSectionHeader(
                      s,
                      "Live Channels",
                      () => context.read<FavoritesCubit>().clearLive(),
                    ),
                    SizedBox(height: s.headingGap),
                    SizedBox(
                      height: s.liveCardHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.live.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: s.itemSpacing),
                        itemBuilder: (context, index) {
                          final item = state.live[index];
                          return SizedBox(
                            width: s.liveCardWidth,
                            child: CardLiveItem(
                              title: item.name ?? "",
                              icon: item.streamIcon,
                              onTap: () async {
                                final user = await LocaleApi.getUser();
                                if (user != null) {
                                  final format =
                                      GetStorage().read('stream_format') ??
                                          'default';
                                  final base =
                                      "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/${item.streamId}";
                                  final link = format == 'default'
                                      ? base
                                      : "$base.$format";
                                  final title = item.name ?? "";
                                  ExternalPlayerService.play(
                                    context: context,
                                    url: link,
                                    title: title,
                                    openBuiltIn: () {
                                      Get.to(() => MediaKitPlayerScreen(
                                            link: link,
                                            title: title,
                                            isLive: true,
                                            channel: item,
                                          ));
                                    },
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: s.sectionSpacing),
                  ],
                  if (state.movies.isNotEmpty) ...[
                    _buildSectionHeader(
                      s,
                      "Movies",
                      () => context.read<FavoritesCubit>().clearMovies(),
                    ),
                    SizedBox(height: s.headingGap),
                    SizedBox(
                      height: s.movieCardHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.movies.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: s.itemSpacing),
                        itemBuilder: (context, index) {
                          final item = state.movies[index];
                          return SizedBox(
                            width: s.movieCardWidth,
                            child: FocusableCard(
                              onTap: () => Get.toNamed(screenMovieDetails,
                                  arguments: item),
                              scale: 1.05,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item.streamIcon ?? "",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (state.series.isNotEmpty) ...[
                    SizedBox(height: s.sectionSpacing),
                    _buildSectionHeader(
                      s,
                      "Series",
                      () => context.read<FavoritesCubit>().clearSeries(),
                    ),
                    SizedBox(height: s.headingGap),
                    SizedBox(
                      height: s.seriesCardHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.series.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: s.itemSpacing),
                        itemBuilder: (context, index) {
                          final item = state.series[index];
                          return SizedBox(
                            width: s.seriesCardWidth,
                            child: FocusableCard(
                              onTap: () => Get.toNamed(screenSeriesDetails,
                                  arguments: item),
                              scale: 1.05,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item.cover ?? "",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          } else if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSectionHeader(_FavSizes s, String title, VoidCallback onClear) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: s.headingFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onClear,
          child: Text(
            "Clear All",
            style: TextStyle(
              color: kColorPrimary,
              fontSize: s.clearAllFontSize,
            ),
          ),
        ),
      ],
    );
  }
}
