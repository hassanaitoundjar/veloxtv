part of '../screens.dart';

class NextMediaInfo {
  final String link;
  final String title;
  final Future<NextMediaInfo?> Function()? onNextEpisodeAsync;
  NextMediaInfo({required this.link, required this.title, this.onNextEpisodeAsync});
}

class MediaKitPlayerScreen extends StatefulWidget {
  final String link;
  final String title;
  final bool isLive;
  final Player? player;
  final VideoController? videoController;

  /// If provided (e.g. from Search), the player will load this channel's
  /// category in the side panel so the list is always contextually correct.
  final ChannelLive? channel;
  final Future<NextMediaInfo?> Function()? onNextEpisodeAsync;
  const MediaKitPlayerScreen({
    super.key,
    required this.link,
    required this.title,
    this.isLive = false,
    this.player,
    this.videoController,
    this.channel,
    this.onNextEpisodeAsync,
  });
  @override
  State<MediaKitPlayerScreen> createState() => _MediaKitPlayerScreenState();
}

class _MediaKitPlayerScreenState extends State<MediaKitPlayerScreen>
    with WidgetsBindingObserver {
  late final Player _player;
  late final VideoController _videoController;
  bool _isExternalController = false;
  bool _showControls = true;
  final FocusNode _playPauseFocusNode = FocusNode();

  // Live Side Panel State
  bool _showChannelList = false;
  late String _currentTitle;
  Future<NextMediaInfo?> Function()? _currentOnNextEpisodeAsync;
  bool _isLoadingNext = false;

  // PiP State
  bool _isInPipMode = false;
  late final SimplePip _simplePip;

  double _playbackSpeed = 1.0;
  Timer? _hideTimer;
  void _startHideTimer() {
    _hideTimer?.cancel();
    final wasHidden = !_showControls;
    setState(() {
      _showControls = true;
    });
    if (wasHidden && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _playPauseFocusNode.requestFocus();
      });
    }
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
  int _aspectRatioMode = 1; // Default to Fill (Full Screen)
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
    WidgetsBinding.instance.addObserver(this);
    _currentTitle = widget.title;
    _currentOnNextEpisodeAsync = widget.onNextEpisodeAsync;
    MediaKit.ensureInitialized();
    WakelockPlus.enable();
    _startHideTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Initialize PiP
    _simplePip = SimplePip(
      onPipEntered: () {
        if (mounted) setState(() => _isInPipMode = true);
      },
      onPipExited: () {
        if (mounted) {
          setState(() => _isInPipMode = false);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        }
      },
      onPipAction: (action) {
        switch (action) {
          case PipAction.play:
            _player.play();
          case PipAction.pause:
            _player.pause();
          case PipAction.forward:
            _player.seek(_player.state.position + const Duration(seconds: 10));
          case PipAction.rewind:
            _player.seek(_player.state.position - const Duration(seconds: 10));
          default:
            break;
        }
      },
    );
    // Enable auto-enter PiP when user presses Home button (API 31+)
    _simplePip.setAutoPipMode(
      aspectRatio: (16, 9),
      autoEnter: true,
      seamlessResize: true,
    );

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
      _videoController = VideoController(_player);
      _player.open(
        Media(
          widget.link,
          extras: {
            'hwdec': 'auto',
          },
        ),
        play: true,
      );
    }
    // If a channel was passed (e.g. from Search), load its category
    // so the side panel shows the correct channel list.
    if (widget.isLive && widget.channel?.categoryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ChannelsBloc>().add(
                GetChannels(widget.channel!.categoryId!, TypeCategory.live),
              );
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    WakelockPlus.disable();
    // Disable auto PiP when leaving player
    _simplePip.setAutoPipMode(autoEnter: false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (!_isExternalController) {
      _player.dispose();
    }
    _playPauseFocusNode.dispose();
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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
    if (mounted) {
      _startHideTimer();
      _playPauseFocusNode.requestFocus();
    }
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
    if (mounted) {
      _startHideTimer();
      _playPauseFocusNode.requestFocus();
    }
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
      body: FocusScope(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          final key = event.logicalKey;

          // Media keys — always handle
          if (key == LogicalKeyboardKey.mediaPlayPause) {
            _onInteraction();
            _player.playOrPause();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.mediaPlay) {
            _onInteraction();
            _player.play();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.mediaPause) {
            _onInteraction();
            _player.pause();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.mediaFastForward) {
            _onInteraction();
            _player.seek(_player.state.position + const Duration(seconds: 10));
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.mediaRewind) {
            _onInteraction();
            _player.seek(_player.state.position - const Duration(seconds: 10));
            return KeyEventResult.handled;
          }

          // When controls are hidden — handle D-Pad directly
          if (!_showControls) {
            if (key == LogicalKeyboardKey.select ||
                key == LogicalKeyboardKey.enter ||
                key == LogicalKeyboardKey.space) {
              _onInteraction();
              return KeyEventResult.handled;
            }
            if (!widget.isLive) {
              if (key == LogicalKeyboardKey.arrowLeft) {
                _player
                    .seek(_player.state.position - const Duration(seconds: 10));
                _onInteraction();
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.arrowRight) {
                _player
                    .seek(_player.state.position + const Duration(seconds: 10));
                _onInteraction();
                return KeyEventResult.handled;
              }
            }
            if (key == LogicalKeyboardKey.arrowUp) {
              _player.setVolume((_player.state.volume + 5.0).clamp(0.0, 100.0));
              _onInteraction();
              return KeyEventResult.handled;
            } else if (key == LogicalKeyboardKey.arrowDown) {
              _player.setVolume((_player.state.volume - 5.0).clamp(0.0, 100.0));
              _onInteraction();
              return KeyEventResult.handled;
            }
            // Any other key → show controls
            _onInteraction();
            return KeyEventResult.handled;
          }

          // Controls visible — space for play/pause
          if (key == LogicalKeyboardKey.space) {
            _player.playOrPause();
            _onInteraction();
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.escape ||
              key == LogicalKeyboardKey.goBack) {
            Navigator.pop(context);
            return KeyEventResult.handled;
          }
          // Reset hide timer on any key, let arrows do focus traversal
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
                        child: CircularProgressIndicator(color: kColorPrimary),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                // 🌑 GRADIENT OVERLAYS
                if (_showControls && !_isInPipMode) ...[
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
                if (_showControls && !_isInPipMode)
                  SafeArea(
                    child: Column(
                      children: [
                        // 🔝 TOP BAR
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              _PlayerControlButton(
                                icon: Icons.arrow_back,
                                onPressed: () => Navigator.pop(context),
                                onFocusChange: (_) => _onInteraction(),
                              ),
                              if (widget.isLive)
                                _PlayerControlButton(
                                  icon: _showChannelList
                                      ? Icons.playlist_remove
                                      : Icons.playlist_play,
                                  onPressed: () {
                                    setState(() {
                                      _showChannelList = !_showChannelList;
                                    });
                                  },
                                  onFocusChange: (_) => _onInteraction(),
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
                                            data: const SliderThemeData(
                                              thumbShape: RoundSliderThumbShape(
                                                  enabledThumbRadius: 6),
                                              trackHeight: 2,
                                              overlayShape:
                                                  RoundSliderOverlayShape(
                                                      overlayRadius: 12),
                                              activeTrackColor: kColorPrimary,
                                              inactiveTrackColor:
                                                  Colors.white24,
                                              thumbColor: kColorPrimary,
                                            ),
                                            child: ExcludeFocus(
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
                                          final playing = snapshot.data ?? true;
                                          return _PlayerControlButton(
                                            focusNode: _playPauseFocusNode,
                                            icon: playing
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            onPressed: _player.playOrPause,
                                            autoFocus: true,
                                            onFocusChange: (_) =>
                                                _onInteraction(),
                                          );
                                        },
                                      ),
                                      if (!widget.isLive) ...[
                                        _PlayerControlButton(
                                          icon: Icons.replay_10,
                                          onPressed: () {
                                            _player.seek(_player
                                                    .state.position -
                                                const Duration(seconds: 10));
                                          },
                                          onFocusChange: (_) =>
                                              _onInteraction(),
                                        ),
                                        _PlayerControlButton(
                                          icon: Icons.forward_10,
                                          onPressed: () {
                                            _player.seek(_player
                                                    .state.position +
                                                const Duration(seconds: 10));
                                          },
                                          onFocusChange: (_) =>
                                              _onInteraction(),
                                        ),
                                        if (_currentOnNextEpisodeAsync != null)
                                          _PlayerControlButton(
                                            icon: _isLoadingNext ? Icons.hourglass_empty : Icons.skip_next,
                                            onPressed: _isLoadingNext ? () {} : () async {
                                              if (_currentOnNextEpisodeAsync != null && !_isLoadingNext) {
                                                setState(() => _isLoadingNext = true);
                                                final nextMedia = await _currentOnNextEpisodeAsync!();
                                                if (nextMedia != null && mounted) {
                                                  setState(() {
                                                    _currentTitle = nextMedia.title;
                                                    _currentOnNextEpisodeAsync = nextMedia.onNextEpisodeAsync;
                                                    _isLoadingNext = false;
                                                  });
                                                  await _player.open(Media(nextMedia.link, extras: {'hwdec': 'auto'}), play: true);
                                                } else if (mounted) {
                                                  setState(() => _isLoadingNext = false);
                                                }
                                              }
                                            },
                                            onFocusChange: (_) => _onInteraction(),
                                          ),
                                      ],
                                      StreamBuilder<double>(
                                        stream: _player.stream.volume,
                                        initialData: _player.state.volume,
                                        builder: (context, snapshot) {
                                          final muted =
                                              (snapshot.data ?? 0) <= 0;
                                          return _PlayerControlButton(
                                            icon: muted
                                                ? Icons.volume_off
                                                : Icons.volume_up,
                                            onPressed: _toggleMute,
                                            onFocusChange: (_) =>
                                                _onInteraction(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  // CENTER: Title (always visible, smaller on phone)
                                  Expanded(
                                    child: Text(
                                      _currentTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.isPhone ? 11 : 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // RIGHT: Subs, Speed, Fit/Size
                                  Row(
                                    children: [
                                      if (!widget.isLive)
                                        _PlayerControlButton(
                                          icon: Icons.subtitles,
                                          onPressed: _showTracksSelection,
                                          onFocusChange: (_) =>
                                              _onInteraction(),
                                        ),
                                      if (!widget.isLive)
                                        _PlayerControlButton(
                                          icon: Icons.audiotrack,
                                          onPressed: _showAudioTracksSelection,
                                          onFocusChange: (_) =>
                                              _onInteraction(),
                                        ),
                                      if (!widget.isLive)
                                        _PlayerControlButton(
                                          icon: null,
                                          label: "${_playbackSpeed}x",
                                          onPressed: _changeSpeed,
                                          onFocusChange: (_) =>
                                              _onInteraction(),
                                        ),
                                      _PlayerControlButton(
                                        icon: _aspectRatioMode == 0
                                            ? Icons.aspect_ratio
                                            : Icons.fit_screen,
                                        onPressed: _toggleAspectRatio,
                                        onFocusChange: (_) => _onInteraction(),
                                      ),
                                      _PlayerControlButton(
                                        icon: Icons
                                            .picture_in_picture_alt_rounded,
                                        onPressed: () async {
                                          final isAvailable =
                                              await SimplePip.isPipAvailable;
                                          if (isAvailable) {
                                            _simplePip.enterPipMode(
                                              aspectRatio: (16, 9),
                                              autoEnter: true,
                                              seamlessResize: true,
                                            );
                                          }
                                        },
                                        onFocusChange: (_) => _onInteraction(),
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
                // 📌 CHANNEL NAME — persistent top-left badge (phone only)
                if (context.isPhone && widget.isLive && !_isInPipMode)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                _currentTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // 📺 LIVE CHANNELS SIDE PANEL
                if (widget.isLive && _showChannelList && !_isInPipMode)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    width: context.isPhone
                        ? MediaQuery.of(context).size.width * 0.40
                        : 350,
                    child: SafeArea(
                      right: false,
                      child: _buildSideChannelList(isPhone: context.isPhone),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onChannelSelected(ChannelLive channel) async {
    final user = await LocaleApi.getUser();
    if (user != null && channel.streamId != null) {
      final format = GetStorage().read('stream_format') ?? 'default';
      final base =
          "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/${channel.streamId}";
      final link = format == 'default' ? base : "$base.$format";

      setState(() {
        _currentTitle = channel.name ?? "Live TV";
      });

      await _player.open(
        Media(
          link,
          extras: {
            'hwdec': 'auto',
          },
        ),
        play: true,
      );
      _onInteraction();
    }
  }

  Widget _buildSideChannelList({bool isPhone = false}) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 12 : 16,
                  vertical: isPhone ? 8 : 12,
                ),
                color: Colors.black38,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Channels",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPhone ? 12 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.white, size: isPhone ? 20 : 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _showChannelList = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Channels List
              Expanded(
                child: BlocBuilder<ChannelsBloc, ChannelsState>(
                  builder: (context, state) {
                    if (state is ChannelsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChannelsSuccess &&
                        state.type == TypeCategory.live) {
                      final channels = List<ChannelLive>.from(state.channels);
                      if (channels.isEmpty) {
                        return const Center(
                            child: Text("No channels",
                                style: TextStyle(color: Colors.white54)));
                      }
                      return ListView.builder(
                        itemCount: channels.length,
                        itemBuilder: (context, index) {
                          final channel = channels[index];
                          final isPlaying = _currentTitle == channel.name;
                          final iconSize = isPhone ? 32.0 : 40.0;
                          return Material(
                            color: isPlaying
                                ? kColorPrimary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _onChannelSelected(channel),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isPhone ? 8 : 12,
                                  vertical: isPhone ? 5 : 7,
                                ),
                                child: Row(
                                  children: [
                                    // Channel icon
                                    Container(
                                      width: iconSize,
                                      height: iconSize,
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: channel.streamIcon ?? "",
                                        errorWidget: (_, __, ___) => Icon(
                                            Icons.tv,
                                            color: Colors.white24,
                                            size: isPhone ? 16 : 20),
                                        placeholder: (_, __) =>
                                            const CircularProgressIndicator(
                                                strokeWidth: 1.5),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(width: isPhone ? 8 : 12),
                                    // Channel name
                                    Expanded(
                                      child: Text(
                                        channel.name ?? "Channel",
                                        style: TextStyle(
                                          color: isPlaying
                                              ? kColorPrimary
                                              : Colors.white,
                                          fontWeight: isPlaying
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: isPhone ? 12 : 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Now-playing indicator
                                    if (isPlaying)
                                      Icon(Icons.play_arrow,
                                          color: kColorPrimary,
                                          size: isPhone ? 16 : 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const Center(
                        child: Text("Select Category",
                            style: TextStyle(color: Colors.white54)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A focusable control button for the player with visible highlight on focus.
class _PlayerControlButton extends StatefulWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback onPressed;
  final FocusNode? focusNode;
  final bool autoFocus;
  final ValueChanged<bool>? onFocusChange;

  const _PlayerControlButton({
    this.icon,
    this.label,
    required this.onPressed,
    this.focusNode,
    this.autoFocus = false,
    this.onFocusChange,
  });

  @override
  State<_PlayerControlButton> createState() => _PlayerControlButtonState();
}

class _PlayerControlButtonState extends State<_PlayerControlButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autoFocus,
      onFocusChange: (focused) {
        setState(() => _isFocused = focused);
        widget.onFocusChange?.call(focused);
      },
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.select ||
              key == LogicalKeyboardKey.enter) {
            widget.onPressed();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isFocused
                ? kColorPrimary.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: _isFocused
                ? Border.all(color: kColorPrimary, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: widget.label != null
              ? Text(
                  widget.label!,
                  style: TextStyle(
                    color: _isFocused ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                )
              : Icon(
                  widget.icon,
                  color: _isFocused ? Colors.white : Colors.white70,
                  size: 24,
                ),
        ),
      ),
    );
  }
}
