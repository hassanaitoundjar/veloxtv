part of 'screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data logic
    context.read<LiveCatyBloc>().add(GetLiveCategories());
    context.read<MovieCatyBloc>().add(GetMovieCategories());
    context.read<SeriesCatyBloc>().add(GetSeriesCategories());
    context.read<FavoritesCubit>().initialData();
  }

  @override
  Widget build(BuildContext context) {
    // Detect if we are on a phone/portrait mode
    final isPortrait = MediaQuery.of(context).size.width < 600 ||
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Column(
          children: [
            // App Bar
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String expDate = "Unlimited";
                if (state is AuthSuccess &&
                    state.user.userInfo?.expDate != null) {
                  // Format date logic here if needed
                  expDate = state.user.userInfo!.expDate!;
                }
                return AppBarWelcome(expiration: expDate);
              },
            ),

            // Main Content
            Expanded(
              child: Padding(
                padding: getTvSafeMargins(context),
                child: isPortrait
                    ? _buildPortraitLayout()
                    : _buildLandscapeLayout(),
              ),
            ),

            // Bottom Status Bar: Username & Expiration
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String username = "";
                String expDate = "Unlimited";
                if (state is AuthSuccess) {
                  username = state.user.userInfo?.username ?? "User";
                  expDate = state.user.userInfo?.expDate ?? "Unlimited";
                }
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: kColorCardLight.withValues(alpha: 0.15),
                    border: const Border(
                      top: BorderSide(color: Colors.white10, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bottom Left: Expiration Date
                      Row(
                        children: [
                          Text(
                            "Expiration date: ${formatExpiration(expDate)}",
                            style: Get.textTheme.bodySmall
                                ?.copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                      
                      // Bottom Right: Username
                      Row(
                        children: [
                          Text(
                            "Username: $username",
                            style: Get.textTheme.bodySmall
                                ?.copyWith(color: Colors.white54, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Column(
      children: [
              // ROW 1: LIVE, MOVIES, SERIES
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildGridItem(
                        title: "Live TV",
                        icon: FontAwesomeIcons.tv,
                        isIconData: true,
                        onTap: () => Get.toNamed(screenLiveTv),
                        blocBuilder: BlocBuilder<LiveCatyBloc, LiveCatyState>(
                          builder: (context, state) => _buildCount(state),
                        ),
                        autoFocus: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildGridItem(
                        title: "Movies",
                        icon: FontAwesomeIcons.film,
                        isIconData: true,
                        onTap: () => Get.toNamed(screenMovies),
                        blocBuilder: BlocBuilder<MovieCatyBloc, MovieCatyState>(
                          builder: (context, state) => _buildCount(state),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildGridItem(
                        title: "Series",
                        icon: FontAwesomeIcons.layerGroup,
                        isIconData: true,
                        onTap: () => Get.toNamed(screenSeries),
                        blocBuilder:
                            BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
                          builder: (context, state) => _buildCount(state),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ROW 2: CATCH UP, EPG, FAVORITES
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildGridItem(
                        title: "Catch Up",
                        icon: FontAwesomeIcons.clockRotateLeft,
                        isIconData: true,
                        onTap: () => Get.toNamed(screenLiveTv),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildGridItem(
                        title: "Multi-View",
                        icon: FontAwesomeIcons.tableCellsLarge,
                        isIconData: true,
                        onTap: () {
                          Get.to(() => const MultiViewScreen());
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildGridItem(
                        title: "Favorites",
                        icon: FontAwesomeIcons.heart,
                        isIconData: true,
                        onTap: () => Get.toNamed(screenFavorites),
                      ),
                    ),
                  ],
                ),
              ),
            ],
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live TV
          _buildPortraitGridItem(
            title: "Live TV",
            icon: FontAwesomeIcons.tv,
            isIconData: true,
            onTap: () => Get.toNamed(screenLiveTv),
            blocBuilder: BlocBuilder<LiveCatyBloc, LiveCatyState>(
                builder: (context, state) => _buildCount(state)),
          ),
          const SizedBox(height: 12),

          // Movies
          _buildPortraitGridItem(
            title: "Movies",
            icon: FontAwesomeIcons.film,
            isIconData: true,
            onTap: () => Get.toNamed(screenMovies),
            blocBuilder: BlocBuilder<MovieCatyBloc, MovieCatyState>(
                builder: (context, state) => _buildCount(state)),
          ),
          const SizedBox(height: 12),

          // Series
          _buildPortraitGridItem(
            title: "Series",
            icon: FontAwesomeIcons.layerGroup,
            isIconData: true,
            onTap: () => Get.toNamed(screenSeries),
            blocBuilder: BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
                builder: (context, state) => _buildCount(state)),
          ),
          const SizedBox(height: 12),

          // Row for Catch Up & EPG
          Row(
            children: [
              Expanded(
                  child: _buildPortraitGridItem(
                      title: "Catch Up",
                      icon: FontAwesomeIcons.clockRotateLeft,
                      isIconData: true,
                      onTap: () => Get.toNamed(screenLiveTv),
                      height: 100)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildPortraitGridItem(
                      title: "Multi-View",
                      icon: FontAwesomeIcons.tableCellsLarge,
                      isIconData: true,
                      onTap: () => Get.to(() => const MultiViewScreen()),
                      height: 100)),
            ],
          ),
          const SizedBox(height: 12),

          // Favorites
          _buildPortraitGridItem(
              title: "Favorites",
              icon: FontAwesomeIcons.heart,
              isIconData: true,
              onTap: () => Get.toNamed(screenFavorites),
              height: 80),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 24),

          const SizedBox(height: 50), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildPortraitGridItem({
    required String title,
    required dynamic icon,
    required VoidCallback onTap,
    Widget? blocBuilder,
    bool isIconData = false,
    double height = 120,
  }) {
    return SizedBox(
      height: height,
      child: _buildGridItem(
          title: title,
          icon: icon,
          onTap: onTap,
          isIconData: isIconData,
          blocBuilder: blocBuilder),
    );
  }

  Widget _buildCount(dynamic state) {
    if (state is LiveCatySuccess)
      return Text("${state.categories.length} Categories", style: _countStyle);
    if (state is MovieCatySuccess)
      return Text("${state.categories.length} Movies", style: _countStyle);
    if (state is SeriesCatySuccess)
      return Text("${state.categories.length} Series", style: _countStyle);
    return Text("Loading...", style: _countStyle);
  }

  TextStyle get _countStyle =>
      Get.textTheme.bodyMedium!.copyWith(color: kColorTextSecondary);

  Widget _buildGridItem({
    required String title,
    required dynamic icon,
    required VoidCallback onTap,
    Widget? blocBuilder,
    bool isIconData = false,
    bool autoFocus = false,
  }) {
    // Removed Expanded wrapper
    return FocusableCard(
      onTap: onTap,
      autoFocus: autoFocus,
      scale: 1.05,
      child: Container(
        decoration: kDecorCard.copyWith(
          color: kColorCardLight.withOpacity(0.1),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isIconData)
              Icon(icon as IconData, size: 40, color: Colors.white)
            else
              Image.asset(icon as String, width: 60, height: 60),
            const SizedBox(height: 16),
            Text(title,
                style: Get.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            if (blocBuilder != null) ...[
              const SizedBox(height: 8),
              blocBuilder,
            ]
          ],
        ),
      ),
    );
  }

}
