part of '../screens.dart';

class MovieChannelsScreen extends StatefulWidget {
  const MovieChannelsScreen({super.key});

  @override
  State<MovieChannelsScreen> createState() => _MovieChannelsScreenState();
}

class _MovieChannelsScreenState extends State<MovieChannelsScreen> {
  late CategoryModel _initialCategory;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    if (Get.arguments is CategoryModel) {
      _initialCategory = Get.arguments as CategoryModel;
      context
          .read<ChannelsBloc>()
          .add(GetChannels(_initialCategory.categoryId!, TypeCategory.movies));
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
            // Global Header (Same as Live TV)
            AppBarLive(
              onSearch: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
            ),

            // Main Content Row
            Expanded(
              child: Row(
                children: [
                  // Left - Vertical Categories
                  BlocBuilder<MovieCatyBloc, MovieCatyState>(
                    builder: (context, state) {
                      if (state is MovieCatySuccess) {
                        return SideCategoryMenu(
                          categories: state.categories,
                          selectedId: int.parse(_initialCategory.categoryId!),
                          onSelect: (cat) {
                            setState(() {
                              _initialCategory = cat;
                            });
                            context.read<ChannelsBloc>().add(GetChannels(
                                cat.categoryId!, TypeCategory.movies));
                          },
                        );
                      }
                      return const SizedBox(width: 200);
                    },
                  ),

                  // Right - Movie Poster Grid
                  Expanded(
                    child: BlocBuilder<ChannelsBloc, ChannelsState>(
                      builder: (context, state) {
                        if (state is ChannelsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is ChannelsSuccess) {
                          var movies = state.channels.cast<ChannelMovie>();

                          // Apply search filter
                          if (_searchQuery.isNotEmpty) {
                            movies = movies
                                .where((m) => (m.name
                                        ?.toLowerCase()
                                        .contains(_searchQuery) ??
                                    false))
                                .toList();
                          }

                          if (movies.isEmpty) {
                            return const Center(
                                child: Text("No movies found."));
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: getGridColumns(context).toInt(),
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: movies.length,
                            itemBuilder: (context, index) {
                              final movie = movies[index];
                              return BlocBuilder<FavoritesCubit,
                                  FavoritesState>(
                                builder: (context, favState) {
                                  final isFav = favState is FavoritesSuccess &&
                                      favState.movies.any(
                                          (m) => m.streamId == movie.streamId);
                                  return FocusableCard(
                                    onTap: () {
                                      Get.toNamed(screenMovieDetails,
                                          arguments: movie);
                                    },
                                    scale: 1.05,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Poster Image
                                        Container(
                                          decoration: kDecorCard.copyWith(
                                            image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  movie.streamIcon ?? ""),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        // Gradient Overlay
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.8),
                                              ],
                                              stops: const [0.5, 1.0],
                                            ),
                                          ),
                                        ),
                                        // Rating Badge (Top Right)
                                        if (movie.rating != null &&
                                            movie.rating!.isNotEmpty)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.star,
                                                      color: Colors.amber,
                                                      size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    movie.rating!,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        // Favorite Heart (Top Left)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (isFav) {
                                                context
                                                    .read<FavoritesCubit>()
                                                    .removeMovie(
                                                        movie.streamId ?? "");
                                              } else {
                                                context
                                                    .read<FavoritesCubit>()
                                                    .addMovie(movie);
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isFav
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFav
                                                    ? Colors.yellow
                                                    : Colors.white70,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Title at Bottom
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          right: 8,
                                          child: Text(
                                            movie.name ?? "",
                                            style: Get.textTheme.bodySmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
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
          ],
        ),
      ),
    );
  }
}
