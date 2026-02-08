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
            if (state.live.isEmpty && state.movies.isEmpty && state.series.isEmpty) {
              return const Center(child: Text("No favorites yet."));
            }
            
            return SingleChildScrollView(
              padding: getTvSafeMargins(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.live.isNotEmpty) ...[
                    Text("Live Channels", style: Get.textTheme.headlineSmall),
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
                              onTap: () {
                                Get.toNamed(screenPlayer, arguments: item);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  if (state.movies.isNotEmpty) ...[
                    Text("Movies", style: Get.textTheme.headlineSmall),
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
                              onTap: () => Get.toNamed(screenMovieDetails, arguments: item),
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
                ],
              ),
            );
          }
           else if (state is FavoritesLoading) {
             return const Center(child: CircularProgressIndicator());
           }
          
          return const SizedBox();
        },
      ),
    );
  }
}
