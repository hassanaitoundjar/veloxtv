part of 'screens.dart';

/// Responsive size tokens for HomeScreen — fully auto-calculated from MediaQuery.
/// No breakpoints. Every value scales smoothly from the smallest phone to a 4K TV.
class _HomeSizes {
  final double cardWidth;
  final double cardHeightLiveTv;
  final double cardHeightOther;
  final double cardGap;
  final double titleFont;
  final double countFont;
  final double greetingFont;
  final double iconBoxSize;
  final double iconSize;
  final double bottomBtnHorizontalPadding;
  final double bottomBtnVerticalPadding;
  final double bottomBtnFont;
  final double bottomBtnIconSize;
  final double bottomRowGap;
  final double portraitCardHeight;
  final double weatherIconSize;
  final double weatherTempFont;
  final double weatherTimeFont;
  final double weatherDateFont;

  const _HomeSizes({
    required this.cardWidth,
    required this.cardHeightLiveTv,
    required this.cardHeightOther,
    required this.cardGap,
    required this.titleFont,
    required this.countFont,
    required this.greetingFont,
    required this.iconBoxSize,
    required this.iconSize,
    required this.bottomBtnHorizontalPadding,
    required this.bottomBtnVerticalPadding,
    required this.bottomBtnFont,
    required this.bottomBtnIconSize,
    required this.bottomRowGap,
    required this.portraitCardHeight,
    required this.weatherIconSize,
    required this.weatherTempFont,
    required this.weatherTimeFont,
    required this.weatherDateFont,
  });

  factory _HomeSizes.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final width = size.width;
    final height = size.height;
    final isPortrait = mq.orientation == Orientation.portrait;

    // Anchor: 600 = reference "standard" screen width.
    // shortestSide gives a stable reference regardless of orientation.
    final shortestSide = size.shortestSide;
    final longestSide = size.longestSide;

    // Main scale factor — normalized to a 600dp reference.
    // Clamped so it never gets too small (phone) or too large (4K).
    final double sf = (shortestSide / 600.0).clamp(0.45, 1.8);

    // Card width: a percentage of available screen width, tuned by orientation.
    // Portrait: cards are wider (takes more of the narrow screen).
    // Landscape: cards are narrower (3 sit side by side).
    final double cardWidthRatio = isPortrait
        ? (shortestSide < 400 ? 0.88 : 0.50)
        : (longestSide > 1200 ? 0.22 : 0.28);
    final double cw = width * cardWidthRatio;

    // Card heights scale with the longest side so they use available vertical space.
    final double cardHScale = (longestSide / 900.0).clamp(0.5, 1.8);

