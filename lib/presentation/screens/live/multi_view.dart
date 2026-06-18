part of '../screens.dart';

class MultiViewScreen extends StatefulWidget {
  const MultiViewScreen({super.key});

  @override
  State<MultiViewScreen> createState() => _MultiViewScreenState();
}

class _MultiViewScreenState extends State<MultiViewScreen> {
  // 4 Slots for players
  final List<Player> _players = [];
  final List<VideoController> _controllers = [];
  final List<ChannelLive?> _channels = [null, null, null, null];
  final List<bool> _tvFocusStates = [false, false, false, false];
  int _audioFocusIndex = 0;

  int? _maximizedIndex;
  int? _selectedScreenCount;

  @override
  void initState() {
    super.initState();
    // Initialize 4 players
    for (int i = 0; i < 4; i++) {
      final player = Player();
      _players.add(player);
      _controllers.add(VideoController(player));
      // Mute all except the focused one (default 0)
      player.setVolume(i == 0 ? 100 : 0);
    }
  }

  @override
  void dispose() {
    for (var player in _players) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> _playChannel(int index, ChannelLive channel) async {
    final user = await LocaleApi.getUser();
    if (user == null || channel.streamId == null) return;

    final url =
        "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/${channel.streamId}";

    setState(() {
      _channels[index] = channel;
    });

    await _players[index].open(Media(url), play: true);
    _setAudioFocus(index);
  }

  void _setAudioFocus(int index) {
    setState(() {
      _audioFocusIndex = index;
    });
    for (int i = 0; i < _players.length; i++) {
      _players[i].setVolume(i == index ? 100 : 0);
    }
  }

  void _onSlotTap(int index) {
    if (_channels[index] == null) {
      _openChannelPicker(index);
    } else {
      _setAudioFocus(index);
    }
  }

  // Double tap and long press are currently not supported with FocusableCard wrapper
  // which consumes gestures. Kept for future reference if we implement custom focus widget.
  /*
  void _onSlotDoubleTap(int index) {
    if (_channels[index] != null) {
      setState(() {
        if (_maximizedIndex == index) {
          _maximizedIndex = null;
        } else {
          _maximizedIndex = index;
        }
      });
    }
  }

  void _onSlotLongPress(int index) {
    if (_channels[index] != null) {
      _players[index].stop();
      setState(() {
        _channels[index] = null;
        if (_maximizedIndex == index) {
          _maximizedIndex = null;
        }
      });
    }
  }
  */

  void _openChannelPicker(int index) async {
    // Navigate to LiveCategories in Picker Mode
    final result = await Get.to(() => const LiveTvScreen(isPicker: true));

    print("DEBUG: MultiView result type: ${result.runtimeType}");
    print("DEBUG: MultiView result value: $result");

    if (result != null && result is ChannelLive) {
      _playChannel(index, result);
    } else {
      print("DEBUG: MultiView result is not ChannelLive or is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedScreenCount == null) {
      return _buildSelectionScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_maximizedIndex != null)
            _buildSlot(_maximizedIndex!)
          else
            _buildMultiViewGrid(),
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.black54,
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () {
                  if (_maximizedIndex != null) {
                    setState(() {
                      _maximizedIndex = null;
                    });
                  } else {
                    setState(() {
                      _selectedScreenCount = null;
                      // Clear all channels
                      for (int i = 0; i < 4; i++) {
                        _players[i].stop();
                        _channels[i] = null;
                      }
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiViewGrid() {
    if (_selectedScreenCount == 2) {
      return Row(
        children: [
          _buildSlot(0),
          _buildSlot(1),
        ],
      );
    } else if (_selectedScreenCount == 3) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildSlot(0),
                _buildSlot(1),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildSlot(2),
                Expanded(child: Container(color: Colors.black)),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildSlot(0),
                _buildSlot(1),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildSlot(2),
                _buildSlot(3),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSelectionScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Select Multi-View Layout",
                    style: Get.textTheme.headlineMedium
                        ?.copyWith(color: Colors.white)),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLayoutOption(2, "2 Screens", Icons.view_column),
                    const SizedBox(width: 32),
                    _buildLayoutOption(3, "3 Screens", Icons.grid_view),
                    const SizedBox(width: 32),
                    _buildLayoutOption(4, "4 Screens", Icons.apps),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.black54,
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(int index) {
    final channel = _channels[index];
    final isAudioFocused = _audioFocusIndex == index;
    final isMaximized = _maximizedIndex == index;
    final isTvFocused = _tvFocusStates[index];

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2), // Small gap between panes to prevent border overlap
        decoration: BoxDecoration(
          border: Border.all(
            color: isTvFocused 
                ? Colors.white 
                : (isAudioFocused ? kColorPrimary : Colors.white10),
            width: isTvFocused ? 3 : (isAudioFocused ? 2 : 1),
          ),
          color: Colors.black,
        ),
        child: InkWell(
          onTap: () => _onSlotTap(index),
          onFocusChange: (focused) {
            setState(() {
              _tvFocusStates[index] = focused;
            });
          },
          autofocus: index == 0,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (channel != null)
                  Video(controller: _controllers[index], fit: BoxFit.cover)
                else
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_circle_outline,
                            color: Colors.white24, size: 48),
                        if (index == 0 && _channels.every((c) => c == null))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Tap to add channel",
                              style: GoogleFonts.outfit(color: Colors.white24),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),

                // Audio Indicator
                if (channel != null && !isMaximized)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isAudioFocused ? Icons.volume_up : Icons.volume_off,
                        color: isAudioFocused ? kColorPrimary : Colors.white70,
                        size: 16,
                      ),
                    ),
                  ),

                // Channel Name
                if (channel != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      channel.name ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black)],
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
    );
  }
  Widget _buildLayoutOption(int count, String title, IconData icon) {
    return FocusableCard(
      onTap: () {
        setState(() {
          _selectedScreenCount = count;
        });
      },
      scale: 1.1,
      autoFocus: count == 2,
      child: Container(
        width: 180,
        height: 180,
        decoration: kDecorCard.copyWith(
            color: kColorCardLight.withValues(alpha: 0.2)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: kColorPrimary),
            const SizedBox(height: 16),
            Text(title,
                style: Get.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
