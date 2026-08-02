part of 'widgets.dart';

class AppBarWelcome extends StatefulWidget {
  final String expiration;
  final String username;

  const AppBarWelcome(
      {super.key, required this.expiration, required this.username});

  @override
  State<AppBarWelcome> createState() => _AppBarWelcomeState();
}

class _AppBarWelcomeState extends State<AppBarWelcome> {
  String _formatExpiration(String exp) {
    if (exp.isEmpty) return "N/A";
    final timestamp = int.tryParse(exp);
    if (timestamp != null) {
      // Check if it's in seconds or milliseconds
      final date = DateTime.fromMillisecondsSinceEpoch(
          timestamp > 9999999999 ? timestamp : timestamp * 1000);
      return DateFormat('MMMM d, yyyy').format(date).toUpperCase();
    }
    return exp.toUpperCase();
  }

  Widget _buildCircleButton(
      {required IconData icon,
      required String tooltip,
      required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: Focus(
        child: Builder(builder: (context) {
          final isFocused = Focus.of(context).hasFocus;
          final width = MediaQuery.of(context).size.width;
          final isMobile = width < 600;
          final isTablet = width < 900;
          
          final double padding = isMobile ? 6 : (isTablet ? 8 : 10);
          final double margin = isMobile ? 4 : (isTablet ? 8 : 12);
          final double iconSize = isMobile ? 16 : (isTablet ? 18 : 22);

          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: EdgeInsets.all(padding),
              margin: EdgeInsets.only(left: margin),
              decoration: BoxDecoration(
                color: isFocused ? Colors.white30 : Colors.white10,
                shape: BoxShape.circle,
                border: isFocused
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
              child: Icon(icon,
                  color: isFocused ? Colors.white : Colors.white70, size: iconSize),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      child: Row(
        children: [
          // LEFT: Logo & Search
          Builder(builder: (context) {
            final width = MediaQuery.of(context).size.width;
            final isMobile = width < 600;
            final isTablet = width < 900;

            final double logoSize = isMobile ? 14 : (isTablet ? 15 : 26);
            final double searchIconSize = isMobile ? 15 : 16;
            final double searchFontSize = isMobile ? 12 : 14;
            final double gap = isMobile ? 12 : 24;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "VANTO",
                  style: GoogleFonts.rubik(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: logoSize,
                    letterSpacing: 1,
                  ),
                ),
                if (!isMobile)
                  Text(
                    " PLAYER",
                    style: GoogleFonts.rubik(
                      color: kAccentColor,
                      fontWeight: FontWeight.w400,
                      fontSize: logoSize,
                    ),
                  ),
                SizedBox(width: gap),
                Container(
                    width: 1,
                    height: isMobile ? 18 : 24,
                    color: Colors.white24),
                SizedBox(width: gap),
                Focus(
                  child: Builder(builder: (context) {
                    final isFocused = Focus.of(context).hasFocus;
                    return InkWell(
                      onTap: () => Get.toNamed(screenSearch),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 12,
                            vertical: isMobile ? 6 : 8),
                        decoration: BoxDecoration(
                          color: isFocused
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          border: isFocused
                              ? Border.all(color: Colors.white, width: 2)
                              : Border.all(color: Colors.transparent, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(isMobile ? 6 : 10),
                              decoration: BoxDecoration(
                                color: isFocused
                                    ? Colors.transparent
                                    : Colors.white10,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.mic_none,
                                  color:
                                      isFocused ? Colors.white : Colors.white70,
                                  size: searchIconSize),
                            ),
                            if (!isMobile) ...[
                              const SizedBox(width: 12),
                              Text(
                                "Search",
                                style: TextStyle(
                                    color: isFocused
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: searchFontSize),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          }),

          const Spacer(),

          // CENTER: Subscription Expiration
          Builder(builder: (context) {
            final width = MediaQuery.of(context).size.width;
            final isMobile = width < 600;
            final isTablet = width < 900;

            final double iconSize = isMobile ? 9 : 18;
            final double fontSize = isMobile ? 9 : (isTablet ? 9 : 12);
            final double paddingH = isMobile ? 9 : 20;
            final double paddingV = isMobile ? 6 : 12;
            final String prefixText = isMobile ? "EXP: " : "SUBSCRIPTION EXP: ";

            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: paddingH, vertical: paddingV),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined,
                      color: kAccentColor, size: iconSize),
                  SizedBox(width: isMobile ? 4 : 10),
                  Text(
                    prefixText,
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    _formatExpiration(widget.expiration),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Spacer(),

          // RIGHT: Action Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCircleButton(
                icon: Icons.refresh,
                tooltip: "Reload Data",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            "Reloading data...",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.black87,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: 300,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  context.read<LiveCatyBloc>().add(GetLiveCategories());
                  context.read<MovieCatyBloc>().add(GetMovieCategories());
                  context.read<SeriesCatyBloc>().add(GetSeriesCategories());
                },
              ),
              _buildCircleButton(
                icon: Icons.settings_outlined,
                tooltip: "Settings",
                onTap: () => Get.toNamed(screenSettings),
              ),
              Builder(builder: (context) => SizedBox(width: MediaQuery.of(context).size.width < 600 ? 8 : 16)),
              Focus(
                child: Builder(builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;
                  final width = MediaQuery.of(context).size.width;
                  final isMobile = width < 600;
                  final isTablet = width < 900;
                  
                  final double boxSize = isMobile ? 32 : (isTablet ? 38 : 44);
                  final double fontSize = isMobile ? 14 : (isTablet ? 16 : 18);

                  return InkWell(
                    onTap: () => Get.toNamed(screenAccountProfile),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        color: kAccentColor,
                        shape: BoxShape.circle,
                        border: isFocused
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.username.isNotEmpty
                            ? widget.username[0].toUpperCase()
                            : "U",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardWelcomeTv extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final VoidCallback onTap;
  final bool autoFocus;

  const CardWelcomeTv({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onTap: onTap,
      autoFocus: autoFocus,
      scale: 1.05,
      child: Container(
        decoration: kDecorCard.copyWith(color: kColorCard),
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, width: 8.w, height: 8.w),
              SizedBox(height: 2.h),
              Text(title, style: Get.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Get.textTheme.bodyMedium
                    ?.copyWith(color: kColorTextSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardWelcomeSetting extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  final bool autoFocus;

  const CardWelcomeSetting({
    super.key,
    required this.title,
    required this.icon,
    this.autoFocus = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onTap: onTap,
      autoFocus: autoFocus,
      scale: 1.02,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: kDecorCard.copyWith(
          color: kColorCardLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: kDecorIconCircle,
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(title, style: Get.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
