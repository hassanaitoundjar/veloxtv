part of '../screens.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Live Channels",
                            style: Get.textTheme.headlineSmall),
                        TextButton(
                          onPressed: () =>
                              context.read<FavoritesCubit>().clearLive(),
                          child: const Text("Clear All",
                              style: TextStyle(color: kColorPrimary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.live.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final item = state.live[index];
                          return SizedBox(
                            width: 160,
                            child: CardLiveItem(
                              title: item.name ?? "",
                              icon: item.streamIcon,
                              onTap: () async {
                                final user = await LocaleApi.getUser();
                                if (user != null) {
                                  final link =
                                      "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/${item.streamId}";
                                  Get.to(() => MediaKitPlayerScreen(
                                        link: link,
                                        title: item.name ?? "",
                                        isLive: true,
                                      ));
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  if (state.movies.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Movies", style: Get.textTheme.headlineSmall),
                        TextButton(
                          onPressed: () =>
                              context.read<FavoritesCubit>().clearMovies(),
                          child: const Text("Clear All",
                              style: TextStyle(color: kColorPrimary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.movies.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final item = state.movies[index];
                          return SizedBox(
                            width: 140,
                            child: FocusableCard(
                              onTap: () => Get.toNamed(screenMovieDetails,
                                  arguments: item),
                              scale: 1.05,
                              child: CachedNetworkImage(
                                imageUrl: item.streamIcon ?? "",
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (state.series.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Series", style: Get.textTheme.headlineSmall),
                        TextButton(
                          onPressed: () =>
                              context.read<FavoritesCubit>().clearSeries(),
                          child: const Text("Clear All",
                              style: TextStyle(color: kColorPrimary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.series.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final item = state.series[index];
                          return SizedBox(
                            width: 140,
                            child: FocusableCard(
                              onTap: () => Get.toNamed(screenSeriesDetails,
                                  arguments: item),
                              scale: 1.05,
                              child: CachedNetworkImage(
                                imageUrl: item.cover ?? "",
                                fit: BoxFit.cover,
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
}
