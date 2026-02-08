part of 'widgets.dart';

class AppBarLive extends StatefulWidget {
  final Function(String)? onSearch;
  final VoidCallback? onToggleView;
  final bool isGridView;

  const AppBarLive({
    super.key,
    this.onSearch,
    this.onToggleView,
    this.isGridView = true,
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
        ],
      ),
    );
  }
}

class SideCategoryMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      color: kColorPanel,
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.categoryId == selectedId.toString();

          return FocusableCard(
            onTap: () => onSelect(cat),
            scale: 1.02,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color: isSelected ? kColorPrimary.withOpacity(0.2) : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cat.categoryName ?? "Unknown",
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: isSelected ? kColorPrimary : kColorTextSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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
  final VoidCallback onTap;

  const ListChannelItem({
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
          ],
        ),
      ),
    );
  }
}
