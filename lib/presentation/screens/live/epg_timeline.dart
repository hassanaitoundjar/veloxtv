part of '../screens.dart';

class EpgTimelineScreen extends StatefulWidget {
  final List<ChannelLive> channels;
  final String initialChannelId;

  const EpgTimelineScreen({
    super.key,
    required this.channels,
    required this.initialChannelId,
  });

  @override
  State<EpgTimelineScreen> createState() => _EpgTimelineScreenState();
}

class _EpgTimelineScreenState extends State<EpgTimelineScreen> {
  final ScrollController _verticalController1 = ScrollController();
  final ScrollController _verticalController2 = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  // Timeline constants
  final double _hourWidth = 250.0;
  final double _channelHeight = 70.0; // Increased for better touch target
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    // Set timeline range (e.g., -2 hours to +24 hours from now)
    final now = DateTime.now();
    _startTime = DateTime(now.year, now.month, now.day, now.hour)
        .subtract(const Duration(hours: 2));
    _endTime = _startTime.add(const Duration(hours: 24));

    // Sync vertical scrolling
    _verticalController1.addListener(() {
      if (_verticalController1.offset != _verticalController2.offset) {
        _verticalController2.jumpTo(_verticalController1.offset);
      }
    });
    _verticalController2.addListener(() {
      if (_verticalController2.offset != _verticalController1.offset) {
        _verticalController1.jumpTo(_verticalController2.offset);
      }
    });

    // Auto-scroll to "Now"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentDiff = DateTime.now().difference(_startTime).inMinutes;
      final offset = (currentDiff / 60.0) * _hourWidth;
      if (_horizontalController.hasClients) {
        _horizontalController.jumpTo((offset - 100)
            .clamp(0.0, _horizontalController.position.maxScrollExtent));
      }

