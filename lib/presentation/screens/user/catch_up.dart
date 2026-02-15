part of '../screens.dart';

class CatchUpScreen extends StatefulWidget {
  final ChannelLive channel;

  const CatchUpScreen({super.key, required this.channel});

  @override
  State<CatchUpScreen> createState() => _CatchUpScreenState();
}

class _CatchUpScreenState extends State<CatchUpScreen> {
  List<EpgModel> _epgList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEpg();
  }

  Future<void> _fetchEpg() async {
    if (widget.channel.streamId == null) return;
    final list = await IpTvApi.getEPGbyStreamId(widget.channel.streamId!);
    if (mounted) {
      setState(() {
        _epgList = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter for past events only (archives)
    final now = DateTime.now();
    final pastEvents = _epgList.where((epg) {
      if (epg.stopTimestamp == null) return false;
      try {
        final endDt = DateTime.fromMillisecondsSinceEpoch(
            int.parse(epg.stopTimestamp!) * 1000);
        return endDt.isBefore(now);
      } catch (_) {
        return false;
      }
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.channel.name ?? "Catch Up"),
        leading: const BackButton(color: Colors.white),
      ),
      body: Ink(
        width: getSize(context).width,
        height: getSize(context).height,
        decoration: kDecorBackground,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : pastEvents.isEmpty
                ? const Center(
                    child: Text("No catch-up available",
                        style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 100, bottom: 20),
                    itemCount: pastEvents.length,
                    itemBuilder: (context, index) {
                      final epg = pastEvents[index];
                      // Use epg.title, start, end, description
                      String timeDisplay =
                          "${epg.start ?? ""} - ${epg.end ?? ""}";
                      try {
                        if (epg.startTimestamp != null &&
                            epg.stopTimestamp != null) {
                          final s = DateTime.fromMillisecondsSinceEpoch(
                              int.parse(epg.startTimestamp!) * 1000);
                          final e = DateTime.fromMillisecondsSinceEpoch(
                              int.parse(epg.stopTimestamp!) * 1000);
                          String fmt(DateTime dt) =>
                              "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                          timeDisplay = "${fmt(s)} - ${fmt(e)}";
                        }
                      } catch (_) {}

                      // Logic to play
                      return Card(
                        color: Colors.white10,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(epg.title ?? "No Title",
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(timeDisplay,
                              style: const TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_circle_outline,
                                color: kColorPrimary),
                            onPressed: () async {
                              // Play Catch-up
                              if (epg.startTimestamp != null &&
                                  epg.stopTimestamp != null) {
                                try {
                                  final startDt =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(epg.startTimestamp!) *
                                              1000);
                                  final endDt =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(epg.stopTimestamp!) * 1000);
                                  final durationMin =
                                      endDt.difference(startDt).inMinutes;

                                  final user = await LocaleApi.getUser();
                                  if (user != null) {
                                    final catchUpUrl =
                                        IpTvApi.constructCatchUpUrl(
                                      baseUrl: user.serverInfo!.serverUrl!,
                                      username: user.userInfo!.username!,
                                      password: user.userInfo!.password!,
                                      streamId: widget.channel.streamId!,
                                      startTimestamp:
                                          "${startDt.millisecondsSinceEpoch ~/ 1000}",
                                      duration: durationMin.toString(),
                                    );

                                    Get.to(() => MediaKitPlayerScreen(
                                          title: "${epg.title} (Catch-up)",
                                          link: catchUpUrl,
                                          isLive: false,
                                        ));
                                  }
                                } catch (e) {
                                  debugPrint("Error parsing dates: $e");
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
