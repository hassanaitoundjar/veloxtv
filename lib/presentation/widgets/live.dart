part of 'widgets.dart';

class AppBarLive extends StatefulWidget {
  final Function(String)? onSearch;
  final VoidCallback? onToggleView;
  final bool isGridView;
  final FocusNode? focusNode;

  const AppBarLive({
    super.key,
    this.onSearch,
    this.onToggleView,
    this.isGridView = true,
    this.focusNode,
  });

  @override
  State<AppBarLive> createState() => _AppBarLiveState();
}

class _AppBarLiveState extends State<AppBarLive> {
  // Use Timer for clock
  Timer? _timer;
  String _currentTime = "";
  String _currentDate = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('hh:mm a').format(now);
        _currentDate = DateFormat('MMM d, yyyy').format(now);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      color: kColorPanel,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left Side: Back Button & Logo
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 16),
                Image.asset(kIconSplash, width: 40, height: 40),
                const SizedBox(width: 12),
                Text(
                  kAppName,
                  style: Get.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Center: Clock & Date
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentTime,
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: kColorPrimary,
                ),
              ),
              Text(
                _currentDate,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: kColorTextSecondary,
                ),
              ),
            ],
          ),

          // Right Side: Search Field
          if (widget.onSearch != null)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 400,
                height: 40,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: kColorCardLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  focusNode: widget.focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.white54, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: widget.onSearch,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SideCategoryMenu extends StatefulWidget {
  final List<CategoryModel> categories;
  final int selectedId;
  final Function(CategoryModel) onSelect;

  const SideCategoryMenu({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  State<SideCategoryMenu> createState() => _SideCategoryMenuState();
}

class _SideCategoryMenuState extends State<SideCategoryMenu> {
  String _catSearch = "";
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          FocusScope.of(context).nextFocus();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          FocusScope.of(context).previousFocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter categories by search
    final filteredCats = _catSearch.isEmpty
        ? widget.categories
        : widget.categories
            .where((c) =>
                c.categoryName
                    ?.toLowerCase()
                    .contains(_catSearch.toLowerCase()) ??
                false)
            .toList();

    return Container(
      width: 25.w,
      color: kColorPanel,
      child: Column(
        children: [
          // Category Search Field
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: kColorCardLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Search By Categories...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.white54, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (val) => setState(() => _catSearch = val),
              ),
            ),
          ),
          // Category List
          Expanded(
            child: ListView.builder(
              itemCount: filteredCats.length,
              itemBuilder: (context, index) {
                final cat = filteredCats[index];
                final isSelected =
                    cat.categoryId == widget.selectedId.toString();

                return FocusableCard(
                  onTap: () => widget.onSelect(cat),
                  scale: 1.02,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    color: isSelected ? kColorPrimary.withOpacity(0.2) : null,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            cat.categoryName ?? "Unknown",
                            style: Get.textTheme.bodyLarge?.copyWith(
                              color: isSelected
                                  ? kColorPrimary
                                  : kColorTextSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.arrow_forward_ios,
                              size: 14, color: kColorPrimary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CardLiveItem extends StatelessWidget {
  final String title;
  final String? icon;
  final String? epg; // Currently playing
  final bool isFocus;
  final VoidCallback onTap;

  const CardLiveItem({
    super.key,
    required this.title,
    this.icon,
    this.epg,
    required this.onTap,
    this.isFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onTap: onTap,
      scale: 1.05,
      child: Container(
        decoration: kDecorCard.copyWith(
          color: kColorCardLight,
          border: isFocus ? Border.all(color: kColorFocus, width: 2) : null,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: CachedNetworkImage(
                  imageUrl: icon ?? "",
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.tv, size: 40, color: Colors.white24),
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: kColorCardDark,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Get.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (epg != null)
                      Text(
                        epg!,
                        style: Get.textTheme.bodySmall
                            ?.copyWith(color: kColorPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListChannelItem extends StatelessWidget {
  final String title;
  final String? icon;
  final String? epg;
  final bool isFocus;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const ListChannelItem({
    super.key,
    required this.title,
    this.icon,
    this.epg,
    required this.onTap,
    this.isFocus = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onTap: onTap,
      scale: 1.02,
      child: Container(
        height: 70,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: kDecorCard.copyWith(
          color: isFocus ? kColorPrimary.withOpacity(0.2) : kColorCardLight,
          border: isFocus
              ? Border(left: BorderSide(color: kColorPrimary, width: 4))
              : null,
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              child: CachedNetworkImage(
                imageUrl: icon ?? "",
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.tv, size: 24, color: Colors.white24),
                placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isFocus ? Colors.white : kColorTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (epg != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      epg!,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: isFocus ? Colors.white70 : kColorTextSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Favorite Icon
            if (onFavoriteToggle != null)
              ExcludeFocus(
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.yellow : Colors.white38,
                    size: 22,
                  ),
                  onPressed: onFavoriteToggle,
                  splashRadius: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
