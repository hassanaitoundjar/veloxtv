part of '../screens.dart';

class MediaKitPlayerScreen extends StatefulWidget {
  final String link;
  final String title;
  final bool isLive;
  final Player? player;
  final VideoController? videoController;
  const MediaKitPlayerScreen({
    super.key,
    required this.link,
    required this.title,
    this.isLive = false,
    this.player,
    this.videoController,
  });
  @override
  State<MediaKitPlayerScreen> createState() => _MediaKitPlayerScreenState();
}

class _MediaKitPlayerScreenState extends State<MediaKitPlayerScreen> {
  late final Player _player;
  late final VideoController _videoController;
  bool _isExternalController = false;
  bool _showControls = true;

  // Live Side Panel State
  bool _showChannelList = false;
  CategoryModel? _selectedSideCategory;
  late String _currentTitle;

  double _playbackSpeed = 1.0;
  Timer? _hideTimer;
  void _startHideTimer() {
    _hideTimer?.cancel();
    setState(() {
      _showControls = true;
    });
    _hideTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _onInteraction() {
    _startHideTimer();
  }

  // Aspect Ratio Modes: 0=Fit(Original), 1=Fill(Stretch), 2=Zoom(Cover), 3=16:9, 4=4:3
  int _aspectRatioMode = 0;
  final List<String> _arNames = ["Original", "Fill", "Zoom", "16:9", "4:3"];
  void _toggleAspectRatio() {
    setState(() {
      _aspectRatioMode = (_aspectRatioMode + 1) % _arNames.length;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Aspect Ratio: ${_arNames[_aspectRatioMode]}"),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
    _onInteraction();
  }

  void _changeSpeed() {
    setState(() {
      _playbackSpeed = _playbackSpeed == 1.0
          ? 1.25
          : _playbackSpeed == 1.25
              ? 1.5
              : _playbackSpeed == 1.5
                  ? 2.0
                  : 1.0;
      _player.setRate(_playbackSpeed);
    });
  }

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    MediaKit.ensureInitialized();
    WakelockPlus.enable();
    _startHideTimer();
    if (!widget.isLive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    if (widget.player != null && widget.videoController != null) {
      _player = widget.player!;
      _videoController = widget.videoController!;
      _isExternalController = true;
    } else {
      _player = Player(
        configuration: const PlayerConfiguration(
          bufferSize: 32 * 1024 * 1024,
        ),
      );
      _videoController = VideoController(
        _player,
        configuration: const VideoControllerConfiguration(
          enableHardwareAcceleration: false,
        ),
      );
      _player.open(
        Media(
          widget.link,
          extras: {
            'hwdec': 'no',
          },
        ),
        play: true,
      );
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    WakelockPlus.disable();
    if (!widget.isLive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    if (!_isExternalController) {
      _player.dispose();
    }
    super.dispose();
  }

  // 🔤 SUBTITLE PICKER
  void _showTracksSelection() async {
    _startHideTimer();
    final subtitleTracks = _player.state.tracks.subtitle;
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 400,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Subtitles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        dense: true,
                        leading:
                            _player.state.track.subtitle == SubtitleTrack.no()
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 20)
                                : const SizedBox(width: 20),
                        title: const Text(
                          'Off',
                          style: TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          _player.setSubtitleTrack(SubtitleTrack.no());
                          Navigator.pop(context);
                        },
                      ),
                      ...subtitleTracks.map((track) {
                        final isSelected =
                            _player.state.track.subtitle == track;
                        return ListTile(
                          dense: true,
                          leading: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 20)
                              : const SizedBox(width: 20),
                          title: Text(
                            track.language ?? track.title ?? 'Subtitle',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            _player.setSubtitleTrack(track);
                            Navigator.pop(context);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    _startHideTimer();
  }

  // 🔊 AUDIO TRACK PICKER
  void _showAudioTracksSelection() async {
    _startHideTimer();
    final audioTracks = _player.state.tracks.audio;
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 400,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Audio Tracks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ...audioTracks.map((track) {
                        final isSelected = _player.state.track.audio == track;
                        return ListTile(
                          dense: true,
                          leading: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 20)
                              : const SizedBox(width: 20),
                          title: Text(
                            track.language ?? track.title ?? 'Audio Track',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            _player.setAudioTrack(track);
                            Navigator.pop(context);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    _startHideTimer();
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return "${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
    }
    return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  void _toggleMute() {
    _startHideTimer();
    final currentVol = _player.state.volume;
    if (currentVol > 0) {
      _player.setVolume(0);
    } else {
      _player.setVolume(100);
    }
  }

  Widget _buildVideoPlayer() {
    Widget playerWidget = Video(
      controller: _videoController,
      fit: _getBoxFit(),
      controls: NoVideoControls,
    );
    double? targetAspectRatio;
    if (_aspectRatioMode == 3) targetAspectRatio = 16 / 9;
    if (_aspectRatioMode == 4) targetAspectRatio = 4 / 3;
    if (targetAspectRatio != null) {
      return Center(
        child: AspectRatio(
          aspectRatio: targetAspectRatio,
          child: Video(
            controller: _videoController,
            fit: BoxFit.fill,
            controls: NoVideoControls,
          ),
        ),
      );
    }
    return playerWidget;
  }

  BoxFit _getBoxFit() {
    switch (_aspectRatioMode) {
      case 0:
        return BoxFit.contain;
      case 1:
        return BoxFit.fill;
      case 2:
        return BoxFit.cover;
      default:
        return BoxFit.contain;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.select): _onInteraction,
          const SingleActivator(LogicalKeyboardKey.enter): _onInteraction,
          const SingleActivator(LogicalKeyboardKey.space): _onInteraction,
        },
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            _onInteraction();
            return KeyEventResult.ignored;
          },
          child: MouseRegion(
            onHover: (_) => _onInteraction(),
            child: GestureDetector(
              onTap: _onInteraction,
              behavior: HitTestBehavior.translucent,
              child: Stack(
                children: [
                  // 🎬 VIDEO LAYER
                  Center(
                    child: _buildVideoPlayer(),
                  ),
                  // ⏳ BUFFERING INDICATOR
                  StreamBuilder<bool>(
                    stream: _player.stream.buffering,
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return const Center(
                          child:
                              CircularProgressIndicator(color: kColorPrimary),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  // 🌑 GRADIENT OVERLAYS
                  if (_showControls) ...[
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black87, Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 160,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                  // 🎮 CONTROLS LAYER
                  if (_showControls)
                    SafeArea(
                      child: Column(
                        children: [
                          // 🔝 TOP BAR
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                if (widget.isLive)
                                  IconButton(
                                    icon: Icon(
                                      _showChannelList
                                          ? Icons.playlist_remove
                                          : Icons.playlist_play,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showChannelList = !_showChannelList;
                                      });
                                    },
                                  ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.flag_outlined,
                                      color: Colors.white),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Report feature coming soon')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // ▶️ CENTER PLAY BUTTON
                          StreamBuilder<bool>(
                            stream: _player.stream.playing,
                            builder: (context, snapshot) {
                              final playing = snapshot.data ?? true;
                              if (playing) return const SizedBox();
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  iconSize: 64,
                                  icon: const Icon(Icons.play_arrow,
                                      color: Colors.white),
                                  onPressed: _player.play,
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          // 🔽 BOTTOM CONTROLS
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ➖ SEEK BAR & REMAINING TIME
                                if (widget.isLive)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.circle,
                                            color: kColorPrimary, size: 12),
                                        SizedBox(width: 8),
                                        Text(
                                          "LIVE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  StreamBuilder<Duration>(
                                    stream: _player.stream.position,
                                    builder: (context, snapshot) {
                                      final position =
                                          snapshot.data ?? Duration.zero;
                                      final duration = _player.state.duration;
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                thumbShape:
                                                    const RoundSliderThumbShape(
                                                        enabledThumbRadius: 6),
                                                trackHeight: 2,
                                                overlayShape:
                                                    const RoundSliderOverlayShape(
                                                        overlayRadius: 12),
                                                activeTrackColor: kColorPrimary,
                                                inactiveTrackColor:
                                                    Colors.white24,
                                                thumbColor: kColorPrimary,
                                              ),
                                              child: Slider(
                                                value: position.inSeconds
                                                    .toDouble()
                                                    .clamp(
                                                        0,
                                                        duration.inSeconds
                                                            .toDouble()),
                                                min: 0,
                                                max: duration.inSeconds
                                                    .toDouble(),
                                                onChanged: (val) {
                                                  _player.seek(Duration(
                                                      seconds: val.toInt()));
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDuration(duration),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                // 🎛️ BUTTONS ROW
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // LEFT: Play, -10, +10, Volume
                                    Row(
                                      children: [
                                        StreamBuilder<bool>(
                                          stream: _player.stream.playing,
                                          builder: (context, snapshot) {
                                            final playing =
                                                snapshot.data ?? true;
                                            return IconButton(
                                              icon: Icon(
                                                  playing
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                  color: Colors.white),
                                              onPressed: _player.playOrPause,
                                            );
                                          },
                                        ),
                                        if (!widget.isLive) ...[
                                          IconButton(
                                            icon: const Icon(Icons.replay_10,
                                                color: Colors.white),
                                            onPressed: () {
                                              _player.seek(_player
                                                      .state.position -
                                                  const Duration(seconds: 10));
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.forward_10,
                                                color: Colors.white),
                                            onPressed: () {
                                              _player.seek(_player
                                                      .state.position +
                                                  const Duration(seconds: 10));
                                            },
                                          ),
                                        ],
                                        IconButton(
                                          icon: const Icon(Icons.volume_up,
                                              color: Colors.white),
                                          onPressed: _toggleMute,
                                        ),
                                      ],
                                    ),
                                    // CENTER: Title
                                    if (!context.isPhone)
                                      Expanded(
                                        child: Text(
                                          _currentTitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    // RIGHT: Subs, Speed, Fit/Size
                                    Row(
                                      children: [
                                        if (!widget.isLive)
                                          IconButton(
                                            icon: const Icon(Icons.subtitles,
                                                color: Colors.white),
                                            onPressed: _showTracksSelection,
                                          ),
                                        if (!widget.isLive)
                                          IconButton(
                                            icon: const Icon(Icons.audiotrack,
                                                color: Colors.white),
                                            onPressed:
                                                _showAudioTracksSelection,
                                          ),
                                        if (!widget.isLive)
                                          TextButton(
                                            onPressed: _changeSpeed,
                                            child: Text(
                                              "${_playbackSpeed}x",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        IconButton(
                                          icon: Icon(
                                              _aspectRatioMode == 0
                                                  ? Icons.aspect_ratio
                                                  : Icons.fit_screen,
                                              color: Colors.white),
                                          onPressed: _toggleAspectRatio,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
}