      // Auto-scroll to selected channel
      final index = widget.channels
          .indexWhere((c) => c.streamId.toString() == widget.initialChannelId);
      if (index != -1 && _verticalController1.hasClients) {
        _verticalController1.jumpTo(index * _channelHeight);
      }
    });
  }

  @override
  void dispose() {
    _verticalController1.dispose();
    _verticalController2.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  // Time parsing helper
  DateTime? _parseEpgTime(dynamic dateStr) {
    if (dateStr == null) return null;

    // If it's already a DateTime (unlikely from API but good safety)
    if (dateStr is DateTime) return dateStr;

    final str = dateStr.toString();
    if (str.isEmpty) return null;

    // Try Unix Timestamp (Numeric)
    if (RegExp(r'^\d+$').hasMatch(str)) {
      try {
        final seconds = int.parse(str);
        // Check if it's milliseconds (13 digits) or seconds (10 digits)
        if (str.length > 11) {
          return DateTime.fromMillisecondsSinceEpoch(seconds, isUtc: true)
              .toLocal();
        }
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
            .toLocal();
      } catch (_) {}
    }

    // Try YYYYMMDDHHMMSS format (Standard XTREAM)
    if (str.length >= 14) {
      try {
        final y = int.parse(str.substring(0, 4));
        final m = int.parse(str.substring(4, 6));
        final d = int.parse(str.substring(6, 8));
        final h = int.parse(str.substring(8, 10));
        final min = int.parse(str.substring(10, 12));
        final s = int.parse(str.substring(12, 14));
        return DateTime(y, m, d, h, min, s);
      } catch (_) {}
    }

    // Try YYYY-MM-DD HH:MM:SS
    try {
      return DateTime.parse(str);
    } catch (_) {}

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EpgBloc(api: IpTvApi()),
      child: Scaffold(
        backgroundColor: kColorBackground,
        appBar: AppBar(
          backgroundColor: kColorCard,
          elevation: 0,
          title: const Text("TV Guide",
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                // Jump to Now
                final currentDiff =
                    DateTime.now().difference(_startTime).inMinutes;
                final offset = (currentDiff / 60.0) * _hourWidth;
                if (_horizontalController.hasClients) {
                  _horizontalController.animateTo(offset - 100,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                }
              },
              tooltip: "Jump to Now",
            ),
          ],
        ),
        body: Column(
          children: [
            // 1. Time Header
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Container(
                    width: 250,
                    color: kColorCard,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Text("Channels",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16)),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Row(
                        children: List.generate(
                          _endTime.difference(_startTime).inHours,
                          (index) {
                            final time = _startTime.add(Duration(hours: index));
                            final isNow = DateTime.now().hour == time.hour &&
                                DateTime.now().day == time.day;
                            return Container(
                              width: _hourWidth,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border: const Border(
                                    left: BorderSide(color: Colors.white12)),
                                color: kColorCard,
                              ),
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                DateFormat('hh:mm a').format(time),
                                style: TextStyle(
                                    color:
                                        isNow ? kColorPrimary : Colors.white70,
                                    fontWeight: isNow
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT: Channels List
                  SizedBox(
                    width: 250,
                    child: ListView.builder(
                      controller: _verticalController1,
                      itemCount: widget.channels.length,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final channel = widget.channels[index];
                        final isSelected = channel.streamId.toString() ==
                            widget.initialChannelId;
                        return Container(
                          height: _channelHeight,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kColorPrimary.withOpacity(0.2)
                                : (index % 2 == 0
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent),
                            border: const Border(
                                bottom: BorderSide(color: Colors.white10)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.black26,
                                ),
                                child: channel.streamIcon != null &&
                                        channel.streamIcon!.isNotEmpty
                                    ? CachedNetworkImage(
                                        // Use cached image
                                        imageUrl: channel.streamIcon!,
                                        fit: BoxFit.contain,
                                        errorWidget: (_, __, ___) => const Icon(
                                            Icons.tv,
                                            color: Colors.white54,
                                            size: 20),
                                      )
                                    : const Icon(Icons.tv,
                                        color: Colors.white54, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  channel.name ?? "Channel ${index + 1}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              ),
                              // Play Button
                              IconButton(
                                icon: const Icon(Icons.play_circle_outline,
                                    color: Colors.white70, size: 20),
                                onPressed: () {
                                  // Navigate to player
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (_) {
                                    final format =
                                        GetStorage().read('stream_format') ??
                                            'ts';
                                    return MediaKitPlayerScreen(
                                      link:
                                          "${GetStorage().read('server_url') ?? ''}/live/${GetStorage().read('username')}/${GetStorage().read('password')}/${channel.streamId}.$format",
                                      title: channel.name ?? "Live Stream",
                                      isLive: true,
                                    );
                                  }));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // RIGHT: EPG Grid
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: _hourWidth *
                            _endTime.difference(_startTime).inHours,
                        child: ListView.builder(
                          controller: _verticalController2,
                          itemCount: widget.channels.length,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final channel = widget.channels[index];
                            return EpgRowItem(
                              key: ValueKey(channel.streamId),
                              channel: channel,
                              startTime: _startTime,
                              hourWidth: _hourWidth,
                              height: _channelHeight,
                              timeParser: _parseEpgTime,
                            );
                          },
                        ),
                      ),
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

class EpgRowItem extends StatefulWidget {
  final ChannelLive channel;
  final DateTime startTime;
  final double hourWidth;
  final double height;
  final DateTime? Function(String?) timeParser;

  const EpgRowItem({
    super.key,
    required this.channel,
    required this.startTime,
    required this.hourWidth,
    required this.height,
    required this.timeParser,
  });

  @override
  State<EpgRowItem> createState() => _EpgRowItemState();
}

class _EpgRowItemState extends State<EpgRowItem> {
  @override
  void initState() {
    super.initState();
    // Fetch EPG for this channel
    context
        .read<EpgBloc>()
        .add(LoadEpgForChannel(widget.channel.streamId.toString()));
  }

  String _decodeText(String? text) {
    if (text == null || text.isEmpty) return "";
    try {
      return utf8.decode(base64.decode(text));
    } catch (e) {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: BlocBuilder<EpgBloc, EpgState>(
        builder: (context, state) {
          final epgList =
              state.epgMap[widget.channel.streamId.toString()] ?? [];
          final isLoading =
              state.loadingStatus[widget.channel.streamId.toString()] ?? false;

          if (isLoading) {
            return Center(
                child: SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                        strokeWidth: 1, color: Colors.white10)));
          }

          if (epgList.isEmpty) {
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: Text("No Program Information",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontStyle: FontStyle.italic,
                      fontSize: 12)),
            );
          }

          return Stack(
            clipBehavior: Clip.none,
            children: epgList.map((epg) {
              // Prefer timestamps if available, otherwise use formatted strings
              final start = widget.timeParser(epg.startTimestamp ?? epg.start);
              final end = widget.timeParser(epg.stopTimestamp ?? epg.end);

              if (start == null || end == null) return const SizedBox();

              final startOffsetMin =
                  start.difference(widget.startTime).inMinutes;
              final durationMin = end.difference(start).inMinutes;

              // Calculate position
              final double left = (startOffsetMin / 60.0) * widget.hourWidth;
              final double width = (durationMin / 60.0) * widget.hourWidth;

              // Don't render if completely out of view (basic optimization)
              if (left + width < 0) return const SizedBox();

              final isCurrent =
                  DateTime.now().isAfter(start) && DateTime.now().isBefore(end);

              return Positioned(
                left: left,
                width: width,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: kColorCard,
                        title: Text(_decodeText(epg.title),
                            style: const TextStyle(color: Colors.white)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Time: ${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}",
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            if (epg.description != null &&
                                epg.description!.isNotEmpty)
                              Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                child: SingleChildScrollView(
                                  child: Text(_decodeText(epg.description),
                                      style: const TextStyle(
                                          color: Colors.white54)),
                                ),
                              )
                            else
                              const Text("No description available.",
                                  style: TextStyle(color: Colors.white38)),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kColorPrimary),
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (_) {
                                final format =
                                    GetStorage().read('stream_format') ?? 'ts';
                                return MediaKitPlayerScreen(
                                  link:
                                      "${GetStorage().read('server_url') ?? ''}/live/${GetStorage().read('username')}/${GetStorage().read('password')}/${widget.channel.streamId}.$format",
                                  title: widget.channel.name ?? "Live Stream",
                                  isLive: true,
                                );
                              }));
                            },
                            child: const Text("Watch Channel",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? kColorPrimary.withOpacity(0.6)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: isCurrent ? kColorPrimary : Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _decodeText(epg.title),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
