part of '../screens.dart';

class SeriesChannelsScreen extends StatefulWidget {
  const SeriesChannelsScreen({super.key});

  @override
  State<SeriesChannelsScreen> createState() => _SeriesChannelsScreenState();
}

class _SeriesChannelsScreenState extends State<SeriesChannelsScreen> {
  CategoryModel? _selectedCategory;
  String _searchQuery = "";
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is CategoryModel) {
      _selectedCategory = Get.arguments as CategoryModel;
      context.read<ChannelsBloc>().add(
          GetChannels(_selectedCategory!.categoryId!, TypeCategory.series));
      _initialized = true;
    }
  }

  void _initWithFirstCategory(List<CategoryModel> categories) {
    if (!_initialized && categories.isNotEmpty) {
      _selectedCategory = categories.first;
      context.read<ChannelsBloc>().add(
          GetChannels(_selectedCategory!.categoryId!, TypeCategory.series));
      _initialized = true;
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
            // Global Header
            AppBarLive(
              onSearch: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
            ),

            // Main Content Row
            Expanded(
              child: Row(
                children: [
                  // Left - Vertical Categories
                  BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
                    builder: (context, state) {
                      if (state is SeriesCatySuccess) {
                        // Auto-select first category if not yet initialized
                        _initWithFirstCategory(state.categories);

                        return SideCategoryMenu(
                          categories: state.categories,
                          selectedId: int.tryParse(
                                  _selectedCategory?.categoryId ?? "") ??
                              0,
                          onSelect: (cat) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                            context.read<ChannelsBloc>().add(GetChannels(
                                cat.categoryId!, TypeCategory.series));
                          },
                        );
                      }
                      return const SizedBox(width: 200);
                    },
                  ),

                  // Right - Series Poster Grid
                  Expanded(
                    child: BlocBuilder<ChannelsBloc, ChannelsState>(
                      builder: (context, state) {
                        if (state is ChannelsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is ChannelsSuccess) {
                          var seriesList = state.channels.cast<ChannelSerie>();

                          // Apply search filter
                          if (_searchQuery.isNotEmpty) {
                            seriesList = seriesList
                                .where((s) => (s.name
                                        ?.toLowerCase()
                                        .contains(_searchQuery) ??
                                    false))
                                .toList();
                          }

                          if (seriesList.isEmpty) {
                            return const Center(
                                child: Text("No series found."));
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: getGridColumns(context).toInt(),
                              childAspectRatio: 0.65, // Taller poster ratio
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: seriesList.length,
                            itemBuilder: (context, index) {
                              final serie = seriesList[index];

                              return BlocBuilder<FavoritesCubit,
                                  FavoritesState>(
                                builder: (context, favState) {
                                  final isFav = favState is FavoritesSuccess &&
                                      favState.series.any(
                                          (s) => s.seriesId == serie.seriesId);

                                  return FocusableCard(
                                    onTap: () {
                                      Get.toNamed(screenSeriesDetails,
                                          arguments: serie);
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
                                                  serie.cover ?? ""),
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
                                                Colors.black.withOpacity(0.8)
                                              ],
                                              stops: const [0.5, 1.0],
                                            ),
                                          ),
                                        ),

                                        // Rating Badge (Top Right)
                                        if (serie.rating != null &&
                                            serie.rating!.isNotEmpty &&
                                            serie.rating != "0")
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.star,
                                                      size: 10,
                                                      color: Colors.black),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    serie.rating!,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
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
                                                    .removeSeries(
                                                        serie.seriesId ?? "");
                                                Get.snackbar("Favorites",
                                                    "Removed from favorites",
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    colorText: Colors.white,
                                                    duration: const Duration(
                                                        seconds: 1));
                                              } else {
                                                context
                                                    .read<FavoritesCubit>()
                                                    .addSeries(serie);
                                                Get.snackbar("Favorites",
                                                    "Added to favorites",
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        kColorSuccess,
                                                    colorText: Colors.white,
                                                    duration: const Duration(
                                                        seconds: 1));
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
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
                                            serie.name ?? "",
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