    return _HomeSizes(
      cardWidth: cw,

      // Live TV card is taller (prominent hero card)
      cardHeightLiveTv: (300.0 * cardHScale).clamp(160.0, 560.0),
      cardHeightOther: (230.0 * cardHScale).clamp(130.0, 480.0),

      // Gap between cards
      cardGap: (18.0 * sf).clamp(8.0, 32.0),

      // Typography — scaled from base reference sizes
      titleFont: (22.0 * sf).clamp(12.0, 32.0),
      countFont: (13.0 * sf).clamp(9.0, 18.0),
      greetingFont: (22.0 * sf).clamp(10.0, 36.0),

      // Category icon circle
      iconBoxSize: (64.0 * sf).clamp(36.0, 96.0),
      iconSize: (32.0 * sf).clamp(18.0, 48.0),

      // Bottom action buttons
      bottomBtnHorizontalPadding: (22.0 * sf).clamp(10.0, 40.0),
      bottomBtnVerticalPadding: (10.0 * sf).clamp(6.0, 20.0),
      bottomBtnFont: (16.0 * sf).clamp(8.0, 22.0),
      bottomBtnIconSize: (16.0 * sf).clamp(10.0, 24.0),
      bottomRowGap: (14.0 * sf).clamp(6.0, 28.0),

      // Portrait layout card height (used in vertical scroll layout)
      portraitCardHeight: (height * 0.30).clamp(160.0, 380.0),

      // Weather widget
      weatherIconSize: (20.0 * sf).clamp(12.0, 48.0),
      weatherTempFont: (20.0 * sf).clamp(12.0, 44.0),
      weatherTimeFont: (54.0 * sf).clamp(28.0, 120.0),
      weatherDateFont: (18.0 * sf).clamp(11.0, 40.0),
    );
  }
}

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
    context.read<RecentChannelsCubit>().initialData();

    // Check for updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdates(context);
    });

    // Show first-login parental PIN notice once per user account
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFirstLoginDialog();
    });
  }

  void _showFirstLoginDialog() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;

    final userId = authState.user.id;
    final storage = GetStorage('settings');
    final key = 'first_login_shown_$userId';

    if (storage.read(key) == true) return; // Already shown
    storage.write(key, true);

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: kColorPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: kColorPrimary, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Parental Control PIN',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your default parental control PIN is:',
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  // PIN display
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: kColorPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: kColorPrimary.withValues(alpha: 0.4),
                          width: 1),
                    ),
                    child: Text(
                      '0  0  0  0',
                      style: GoogleFonts.outfit(
                        color: kColorPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You can change it anytime in Settings → Parental Control.',
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: Text('Got it',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
        decoration: const BoxDecoration(color: kColorBackgroundDark),
        child: Column(
          children: [
            // App Bar
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String expDate = "Unlimited";
                String username = "User";
                if (state is AuthSuccess) {
                  if (state.user.userInfo?.expDate != null) {
                    expDate = state.user.userInfo!.expDate!;
                  }
                  if (state.user.userInfo?.username != null) {
                    username = state.user.userInfo!.username!;
                  }
                }
                return AppBarWelcome(expiration: expDate, username: username);
              },
            ),

            // Main Content
            Expanded(
              child: Padding(
                padding: getTvSafeMargins(context),
                child: isPortrait
                    ? _buildPortraitLayout()
                    : _buildLandscapeLayout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final sizes = _HomeSizes.of(context);
    String greetingName = "User";
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      greetingName = authState.user.playlistName ??
          authState.user.userInfo?.username ??
          "User";
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
              bottom: sizes.bottomRowGap * 2.5), // A much more subtle gap
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: sizes.cardWidth,
                  child: _buildGridItem(
                    title: "Live TV's",
                    icon: FontAwesomeIcons.tv,
                    isIconData: true,
                    height: sizes.cardHeightLiveTv,
                    onTap: () => Get.toNamed(screenLiveTv),
                    blocBuilder: BlocBuilder<LiveCatyBloc, LiveCatyState>(
                      builder: (context, state) => _buildCount(state, context),
                    ),
                    autoFocus: false,
                  ),
                ),
                SizedBox(width: sizes.cardGap),
                SizedBox(
                  width: sizes.cardWidth,
                  child: _buildGridItem(
                    title: "Movies",
                    icon: FontAwesomeIcons.film,
                    isIconData: true,
                    height: sizes.cardHeightOther,
                    onTap: () => Get.toNamed(screenMovies),
                    blocBuilder: BlocBuilder<MovieCatyBloc, MovieCatyState>(
                      builder: (context, state) => _buildCount(state, context),
                    ),
                  ),
                ),
                SizedBox(width: sizes.cardGap),
                SizedBox(
                  width: sizes.cardWidth,
                  child: _buildGridItem(
                    title: "Series",
                    icon: FontAwesomeIcons.layerGroup,
                    isIconData: true,
                    height: sizes.cardHeightOther,
                    onTap: () => Get.toNamed(screenSeries),
                    blocBuilder: BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
                      builder: (context, state) => _buildCount(state, context),
                    ),
                  ),
                ),
              ],
            ),
          ), // Closes Center
        ), // Closes Padding
        const Positioned(
          bottom: 0,
          right: 16,
          child: TimeWeatherWidget(),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBottomButton("Favorites", FontAwesomeIcons.heart,
                  () => Get.toNamed(screenFavorites)),
              SizedBox(width: sizes.bottomRowGap),
              _buildBottomButton("Catch Up", FontAwesomeIcons.clockRotateLeft,
                  () => Get.to(() => const CatchUpChannelsScreen())),
              SizedBox(width: sizes.bottomRowGap),
              _buildBottomButton("Multi-View", FontAwesomeIcons.tableCellsLarge,
                  () => Get.to(() => const MultiViewScreen())),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: GoogleFonts.outfit(
                    color: Colors.white54, fontSize: sizes.greetingFont * 0.65),
              ),
              Text(
                greetingName,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: sizes.greetingFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(String title, IconData icon, VoidCallback onTap) {
    return Builder(builder: (context) {
      final sizes = _HomeSizes.of(context);
      return FocusableCard(
        onTap: onTap,
        scale: 1.05, // Slight scale effect for buttons
        showFocusBorder: false,
        builder: (context, isFocused) => Container(
          padding: EdgeInsets.symmetric(
              horizontal: sizes.bottomBtnHorizontalPadding,
              vertical: sizes.bottomBtnVerticalPadding),
          decoration: BoxDecoration(
            color:
                isFocused ? Colors.white : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isFocused ? Colors.white : Colors.white24,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: sizes.bottomBtnIconSize,
                  color: isFocused ? Colors.black : Colors.white),
              SizedBox(width: sizes.bottomBtnIconSize * 0.5),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: isFocused ? Colors.black : Colors.white,
                  fontSize: sizes.bottomBtnFont,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPortraitLayout() {
    return Builder(builder: (context) {
      final sizes = _HomeSizes.of(context);
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live TV
            _buildPortraitGridItem(
              title: "Live TV's",
              icon: FontAwesomeIcons.tv,
              isIconData: true,
              onTap: () => Get.toNamed(screenLiveTv),
              height: sizes.portraitCardHeight,
              blocBuilder: BlocBuilder<LiveCatyBloc, LiveCatyState>(
                  builder: (context, state) => _buildCount(state, context)),
            ),
            SizedBox(height: sizes.cardGap),

            // Movies
            _buildPortraitGridItem(
              title: "Movies",
              icon: FontAwesomeIcons.film,
              isIconData: true,
              onTap: () => Get.toNamed(screenMovies),
              height: sizes.portraitCardHeight,
              blocBuilder: BlocBuilder<MovieCatyBloc, MovieCatyState>(
                  builder: (context, state) => _buildCount(state, context)),
            ),
            SizedBox(height: sizes.cardGap),

            // Series
            _buildPortraitGridItem(
              title: "Series",
              icon: FontAwesomeIcons.layerGroup,
              isIconData: true,
              onTap: () => Get.toNamed(screenSeries),
              height: sizes.portraitCardHeight,
              blocBuilder: BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
                  builder: (context, state) => _buildCount(state, context)),
            ),

            SizedBox(height: sizes.cardGap * 2),
            const Divider(color: Colors.white24),
            SizedBox(height: sizes.cardGap * 2),

            const SizedBox(height: 50), // Bottom padding
          ],
        ),
      );
    });
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
          height: height,
          blocBuilder: blocBuilder),
    );
  }

  Widget _buildCount(dynamic state, BuildContext context) {
    final sizes = _HomeSizes.of(context);
    final style = GoogleFonts.outfit(
        color: Colors.white54,
        fontSize: sizes.countFont,
        fontWeight: FontWeight.w500);

    if (state is LiveCatySuccess) {
      return Text("${state.categories.length} Categories", style: style);
    }
    if (state is MovieCatySuccess) {
      return Text("${state.categories.length} Movies", style: style);
    }
    if (state is SeriesCatySuccess) {
      return Text("${state.categories.length} Series", style: style);
    }
    return Text("Loading...", style: style);
  }

  Widget _buildGridItem({
    required String title,
    required dynamic icon,
    required VoidCallback onTap,
    Widget? blocBuilder,
    bool isIconData = false,
    bool autoFocus = false,
    double? height,
  }) {
    return Builder(builder: (context) {
      final sizes = _HomeSizes.of(context);
      return FocusableCard(
        onTap: onTap,
        autoFocus: autoFocus,
        scale: 1.0,
        showFocusBorder: false,
        builder: (context, isFocused) => Container(
          margin: MediaQuery.of(context).size.width < 900
              ? const EdgeInsets.only(bottom: 20)
              : EdgeInsets.zero,
          height: height ?? 200,
          decoration: BoxDecoration(
            gradient: isFocused
                ? const LinearGradient(
                    colors: [
                      Color(0xFF265eb4),
                      Color(0xFF1b222c),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )
                : const LinearGradient(
                    colors: [
                      Color(0xFF202631),
                      Color(0xFF101318),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFocused ? Colors.white : Colors.transparent,
              width: isFocused ? 2.0 : 0.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: sizes.iconBoxSize,
                      height: sizes.iconBoxSize,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: isIconData
                          ? Icon(icon as IconData,
                              size: sizes.iconSize, color: Colors.white)
                          : Image.asset(icon as String,
                              width: sizes.iconSize * 1.2,
                              height: sizes.iconSize * 1.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: sizes.titleFont,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (blocBuilder != null) ...[
                      const SizedBox(height: 4),
                      blocBuilder,
                    ],
                    const SizedBox(
                        height: 24), // Push it slightly up from the bottom row
                  ],
                ),
              ),
              Row(
                children: [
                  if (MediaQuery.of(context).size.width >= 900)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "NEVER RELOADED",
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (MediaQuery.of(context).size.width >= 900) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.refresh,
                          color: Colors.white54, size: 16),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class TimeWeatherWidget extends StatefulWidget {
  const TimeWeatherWidget({super.key});

  @override
  State<TimeWeatherWidget> createState() => _TimeWeatherWidgetState();
}

class _TimeWeatherWidgetState extends State<TimeWeatherWidget> {
  String _temperature = "--°";
  IconData _weatherIcon = Icons.cloud_outlined;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final dio = Dio();

      // 1. Get Location
      final geoResponse = await dio.get('https://get.geojs.io/v1/ip/geo.json');
      final lat = geoResponse.data['latitude'];
      final lon = geoResponse.data['longitude'];

      if (lat != null && lon != null) {
        // 2. Get Weather
        final weatherResponse = await dio.get(
            'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');

        if (weatherResponse.statusCode == 200) {
          final current = weatherResponse.data['current_weather'];
          final temp = current['temperature'];
          final weatherCode = current['weathercode'] as int?;

          if (mounted) {
            setState(() {
              _temperature = "${temp.round()}°";

              // Simple weather code mapping to icons
              if (weatherCode != null) {
                if (weatherCode <= 1) {
                  _weatherIcon = Icons.wb_sunny_outlined; // Clear
                } else if (weatherCode <= 3) {
                  _weatherIcon = Icons.cloud_outlined; // Cloudy
                } else if (weatherCode >= 51 && weatherCode <= 67) {
                  _weatherIcon = Icons.water_drop_outlined; // Rain
                } else if (weatherCode >= 71 && weatherCode <= 82) {
                  _weatherIcon = Icons.ac_unit; // Snow
                } else if (weatherCode >= 95) {
                  _weatherIcon = Icons.thunderstorm_outlined; // Storm
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _HomeSizes.of(context);
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final hour = now.hour.toString().padLeft(2, '0');
        final minute = now.minute.toString().padLeft(2, '0');

        const weekdays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];

        final weekday = weekdays[now.weekday - 1];
        final month = months[now.month - 1];
        final day = now.day;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_weatherIcon,
                    color: Colors.white, size: sizes.weatherIconSize),
                const SizedBox(width: 8),
                Text(
                  _temperature,
                  style: GoogleFonts.outfit(
                    color: Colors.orangeAccent.shade100,
                    fontSize: sizes.weatherTempFont,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "$hour:$minute",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: sizes.weatherTimeFont,
                fontWeight: FontWeight.w300,
                letterSpacing: -2,
                height: 1.1,
              ),
            ),
            Text(
              "$weekday, $month $day",
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: sizes.weatherDateFont,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
