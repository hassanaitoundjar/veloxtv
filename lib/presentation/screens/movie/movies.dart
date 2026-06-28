part of '../screens.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
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
    // If navigated with a category argument, use it
    if (Get.arguments is CategoryModel) {
      _selectedCategory = Get.arguments as CategoryModel;
      context.read<ChannelsBloc>().add(
          GetChannels(_selectedCategory!.categoryId!, TypeCategory.movies));
      _initialized = true;
    }
  }

  void _initWithFirstCategory(List<CategoryModel> categories) {
    if (!_initialized && categories.isNotEmpty) {
      // For first load, we might skip parental check or check it?
      // Usually first category is "All" or something safe.
      // If we auto-select an adult category on load, we should probably block or just not select.
      // For now, let's just select but maybe we should check.
      // But _checkParentalControl requires context/dialog which might not work well in build/init.
      // Let's assume first category is safe or allowed for now.
      // Find first safe category
      final firstSafe = categories.firstWhere(
        (c) => !_isRestricted(c),
        orElse: () => categories.first,
      );

      // Only auto-select if safe. If all are restricted, user sees blank list until they click.
      if (!_isRestricted(firstSafe)) {
        _selectedCategory = firstSafe;
        context.read<ChannelsBloc>().add(
            GetChannels(_selectedCategory!.categoryId!, TypeCategory.movies));
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

  void _checkMovieAccess(String? name, VoidCallback onAllowed) {
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

  Widget _buildMoviesGrid(List<ChannelMovie> movies, FavoritesState favState, double gridPadding, double gridSpacing, bool isPhone) {
    return GridView.builder(
      padding: EdgeInsets.all(gridPadding),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getGridColumns(context).toInt(),
        childAspectRatio: 0.65,
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final isFav = favState is FavoritesSuccess &&
            favState.movies.any(
                (m) => m.streamId == movie.streamId);
        return FocusableCard(
          onTap: () {
            _checkMovieAccess(movie.name, () {
              Get.toNamed(screenMovieDetails,
                  arguments: movie);
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
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // Rating Badge (Top Right)
              if (movie.rating != null &&
                  movie.rating!.isNotEmpty)
                Positioned(
                  top: isPhone ? 4 : 8,
                  right: isPhone ? 4 : 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isPhone ? 4 : 8,
                        vertical: isPhone ? 2 : 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius:
                          BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star,
                            color: Colors.amber,
                            size: isPhone ? 10 : 14),
                        SizedBox(
                            width: isPhone ? 2 : 4),
                        Text(
                          movie.rating!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  isPhone ? 10 : 12,
                              fontWeight:
                                  FontWeight.bold),
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
                          .removeMovie(
                              movie.streamId ?? "");
                    } else {
                      context
                          .read<FavoritesCubit>()
                          .addMovie(movie);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(
                        isPhone ? 4 : 6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
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
                  movie.name ?? "",
                  style: Get.textTheme.bodySmall
                      ?.copyWith(
                    fontWeight: FontWeight.normal,
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
            AppBarLive(
              onSearch: (val) {
                setState(() => _searchQuery = val.toLowerCase());
                if (_searchQuery.isNotEmpty) {
                  // Fetch all movies for global search
                  context
                      .read<ChannelsBloc>()
                      .add(GetChannels(null, TypeCategory.movies));
                } else {
                  // Restore selected category
                  if (_selectedCategory != null) {
                    context.read<ChannelsBloc>().add(GetChannels(
                        _selectedCategory!.categoryId!, TypeCategory.movies));
                  }
                }
              },
              focusNode: _searchFocusNode,
            ),

            // Main Content Row
            Expanded(
              child: Row(
                children: [
                  // Left - Vertical Categories
                  BlocBuilder<MovieCatyBloc, MovieCatyState>(
                    builder: (context, state) {
                      if (state is MovieCatySuccess) {
                        // Auto-select first category if not yet initialized
                        _initWithFirstCategory(state.categories);

                        return BlocBuilder<FavoritesCubit, FavoritesState>(
                          builder: (context, favState) {
                            final favCount = favState is FavoritesSuccess ? favState.movies.length : 0;
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
                                        cat.categoryId!, TypeCategory.movies));
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

                  // Right - Movie Poster Grid
                  Expanded(
                    child: _selectedCategory?.categoryId == "favorites" 
                      ? BlocBuilder<FavoritesCubit, FavoritesState>(
                          builder: (context, favState) {
                            if (favState is FavoritesLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (favState is FavoritesSuccess) {
                              var movies = List<ChannelMovie>.from(favState.movies);
                              if (_searchQuery.isNotEmpty) {
                                movies = movies
                                    .where((m) => (m.name
                                            ?.toLowerCase()
                                            .contains(_searchQuery) ??
                                        false))
                                    .toList();
                              }
                              if (movies.isEmpty) {
                                return const Center(child: Text("No favorite movies"));
                              }
                              return _buildMoviesGrid(movies, favState, gridPadding, gridSpacing, isPhone);
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
                                state.type == TypeCategory.movies) {
                              var movies = List<ChannelMovie>.from(state.channels);

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

                              return BlocBuilder<FavoritesCubit, FavoritesState>(
                                builder: (context, favState) {
                                  return _buildMoviesGrid(movies, favState, gridPadding, gridSpacing, isPhone);
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
