part of '../screens.dart';

/// Lists all live channels that support Catch-Up (tvArchive == 1),
/// grouped by category. Tapping a channel opens its [CatchUpScreen].
class CatchUpChannelsScreen extends StatefulWidget {
  const CatchUpChannelsScreen({super.key});

  @override
  State<CatchUpChannelsScreen> createState() => _CatchUpChannelsScreenState();
}

class _CatchUpChannelsScreenState extends State<CatchUpChannelsScreen> {
  List<ChannelLive> _channels = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchChannels() async {
    try {
      final all = await IpTvApi().getLiveChannels(null);
      // Keep only channels that support catch-up and have a valid archive duration
      final archiveChannels =
          all.where((c) => c.tvArchive == 1 && (c.tvArchiveDuration ?? 0) > 0).toList()
            ..sort((a, b) => (a.num ?? 0).compareTo(b.num ?? 0));
      if (mounted) {
        setState(() {
          _channels = archiveChannels;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching catch-up channels: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ChannelLive> get _filtered {
    if (_searchQuery.isEmpty) return _channels;
    final q = _searchQuery.toLowerCase();
    return _channels.where((c) {
      return (c.name ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 0,
        title: const Text('Catch-Up TV',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search channels with catch-up...',
                  hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white.withValues(alpha: 0.4), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon:
                              const Icon(Icons.clear, color: Colors.white54, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: kDecorBackground,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kColorPrimary))
            : _channels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'No channels with Catch-Up support',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Catch-Up requires server-side recording support.',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.25),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No channels match "$_searchQuery"',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4)),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                            top: isPhone ? 140 : 160, bottom: 32),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final channel = _filtered[index];
                          final archiveDays =
                              channel.tvArchiveDuration ?? 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: FocusableCard(
                              onTap: () {
                                Get.to(
                                    () => CatchUpScreen(channel: channel));
                              },
                              scale: 1.02,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isPhone ? 12 : 16,
                                    vertical: isPhone ? 10 : 14),
                                decoration: BoxDecoration(
                                  color: kColorCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    // Channel icon
                                    Container(
                                      width: isPhone ? 40 : 50,
                                      height: isPhone ? 40 : 50,
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: channel.streamIcon != null &&
                                              channel
                                                  .streamIcon!.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  channel.streamIcon!,
                                              fit: BoxFit.contain,
                                              errorWidget:
                                                  (_, __, ___) =>
                                                      const Icon(
                                                          Icons.tv,
                                                          color: Colors
                                                              .white24,
                                                          size: 24),
                                            )
                                          : const Icon(Icons.tv,
                                              color: Colors.white24,
                                              size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    // Channel info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            channel.name ?? 'Channel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  isPhone ? 13 : 15,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.history,
                                                  color: kColorPrimary,
                                                  size: isPhone
                                                      ? 12
                                                      : 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                archiveDays > 0
                                                    ? '$archiveDays day${archiveDays == 1 ? '' : 's'} archive'
                                                    : 'Archive available',
                                                style: TextStyle(
                                                  color: kColorPrimary,
                                                  fontSize:
                                                      isPhone ? 11 : 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Arrow
                                    Icon(Icons.chevron_right,
                                        color: Colors.white24,
                                        size: isPhone ? 20 : 24),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
