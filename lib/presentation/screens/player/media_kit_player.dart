part of '../screens.dart';

// Needs FontAwesome for specific icons like +/- 10s if Material doesn't have them,
// or use Material icons that look similar.
// The reference image uses:
// Back (Material ArrowBack)
// Flag (Material Flag/Report)
// Play (Material PlayArrow)
// -10s (Material Replay10)
// +10s (Material Forward10)
// Volume (Material VolumeUp)
// Subtitles (Material Subtitles or ChatBubble)
// Speed (Material Speed)
// Fullscreen (Material Fullscreen)

// We have 'package:font_awesome_flutter/font_awesome_flutter.dart' available in screens.dart (parent part file).

class MediaKitPlayerScreen extends StatefulWidget {
  final String link;
  final String title;
  final bool isLive;

  const MediaKitPlayerScreen({
    super.key,
    required this.link,
    required this.title,
    this.isLive = false,
  });

  @override
  State<MediaKitPlayerScreen> createState() => _MediaKitPlayerScreenState();
}

class _MediaKitPlayerScreenState extends State<MediaKitPlayerScreen> {
  late final Player _player;
  late final VideoController _videoController;

  bool _showControls = true;
  BoxFit _fit = BoxFit.contain;
  double _playbackSpeed = 1.0;

  void _toggleFit() {
    setState(() {
      _fit = _fit == BoxFit.contain ? BoxFit.cover : BoxFit.contain;
    });
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

    MediaKit.ensureInitialized();
    WakelockPlus.enable();

    // 🔥 Fullscreen for Movies / Series
    if (!widget.isLive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

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
          'hwdec': 'no', // Linux safe
        },
      ),
      play: true,
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();

    if (!widget.isLive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }

    _player.dispose();
    super.dispose();
  }

  // 🔤 SUBTITLE PICKER
  void _showTracksSelection() async {
    final subtitleTracks = _player.state.tracks.subtitle;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E), // Dark background
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
                      // "Off" Option
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
                      // Tracks
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
  }

  // 🔊 AUDIO TRACK PICKER
  void _showAudioTracksSelection() async {
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
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return "${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
    }
    return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  void _toggleMute() {
    final currentVol = _player.state.volume;
    if (currentVol > 0) {
      _player.setVolume(0);
    } else {
      _player.setVolume(100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // 🎬 VIDEO LAYER
            Center(
              child: Video(
                controller: _videoController,
                fit: _fit,
                controls: NoVideoControls,
              ),
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
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.flag_outlined,
                                color: Colors.white),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Report feature coming soon')),
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
                          StreamBuilder<Duration>(
                            stream: _player.stream.position,
                            builder: (context, snapshot) {
                              final position = snapshot.data ?? Duration.zero;
                              final duration = _player.state.duration;
                              return Row(
                                children: [
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 6),
                                        trackHeight: 2,
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                                overlayRadius: 12),
                                        activeTrackColor: Colors.red,
                                        inactiveTrackColor: Colors.white24,
                                        thumbColor: Colors.red,
                                      ),
                                      child: Slider(
                                        value: position.inSeconds
                                            .toDouble()
                                            .clamp(0,
                                                duration.inSeconds.toDouble()),
                                        min: 0,
                                        max: duration.inSeconds.toDouble(),
                                        onChanged: (val) {
                                          _player.seek(
                                              Duration(seconds: val.toInt()));
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              );
                            },
                          ),

                          // 🎛️ BUTTONS ROW
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // LEFT: Play, -10, +10, Volume
                              Row(
                                children: [
                                  StreamBuilder<bool>(
                                    stream: _player.stream.playing,
                                    builder: (context, snapshot) {
                                      final playing = snapshot.data ?? true;
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
                                  IconButton(
                                    icon: const Icon(Icons.replay_10,
                                        color: Colors.white),
                                    onPressed: () {
                                      _player.seek(_player.state.position -
                                          const Duration(seconds: 10));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.forward_10,
                                        color: Colors.white),
                                    onPressed: () {
                                      _player.seek(_player.state.position +
                                          const Duration(seconds: 10));
                                    },
                                  ),
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
                                    widget.title,
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
                                  IconButton(
                                    icon: const Icon(Icons.subtitles,
                                        color: Colors.white),
                                    onPressed: _showTracksSelection,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.audiotrack,
                                        color: Colors.white),
                                    onPressed: _showAudioTracksSelection,
                                  ),
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
                                        _fit == BoxFit.cover
                                            ? Icons.fullscreen_exit
                                            : Icons.fullscreen,
                                        color: Colors.white),
                                    onPressed: _toggleFit,
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
    );
  }
}
