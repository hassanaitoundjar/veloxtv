part of '../screens.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  CategoryModel? _selectedCategory;
  late FocusNode _searchFocusNode;
  String _searchQuery = "";
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          FocusScope.of(context).focusInDirection(TraversalDirection.right);
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    });
    if (Get.arguments is CategoryModel) {
      _selectedCategory = Get.arguments as CategoryModel;
      context.read<ChannelsBloc>().add(
          GetChannels(_selectedCategory!.categoryId!, TypeCategory.series));
      _initialized = true;
    }
  }

  void _initWithFirstCategory(List<CategoryModel> categories) {
    if (!_initialized && categories.isNotEmpty) {
      // Find first safe category
      final firstSafe = categories.firstWhere(
        (c) => !_isRestricted(c),
        orElse: () => categories.first,
      );

      if (!_isRestricted(firstSafe)) {
        _selectedCategory = firstSafe;
        context.read<ChannelsBloc>().add(
            GetChannels(_selectedCategory!.categoryId!, TypeCategory.series));
        _initialized = true;
      }
    }
  }

  bool _isRestrictedName(String? name) {
    if (name == null) return false;
    final lower = name.toLowerCase();
    return lower.contains("adult") ||
        lower.contains("porn") ||
        lower.contains("xxx") ||
        lower.contains("18+") ||
        lower.contains("sex") ||
        lower.contains("xx ");
  }

  bool _isRestricted(CategoryModel category) {
    if (!_isRestrictedName(category.categoryName)) return false;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return true;
    final userId = authState.user.id;
    final storage = GetStorage("settings");
    final enabled = storage.read("parental_control_enabled_$userId") ?? true;
    return enabled;
  }

  void _checkSeriesAccess(String? name, VoidCallback onAllowed) {
    if (!_isRestrictedName(name)) {
      onAllowed();
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;
    final userId = authState.user.id;
    final storage = GetStorage("settings");
    final enabled = storage.read("parental_control_enabled_$userId") ?? true;

    if (!enabled) {
      onAllowed();
      return;
    }

    Get.dialog(
      ParentalControlWidget(
        userId: userId,
        mode: ParentalMode.verify,
        onVerifySuccess: onAllowed,
      ),
    );
  }

  void _checkParentalControl(CategoryModel category, VoidCallback onAllowed) {
    if (_isRestricted(category)) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthSuccess) return;
      Get.dialog(
        ParentalControlWidget(
          userId: authState.user.id,
          mode: ParentalMode.verify,
          onVerifySuccess: onAllowed,
        ),
      );
    } else {
      onAllowed();
    }
  }

  Widget _buildSeriesGrid(List<ChannelSerie> seriesList, FavoritesState favState, double gridPadding, double gridSpacing, bool isPhone) {
    return GridView.builder(
      padding: EdgeInsets.all(gridPadding),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getGridColumns(context).toInt(),
        childAspectRatio: 0.65, // Taller poster ratio
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing,
      ),
      itemCount: seriesList.length,
      itemBuilder: (context, index) {
        final serie = seriesList[index];

        final isFav = favState is FavoritesSuccess &&
            favState.series.any(
                (s) => s.seriesId == serie.seriesId);

        return FocusableCard(
          onTap: () {
            _checkSeriesAccess(serie.name, () {
              Get.toNamed(screenSeriesDetails,
                  arguments: serie);
            });
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
                      Colors.black.withValues(alpha: 0.8)
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
                  top: isPhone ? 4 : 8,
                  right: isPhone ? 4 : 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isPhone ? 4 : 6,
                        vertical: isPhone ? 2 : 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius:
                          BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star,
                            size: isPhone ? 8 : 10,
                            color: Colors.black),
                        SizedBox(
                            width: isPhone ? 2 : 2),
                        Text(
                          serie.rating!,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize:
                                isPhone ? 8 : 10,
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
                top: isPhone ? 4 : 8,
                left: isPhone ? 4 : 8,
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
                    padding: EdgeInsets.all(
                        isPhone ? 4 : 4),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFav
                          ? Colors.blue
                          : Colors.white70,
                      size: isPhone ? 14 : 18,
                    ),
                  ),
                ),
              ),

              // Title at Bottom
              Positioned(
                bottom: isPhone ? 4 : 8,
                left: isPhone ? 4 : 8,
                right: isPhone ? 4 : 8,
                child: Text(
                  serie.name ?? "",
                  style: Get.textTheme.bodySmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: isPhone ? 10 : null,
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
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final gridPadding = isPhone ? 8.0 : 16.0;
    final gridSpacing = isPhone ? 8.0 : 16.0;

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
              focusNode: _searchFocusNode,
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

                        return BlocBuilder<FavoritesCubit, FavoritesState>(
                          builder: (context, favState) {
                            final favCount = favState is FavoritesSuccess ? favState.series.length : 0;
                            final favoritesCategory = CategoryModel(
                              categoryId: "favorites",
                              categoryName: "Favorites ($favCount)",
                            );
                            
                            final combinedList = [favoritesCategory, ...state.categories];

                            return SideCategoryMenu(
                              categories: combinedList,
                              selectedId: _selectedCategory?.categoryId ?? "0",
                              onSelect: (cat) {
                                _checkParentalControl(cat, () {
                                  setState(() {
                                    _selectedCategory = cat;
                                  });
                                  if (cat.categoryId != "favorites") {
                                    context.read<ChannelsBloc>().add(GetChannels(
                                        cat.categoryId!, TypeCategory.series));
                                  }
                                });
                              },
                            );
                          }
                        );
                      }
                      return SizedBox(width: isPhone ? 35.w : 25.w);
                    },
                  ),

                  // Right - Series Poster Grid
                  Expanded(
                    child: _selectedCategory?.categoryId == "favorites" 
                      ? BlocBuilder<FavoritesCubit, FavoritesState>(
                          builder: (context, favState) {
                            if (favState is FavoritesLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (favState is FavoritesSuccess) {
                              var seriesList = List<ChannelSerie>.from(favState.series);
                              if (_searchQuery.isNotEmpty) {
                                seriesList = seriesList
                                    .where((s) => (s.name
                                            ?.toLowerCase()
                                            .contains(_searchQuery) ??
                                        false))
                                    .toList();
                              }
                              if (seriesList.isEmpty) {
                                return const Center(child: Text("No favorite series"));
                              }
                              return _buildSeriesGrid(seriesList, favState, gridPadding, gridSpacing, isPhone);
                            }
                            return const SizedBox();
                          },
                        )
                      : BlocBuilder<ChannelsBloc, ChannelsState>(
                          builder: (context, state) {
                            if (state is ChannelsLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (state is ChannelsSuccess &&
                                state.type == TypeCategory.series) {
                              var seriesList =
                                  List<ChannelSerie>.from(state.channels);

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

                              return BlocBuilder<FavoritesCubit, FavoritesState>(
                                builder: (context, favState) {
                                  return _buildSeriesGrid(seriesList, favState, gridPadding, gridSpacing, isPhone);
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
