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
    try {
      final details = await IpTvApi.getSerieDetails(_serie.seriesId!);
      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Episode? _getFirstEpisode() {
    if (_details?.seasons == null || _details!.seasons!.isEmpty) return null;
    if (_details?.episodes == null) return null;
    final firstSeason = _details!.seasons!.first;
    final seasonNum = firstSeason.seasonNumber.toString();
    final episodes = _details!.episodes?[seasonNum];
    if (episodes != null && episodes.isNotEmpty) return episodes.first;
    return null;
  }

  List<Episode> _getCurrentEpisodes() {
    if (_details?.seasons == null || _details!.seasons!.isEmpty) return [];
    final seasonNum =
        _details!.seasons![_selectedSeasonIndex].seasonNumber.toString();
    return _details!.episodes?[seasonNum] ?? [];
  }

  String _cleanEpisodeTitle(String? rawTitle, int? episodeNum) {
    final epLabel = episodeNum != null ? 'Ep $episodeNum' : 'Episode';
    if (rawTitle == null || rawTitle.isEmpty) return epLabel;
    final serieName = _serie.name ?? '';
    String cleaned = rawTitle;
    if (serieName.isNotEmpty && cleaned.startsWith(serieName)) {
      cleaned = cleaned
          .substring(serieName.length)
          .replaceFirst(RegExp(r'^\s*[-–]\s*'), '')
          .trim();
    }
    if (cleaned.isEmpty ||
        RegExp(r'^S\d+E\d+$', caseSensitive: false).hasMatch(cleaned)) {
      return episodeNum != null ? 'Ep $episodeNum' : epLabel;
    }
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: kColorPrimary,
                size: 50,
              ),
            )
          : CustomScrollView(
              slivers: [
                // ── Hero Header ──────────────────────────────────────────
                SliverToBoxAdapter(child: _buildHeroHeader()),
                // ── Episodes Section ─────────────────────────────────────
                if (_details?.seasons != null &&
                    _details!.seasons!.isNotEmpty) ...[
                  SliverToBoxAdapter(child: _buildEpisodesHeader()),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final episodes = _getCurrentEpisodes();
                        if (index >= episodes.length) return null;
                        return _buildEpisodeTile(episodes[index], index);
                      },
                      childCount: _getCurrentEpisodes().length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ],
            ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HERO HEADER  (backdrop + title + meta + buttons + cast/genre)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Real unique backdrop images from the API
    final realBackdrops =
        _details?.info?.backdropPath?.where((u) => u.isNotEmpty).toList() ?? [];

    // Show mosaic only if we have at least 2 real different images AND not on a phone
    final showMosaic = realBackdrops.length >= 2 && !isPhone;

    // Single-image fallback (cover or first backdrop)
    final singleBackdrop =
        realBackdrops.isNotEmpty ? realBackdrops.first : (_serie.cover ?? '');

    // For mosaic, pad to 6 cells using only real backdrops (cycling)
    final mosaicImages = showMosaic
        ? List.generate(6, (i) => realBackdrops[i % realBackdrops.length])
        : <String>[];

    return SizedBox(
      height: isPhone
          ? (isLandscape ? screenH * 0.9 : screenH * 0.55)
          : screenH * 0.65,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Solid dark background ──────────────────────────────────
          Container(color: const Color(0xFF0D0D14)),

          if (showMosaic) ...[
            // ── Mosaic of backdrop images (right ~60%) ───────────────
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              width: isPhone ? screenW * 0.6 : screenW * 0.58,
              child: Row(
                children: [
                  // Left column — 2 tall images
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _mosaicTile(mosaicImages[0])),
                        const SizedBox(height: 2),
                        Expanded(child: _mosaicTile(mosaicImages[1])),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Middle column — 3 shorter images
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _mosaicTile(mosaicImages[2])),
                        const SizedBox(height: 2),
                        Expanded(child: _mosaicTile(mosaicImages[3])),
                        const SizedBox(height: 2),
                        Expanded(child: _mosaicTile(mosaicImages[4])),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Right column — slightly darker
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                            child: _mosaicTile(mosaicImages[5],
                                darkOverlay: 0.35)),
                        const SizedBox(height: 2),
                        Expanded(
                            child: _mosaicTile(mosaicImages[0],
                                darkOverlay: 0.45)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // ── Single full-width backdrop fallback ──────────────────
            CachedNetworkImage(
              imageUrl: singleBackdrop,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFF1A1A2E),
                child: const Icon(Icons.movie, size: 80, color: Colors.white12),
              ),
            ),
          ],

          // ── Gradient: left dark panel blending into mosaic ───────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF0D0D14),
                    const Color(0xFF0D0D14).withValues(alpha: 0.92),
                    const Color(0xFF0D0D14).withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.30, 0.50, 0.75],
                ),
              ),
            ),
          ),

          // ── Bottom fade into page background ────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0D0D14).withValues(alpha: 0.7),
                    const Color(0xFF0D0D14),
                  ],
                  stops: const [0.4, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // ── Back Button ──────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: MediaQuery.of(context).padding.left + 16,
            child: FocusableCard(
              onTap: () => Get.back(),
              scale: 1.1,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
          ),

          // ── Text & Buttons (bottom-left aligned) ────────────────────
          Positioned(
            left: MediaQuery.of(context).padding.left + (isPhone ? 16 : 32),
            right: isPhone ? screenW * 0.28 + 24 : screenW * 0.40,
            top: isPhone
                ? MediaQuery.of(context).padding.top + 64
                : null, // bounded on phone so title is never clipped
            bottom: isPhone ? 16 : 24,
            child: isPhone
                // On phone: use a Column inside a scroll view so content
                // is anchored at the top of the bounded area, not bottom
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title always visible at top
                        Text(
                          _serie.name ?? 'Unknown Series',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                            shadows: [
                              Shadow(
                                  color: Colors.black87,
                                  blurRadius: 12,
                                  offset: Offset(0, 2))
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Spacer pushes meta + buttons to bottom
                        const SizedBox(height: 16),
                        _buildMetaBadges(isPhone),
                        const SizedBox(height: 8),
                        if (_details?.info?.plot != null) ...[
                          Text(
                            _details!.info!.plot!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: isPhone ? 9 : 12,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],
                        _buildActionButtons(isPhone),
                        const SizedBox(height: 6),
                        _buildCastGenre(isPhone),
                      ],
                    ),
                  )
                // On tablet/TV: original bottom-anchored column
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _serie.name ?? 'Unknown Series',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                          shadows: [
                            Shadow(
                                color: Colors.black87,
                                blurRadius: 12,
                                offset: Offset(0, 2))
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      _buildMetaBadges(isPhone),
                      const SizedBox(height: 12),
                      if (_details?.info?.plot != null)
                        Text(
                          _details!.info!.plot!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 20),
                      _buildActionButtons(isPhone),
                      const SizedBox(height: 14),
                      _buildCastGenre(isPhone),
                    ],
                  ),
          ),

          // ── Poster image (right side) ────────────────
          Positioned(
            right: isPhone ? 60 : 80,
            bottom: isPhone ? 16 : 24,
            top: isPhone ? MediaQuery.of(context).padding.top + 64 : 40,
            width: isPhone ? screenW * 0.28 : screenW * 0.22,
            child: Align(
              alignment: Alignment.centerRight,
              child: Hero(
                tag: _serie.seriesId ?? 'hero-poster',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 24,
                        spreadRadius: 4,
                        offset: const Offset(-6, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: _serie.cover ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFF1E1E2E),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFF1E1E2E),
                        child: const Icon(Icons.movie,
                            size: 60, color: Colors.white24),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaBadges(bool isPhone) {
    final year = _details?.info?.releaseDate?.split('-').first;
    final seasonsCount = _details?.seasons?.length;
    final rating = _details?.info?.rating ?? _serie.rating;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Match %
        if (rating != null && rating.isNotEmpty && rating != '0')
          _Badge(
            label: '${_parseRatingPercent(rating)}% Match',
            color: const Color(0xFF46D369),
            textColor: Colors.white,
          ),

        // Year
        if (year != null)
          Text(year,
              style:
                  TextStyle(color: Colors.white70, fontSize: isPhone ? 8 : 14)),

        // Seasons count
        if (seasonsCount != null && seasonsCount > 0)
          Text('$seasonsCount Season${seasonsCount > 1 ? 's' : ''}',
              style: TextStyle(
                  color: Colors.white70, fontSize: isPhone ? 12 : 14)),

        // HD badge
        const _Badge(
          label: 'HD',
          color: Colors.transparent,
          textColor: Colors.white70,
          border: true,
        ),
      ],
    );
  }

  /// Single cell of the backdrop mosaic
  Widget _mosaicTile(String url, {double darkOverlay = 0.15}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) =>
              Container(color: const Color(0xFF1A1A2E)),
        ),
        if (darkOverlay > 0)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: darkOverlay),
            ),
          ),
      ],
    );
  }

  String _parseRatingPercent(String rating) {
    final val = double.tryParse(rating) ?? 0.0;
    if (val <= 10) return (val * 10).toStringAsFixed(0);
    return val.toStringAsFixed(0);
  }

  Future<NextMediaInfo?> _buildNextMediaInfo(int currentSeasonIndex, int currentEpisodeIndex, UserModel userAuth) async {
    Episode? nextEpisode;
    int nextSeasonIndex = currentSeasonIndex;
    int nextEpisodeIndex = currentEpisodeIndex + 1;
    
    final seasons = _details?.seasons;
    if (seasons != null && seasons.isNotEmpty) {
      final currentSeasonNum = seasons[currentSeasonIndex].seasonNumber.toString();
      final currentSeasonEpisodes = _details!.episodes?[currentSeasonNum] ?? [];
      
      if (nextEpisodeIndex < currentSeasonEpisodes.length) {
        nextEpisode = currentSeasonEpisodes[nextEpisodeIndex];
      } else if (currentSeasonIndex + 1 < seasons.length) {
        nextSeasonIndex = currentSeasonIndex + 1;
        nextEpisodeIndex = 0;
        final nextSeasonNum = seasons[nextSeasonIndex].seasonNumber.toString();
        final nextSeasonEpisodes = _details!.episodes?[nextSeasonNum] ?? [];
        if (nextSeasonEpisodes.isNotEmpty) {
          nextEpisode = nextSeasonEpisodes.first;
        }
      }
    }

    if (nextEpisode == null) return null;

    final link = '${userAuth.serverInfo!.serverUrl}/series/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${nextEpisode.id}.${nextEpisode.containerExtension}';
    final title = nextEpisode.title ?? '';
    
    return NextMediaInfo(
      link: link,
      title: title,
      onNextEpisodeAsync: () => _buildNextMediaInfo(nextSeasonIndex, nextEpisodeIndex, userAuth),
    );
  }

  void _playEpisode(Episode episode, int seasonIndex, int episodeIndex, UserModel userAuth) {
    final link = '${userAuth.serverInfo!.serverUrl}/series/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${episode.id}.${episode.containerExtension}';
    final title = episode.title ?? '';

    ExternalPlayerService.play(
      context: context,
      url: link,
      title: title,
      openBuiltIn: () {
        Get.to(
          () => MediaKitPlayerScreen(
            link: link,
            title: title,
            onNextEpisodeAsync: () => _buildNextMediaInfo(seasonIndex, episodeIndex, userAuth),
          ),
          preventDuplicates: false,
        )!.then((slider) {
          if (slider != null && slider is List && slider.isNotEmpty) {
            final model = WatchingModel(
              sliderValue: slider[0],
              durationStrm: slider[1] ?? 0.0,
              stream: link,
              title: title,
              image: _details?.info?.cover ?? '',
              streamId: episode.id.toString(),
            );
            if (!mounted) return;
            context.read<WatchingCubit>().addSerie(model);
          }
        });
      },
    );
  }

  Widget _buildActionButtons(bool isPhone) {
    final firstEpisode = _getFirstEpisode();

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Wrap(
          spacing: isPhone ? 10 : 12,
          runSpacing: 6,
          children: [
            // Play S1:E1
            if (firstEpisode != null && state is AuthSuccess)
              PlayButton(
                label: 'Play S1:E1',
                autoFocus: true,
                isPhone: isPhone,
                onTap: () {
                  final userAuth = (state).user;
                  _playEpisode(firstEpisode, 0, 0, userAuth);
                },
              ),

            // Add to Favourites
            FavoriteButton(
              type: FavoriteItemType.series,
              item: _serie,
              isPhone: isPhone,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCastGenre(bool isPhone) {
    final cast = _details?.info?.cast;
    final genre = _details?.info?.genre;
    if (cast == null && genre == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cast != null && cast.isNotEmpty)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Cast: ',
                  style: TextStyle(
                      color: Colors.white38, fontSize: isPhone ? 11 : 13),
                ),
                TextSpan(
                  text: cast.split(',').take(4).join(', '),
                  style: TextStyle(
                      color: Colors.white70, fontSize: isPhone ? 11 : 13),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (cast != null && genre != null) const SizedBox(height: 4),
        if (genre != null && genre.isNotEmpty)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Genres: ',
                  style: TextStyle(
                      color: Colors.white38, fontSize: isPhone ? 9 : 13),
                ),
                TextSpan(
                  text: genre,
                  style: TextStyle(
                      color: Colors.white70, fontSize: isPhone ? 9 : 13),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // EPISODES HEADER  (title + Season dropdown)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildEpisodesHeader() {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final seasons = _details!.seasons!;
    final currentSeason = seasons[_selectedSeasonIndex];

    return Padding(
      padding: EdgeInsets.fromLTRB(isPhone ? 16 : 32, 0, isPhone ? 16 : 32, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Episodes',
            style: TextStyle(
              color: Colors.white,
              fontSize: isPhone ? 20 : 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (seasons.length > 1) ...[
            const SizedBox(height: 12),
            // Season selector dropdown
            FocusableCard(
              scale: 1.03,
              onTap: () => _showSeasonPicker(seasons, isPhone),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 12 : 16, vertical: isPhone ? 6 : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentSeason.name ??
                          'Season ${currentSeason.seasonNumber}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isPhone ? 13 : 15,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSeasonPicker(List<Season> seasons, bool isPhone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: seasons.length,
        itemBuilder: (_, i) {
          final s = seasons[i];
          final isSelected = i == _selectedSeasonIndex;
          return ListTile(
            title: Text(
              s.name ?? 'Season ${s.seasonNumber}',
              style: TextStyle(
                color: isSelected ? kColorPrimary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing:
                isSelected ? const Icon(Icons.check, color: kColorPrimary) : null,
            onTap: () {
              setState(() => _selectedSeasonIndex = i);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // EPISODE TILE
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildEpisodeTile(Episode episode, int index) {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final title = _cleanEpisodeTitle(episode.title, episode.episodeNum);
    final durationStr = episode.duration != null && episode.duration! > 0
        ? _formatDuration(episode.duration!)
        : null;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return FocusableCard(
          scale: 1.01,
          onTap: () {
            if (state is! AuthSuccess) return;
            final userAuth = state.user;
            _playEpisode(episode, _selectedSeasonIndex, index, userAuth);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isPhone ? 16 : 32,
              vertical: isPhone ? 8 : 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Episode number
                SizedBox(
                  width: isPhone ? 28 : 36,
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: isPhone ? 16 : 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: isPhone ? 12 : 16),

                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: isPhone ? 100 : 130,
                    height: isPhone ? 60 : 75,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: _serie.cover ?? '',
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF1E1E2E),
                          ),
                        ),
                        // Play overlay on hover / focus
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: isPhone ? 12 : 16),

                // Title + Info + Duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isPhone ? 13 : 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (durationStr != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              durationStr,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: isPhone ? 11 : 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (episode.info != null && episode.info!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          episode.info!,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: isPhone ? 11 : 13,
                            height: 1.4,
                          ),
                          maxLines: isPhone ? 2 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final rem = m % 60;
      return '$h:${rem.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// ────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
    this.border = false,
  });

  final String label;
  final Color color;
  final Color textColor;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: border ? Border.all(color: Colors.white38) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
