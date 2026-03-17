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
  final FocusNode _playPauseFocusNode = FocusNode();

  // Live Side Panel State
  bool _showChannelList = false;
  late String _currentTitle;

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
            _player.seek(
                _player.state.position + const Duration(seconds: 10));
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.mediaRewind) {
            _onInteraction();
            _player.seek(
                _player.state.position - const Duration(seconds: 10));
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
                _player.seek(
                    _player.state.position - const Duration(seconds: 10));
                _onInteraction();
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.arrowRight) {
                _player.seek(
                    _player.state.position + const Duration(seconds: 10));
                _onInteraction();
                return KeyEventResult.handled;
              }
            }
            if (key == LogicalKeyboardKey.arrowUp) {
              _player.setVolume(
                  (_player.state.volume + 5.0).clamp(0.0, 100.0));
              _onInteraction();
              return KeyEventResult.handled;
            } else if (key == LogicalKeyboardKey.arrowDown) {
              _player.setVolume(
                  (_player.state.volume - 5.0).clamp(0.0, 100.0));
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
                              const Spacer(),
                              _PlayerControlButton(
                                icon: Icons.flag_outlined,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Report feature coming soon')),
                                  );
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
                                      ],
                                      _PlayerControlButton(
                                        icon: Icons.volume_up,
                                        onPressed: _toggleMute,
                                        onFocusChange: (_) =>
                                            _onInteraction(),
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
                                        _PlayerControlButton(
                                          icon: Icons.subtitles,
                                          onPressed: _showTracksSelection,
                                          onFocusChange: (_) =>
                                              _onInteraction(),
                                        ),
                                      if (!widget.isLive)
                                        _PlayerControlButton(
                                          icon: Icons.audiotrack,
                                          onPressed:
                                              _showAudioTracksSelection,
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
                                        onFocusChange: (_) =>
                                            _onInteraction(),
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
                // 📺 LIVE CHANNELS SIDE PANEL
                if (widget.isLive && _showChannelList)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    width: context.isPhone ? MediaQuery.of(context).size.width * 0.7 : 350,
                    child: SafeArea(
                      right: false,
                      child: _buildSideChannelList(),
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
      final link = "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/${channel.streamId}";
      
      setState(() {
        _currentTitle = channel.name ?? "Live TV";
        // Do not hide the channel list automatically, let the user browse.
      });
      
      await _player.open(
        Media(
          link,
          extras: {
            'hwdec': 'no',
          },
        ),
        play: true,
      );
      _onInteraction();
    }
  }

  Widget _buildSideChannelList() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Column(
            children: [
              // Header
              Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Channels",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
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
                } else if (state is ChannelsSuccess) {
                  final channels = state.channels.cast<ChannelLive>();
                  if (channels.isEmpty) {
                    return const Center(child: Text("No channels", style: TextStyle(color: Colors.white54)));
                  }
                  return ListView.builder(
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      final isPlaying = _currentTitle == channel.name;
                      return Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: ListTile(
                            autofocus: isPlaying,
                            focusColor: Colors.blue.withOpacity(0.5),
                            hoverColor: Colors.blue.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: channel.streamIcon ?? "",
                                errorWidget: (_, __, ___) => const Icon(Icons.tv, color: Colors.white24),
                                placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2),
                                fit: BoxFit.contain,
                              ),
                            ),
                            title: Text(
                              channel.name ?? "Channel",
                              style: TextStyle(
                                color: isPlaying ? kColorPrimary : Colors.white,
                                fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: isPlaying ? const Icon(Icons.play_arrow, color: kColorPrimary, size: 20) : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            onTap: () {
                              _onChannelSelected(channel);
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text("Select Category", style: TextStyle(color: Colors.white54)));
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
                ? kColorPrimary.withOpacity(0.5)
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
