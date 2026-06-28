part of 'widgets.dart';

class AppBarLive extends StatefulWidget {
  final Function(String)? onSearch;
  final VoidCallback? onToggleView;
  final VoidCallback? onTimeline;
  final bool isGridView;
  final FocusNode? focusNode;

  const AppBarLive({
    super.key,
    this.onSearch,
    this.onToggleView,
    this.onTimeline,
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
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ??
        FocusNode(onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              FocusScope.of(context).focusInDirection(TraversalDirection.down);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              FocusScope.of(context).focusInDirection(TraversalDirection.up);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              FocusScope.of(context).focusInDirection(TraversalDirection.left);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              FocusScope.of(context).focusInDirection(TraversalDirection.right);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        });
    _updateTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _currentTime = DateTimeFormatService.formatTime(now);
        _currentDate = DateTimeFormatService.formatDate(now);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;

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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width *
                            (isPhone ? 0.35 : 0.25)),
                    child: Container(
                      height: isPhone ? 32 : 40,
                      margin: EdgeInsets.only(right: isPhone ? 8 : 16),
                      decoration: BoxDecoration(
                        color: kColorCardLight,
                        borderRadius: BorderRadius.circular(isPhone ? 16 : 20),
                      ),
                      child: TvTextField(
                        focusNode: _internalFocusNode,
                        style: TextStyle(
                            color: Colors.white, fontSize: isPhone ? 12 : 14),
                        decoration: InputDecoration(
                          hintText: "Search...",
                          hintStyle: TextStyle(
                              color: Colors.white38,
                              fontSize: isPhone ? 11 : 13),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.white54, size: isPhone ? 16 : 20),
                          border: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: isPhone ? 7 : 10),
                        ),
                        onChanged: widget.onSearch,
                      ),
                    ),
                  ),
                  if (widget.onTimeline != null)
                    IconButton(
                      onPressed: widget.onTimeline,
                      icon: Icon(Icons.view_timeline,
                          color: Colors.white, size: isPhone ? 18 : 24),
                      tooltip: "Timeline View",
                      padding: EdgeInsets.all(isPhone ? 4 : 8),
                      constraints: BoxConstraints(
                        minWidth: isPhone ? 28 : 40,
                        minHeight: isPhone ? 28 : 40,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SideCategoryMenu extends StatefulWidget {
  final List<CategoryModel> categories;
  final String selectedId;
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
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          FocusScope.of(context).focusInDirection(TraversalDirection.right);
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final catFontSize = isPhone ? 11.0 : (screenWidth < 1200 ? 14.0 : 16.0);

    return Container(
      width: isPhone ? 35.w : 25.w,
      color: kColorPanel,
      child: Column(
        children: [
          // Category Search Field
          Padding(
            padding: EdgeInsets.fromLTRB(isPhone ? 8 : 12, isPhone ? 6 : 10,
                isPhone ? 8 : 12, isPhone ? 4 : 8),
            child: Container(
              height: isPhone ? 30 : 40,
              decoration: BoxDecoration(
                color: kColorCardLight,
                borderRadius: BorderRadius.circular(isPhone ? 16 : 8),
              ),
              child: TvTextField(
                focusNode: _searchFocusNode,
                style:
                    TextStyle(color: Colors.white, fontSize: isPhone ? 11 : 14),
                decoration: InputDecoration(
                  hintText: "Search By Categories...",
                  hintStyle: TextStyle(
                      color: Colors.white38, fontSize: isPhone ? 10 : 13),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white54, size: isPhone ? 14 : 18),
                  border: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: isPhone ? 6 : 10),
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
                    cat.categoryId == widget.selectedId;

                return FocusableCard(
                  onTap: () => widget.onSelect(cat),
                  scale: 1.02,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: isPhone ? 8 : 16,
                        horizontal: isPhone ? 10 : 20),
                    color: isSelected
                        ? Color.fromRGBO(kColorPrimary.red, kColorPrimary.green,
                            kColorPrimary.blue, 0.2)
                        : null,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            cat.categoryName ?? "Unknown",
                            style: TextStyle(
                              fontSize: catFontSize,
                              color: isSelected
                                  ? kColorPrimary
                                  : kColorTextSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.arrow_forward_ios,
                              size: isPhone ? 10 : 14, color: kColorPrimary),
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
    // Detect narrow screen (phone) using shortestSide
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final iconSize = isPhone ? 25.0 : 50.0;
    final hPad = isPhone ? 6.0 : 12.0;
    final vPad = isPhone ? 6.0 : 10.0;
    final gap = isPhone ? 6.0 : 12.0;

    return FocusableCard(
      onTap: onTap,
      scale: 1.02,
      child: Container(
        constraints: BoxConstraints(
          minHeight: isPhone ? 40 : 60,
        ),
        margin: const EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: kDecorCard.copyWith(
          color: isFocus
              ? Color.fromRGBO(kColorPrimary.red, kColorPrimary.green,
                  kColorPrimary.blue, 0.2)
              : kColorCardLight,
          border: isFocus
              ? const Border(left: BorderSide(color: kColorPrimary, width: 4))
              : null,
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: iconSize,
              height: iconSize,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              child: CachedNetworkImage(
                imageUrl: icon ?? "",
                errorWidget: (_, __, ___) => Icon(Icons.tv,
                    size: isPhone ? 16 : 24, color: Colors.white24),
                placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5)),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: gap),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isPhone ? 10 : 14,
                      color: isFocus ? Colors.white : kColorTextPrimary,
                    ),
                    // Allow 2 lines on phone so long names are readable
                    maxLines: isPhone ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Hide EPG subtitle on phone to save vertical space
                  if (epg != null && !isPhone) ...[
                    const SizedBox(height: 4),
                    Text(
                      epg!,
                      style: TextStyle(
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
                    color: isFavorite ? Colors.blue : Colors.white38,
                    size: 20,
                  ),
                  onPressed: onFavoriteToggle,
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
