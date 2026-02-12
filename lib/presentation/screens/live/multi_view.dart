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
  int _audioFocusIndex = 0;

  int? _maximizedIndex;

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
    final result =
        await Get.to(() => const LiveCategoriesScreen(isPicker: true));

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_maximizedIndex != null)
            _buildSlot(_maximizedIndex!)
          else
            Column(
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
                onPressed: () {
                  if (_maximizedIndex != null) {
                    setState(() {
                      _maximizedIndex = null;
                    });
                  } else {
                    Get.back();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(int index) {
    final channel = _channels[index];
    final isFocused = _audioFocusIndex == index;
    final isMaximized = _maximizedIndex == index;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isFocused ? kColorPrimary : Colors.white10,
            width: (isFocused && !isMaximized) ? 2 : 1,
          ),
          color: Colors.black,
        ),
        child: FocusableCard(
          onTap: () => _onSlotTap(index),
          // onDoubleTap is not directly supported by FocusableCard wrapper usually,
          // but we can wrap the inner content or modify FocusableCard.
          // For now, let's keep it simple and assume FocusableCard handles tap.
          // To support double tap on TV, we might need a specific key binding or just use the remote.
          // For mobile, we can wrap the inner stack with GestureDetector if needed,
          // but FocusableCard consumes taps.
          // Let's modify the FocusableCard usage to allow passing a child that handles other gestures
          // OR purely rely on FocusableCard for focus execution.

          // Actually, our FocusableCard (in common.dart) returns an InkWell.
          // So we can just add onDoubleTap to FocusableCard if we modify it,
          // OR we can wrap the FocusableCard's child with GestureDetector,
          // but the InkWell might consume the touch.

          // Let's use a raw InkWell with onFocusChange for TV, identical to FocusableCard logic
          // but inlined here to support onDoubleTap and custom border logic.

          autoFocus: index == 0,
          child: Container(
            // This child is what FocusableCard wraps.
            // But wait, I should just use the InkWell logic in _buildSlot
            // and ADD onFocusChange to update the border/focus state.
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
                        isFocused ? Icons.volume_up : Icons.volume_off,
                        color: isFocused ? kColorPrimary : Colors.white70,
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
}
