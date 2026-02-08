part of '../screens.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VlcPlayerController? _vlcViewController;
  bool _showControls = true;
  Timer? _hideTimer;
  String _url = "";
  final FocusNode _playPauseFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Logic to extract URL from arguments (ChannelLive, MovieDetail, or Episode)
    final args = Get.arguments;
    _initializePlayer(args);
  }

  Future<void> _initializePlayer(dynamic args) async {
    final user = await LocaleApi.getUser();
    if (user == null) return;
    String finalUrl = "";

    // Build URL based on content type
    if (args is ChannelLive) {
      finalUrl =
          "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/${args.streamId}";
    } else if (args is MovieDetail) {
      final ext = args.movieData?.containerExtension ?? "mp4";
      finalUrl =
          "${user.serverInfo!.serverUrl}/movie/${user.userInfo!.username}/${user.userInfo!.password}/${args.movieData!.streamId}.$ext";
    } else if (args is Episode) {
      final ext = args.containerExtension ?? "mp4";
      finalUrl =
          "${user.serverInfo!.serverUrl}/series/${user.userInfo!.username}/${user.userInfo!.password}/${args.id}.$ext";
    }

    if (finalUrl.isNotEmpty) {
      _url = finalUrl;
      _vlcViewController = VlcPlayerController.network(
        _url,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );

      _startHideTimer();
      setState(() {}); // Rebuild
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  @override
  void dispose() {
    _vlcViewController?.stop();
    _vlcViewController?.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_vlcViewController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VlcPlayer(
              controller: _vlcViewController!,
              aspectRatio: 16 / 9,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),

            // Controls Overlay
            if (_showControls)
              Container(
                color: Colors.black45,
                child: Column(
                  children: [
                    // Top Bar (Back)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 30),
                            onPressed: () => Get.back(),
                          ),
                          const Spacer(),
                          const Icon(Icons.hd, color: Colors.white),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Center Play/Pause (optional large icon)

                    const Spacer(),

                    // Bottom Controls
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.fast_rewind,
                                color: Colors.white, size: 36),
                            onPressed: () {
                              // Seek back
                              _startHideTimer();
                            },
                          ),
                          const SizedBox(width: 32),
                          FocusableCard(
                            onTap: () async {
                              if (await _vlcViewController!.isPlaying() ??
                                  false) {
                                _vlcViewController!.pause();
                              } else {
                                _vlcViewController!.play();
                              }
                              _startHideTimer();
                              setState(() {});
                            },
                            autoFocus: true,
                            scale: 1.1,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: kColorPrimary,
                              child: Icon(
                                (_vlcViewController!.value.isPlaying)
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          IconButton(
                            icon: const Icon(Icons.fast_forward,
                                color: Colors.white, size: 36),
                            onPressed: () {
                              // Seek forward
                              _startHideTimer();
                            },
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
