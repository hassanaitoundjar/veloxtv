part of '../screens.dart';

// Screen size tiers, auto-detected from available width.
enum _ScreenTier { phone, tablet, large }

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  _ScreenTier _tierFor(double width) {
    if (width < 650) return _ScreenTier.phone;
    if (width < 1100) return _ScreenTier.tablet;
    return _ScreenTier.large;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 650;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Original dark color scheme
        decoration: kDecorBackground,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tier = _tierFor(constraints.maxWidth);
              final isLarge = tier == _ScreenTier.large;

              // Scale factor only kicks in for large/TV screens so phone and
              // tablet behavior stays exactly as before.
              final logoSize = isLarge ? 64.0 : (isWide ? 48.0 : 36.0);
              final titleFont = isLarge ? 30.0 : (isWide ? 22.0 : 16.0);
              final proFont = isLarge ? 16.0 : (isWide ? 13.0 : 10.0);
              final cardMaxWidth = isLarge ? 1200.0 : 860.0;
              final cardPadding = isLarge ? 48.0 : (isWide ? 32.0 : 20.0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top-left Logo ──
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLarge ? 56 : (isWide ? 40 : 20),
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          kIconSplash,
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: kAppName.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: titleFont,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              TextSpan(
                                text: "  PRO",
                                style: GoogleFonts.outfit(
                                  fontSize: proFont,
                                  fontWeight: FontWeight.w500,
                                  color: kColorPrimary,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Center White Card ──
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLarge ? 80 : (isWide ? 60 : 16),
                          vertical: 16,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: cardMaxWidth),
                          child: Container(
                            padding: EdgeInsets.all(cardPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 40,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: isWide
                                ? _buildWideLayout(context, tier)
                                : _buildNarrowLayout(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Wide: 2-column grid + centered bottom button ──
  Widget _buildWideLayout(BuildContext context, _ScreenTier tier) {
    final isLarge = tier == _ScreenTier.large;
    final buttonHeight = isLarge ? 72.0 : 56.0;
    final fontSize = isLarge ? 17.0 : 13.0;
    final iconSize = isLarge ? 28.0 : 22.0;

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: _SmOption(
                    icon: Icons.playlist_play_rounded,
                    label: "LOGIN WITH M3U FILE OR URL",
                    highlighted: true,
                    onTap: () => Get.toNamed(screenRegisterM3u),
                    autoFocus: true,
                    height: buttonHeight,
                    fontSize: fontSize,
                    iconSize: iconSize,
                  ),
                ),
              ),
              SizedBox(width: isLarge ? 24 : 16),
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(2),
                  child: _SmOption(
                    icon: Icons.api_rounded,
                    label: "LOGIN WITH XTREAM CODES API",
                    onTap: () => Get.toNamed(screenRegister),
                    autoFocus: false,
                    height: buttonHeight,
                    fontSize: fontSize,
                    iconSize: iconSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 24 : 16),
          // Centered "List Users" button
          Center(
            child: SizedBox(
              width: isLarge ? 360 : 300,
              child: FocusTraversalOrder(
                order: const NumericFocusOrder(3),
                child: _SmOption(
                  icon: Icons.people_alt_rounded,
                  label: "LIST USERS",
                  onTap: () => Get.toNamed(screenProfiles),
                  height: buttonHeight,
                  fontSize: fontSize,
                  iconSize: iconSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Narrow: stacked list ──
  Widget _buildNarrowLayout(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FocusTraversalOrder(
            order: const NumericFocusOrder(1),
            child: _SmOption(
              icon: Icons.playlist_play_rounded,
              label: "LOAD YOUR PLAYLIST OR FILE/URL",
              highlighted: true,
              onTap: () => Get.toNamed(screenRegisterM3u),
              autoFocus: true,
            ),
          ),
          const SizedBox(height: 12),
          FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: _SmOption(
              icon: Icons.api_rounded,
              label: "LOGIN WITH XTREAM CODES API",
              onTap: () => Get.toNamed(screenRegister),
              autoFocus: false,
            ),
          ),
          const SizedBox(height: 12),
          FocusTraversalOrder(
            order: const NumericFocusOrder(3),
            child: _SmOption(
              icon: Icons.people_alt_rounded,
              label: "LIST USERS",
              onTap: () => Get.toNamed(screenProfiles),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Smarters-style option row button (focus-aware for TV remote) ──
class _SmOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;
  final bool autoFocus;
  final double height;
  final double fontSize;
  final double iconSize;

  const _SmOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
    this.autoFocus = false,
    this.height = 56,
    this.fontSize = 13,
    this.iconSize = 22,
  });

  @override
  State<_SmOption> createState() => _SmOptionState();
}

class _SmOptionState extends State<_SmOption> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    // Blue ONLY when focused (TV remote or touch) — never by default
    final bool isBlue = _isFocused;

    return Focus(
      autofocus: widget.autoFocus,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
             event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: isBlue
                ? const LinearGradient(
                    colors: [kColorPrimary, kColorPrimaryDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isBlue ? null : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isBlue ? kColorPrimary : const Color(0xFFCBD5E1),
              width: isBlue ? 2 : 1.5,
            ),
            boxShadow: isBlue
                ? [
                    BoxShadow(
                      color: kColorPrimary.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: isBlue ? Colors.white : kColorPrimary,
                size: widget.iconSize,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.label,
                    style: GoogleFonts.outfit(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w700,
                      color: isBlue ? Colors.white : const Color(0xFF1E293B),
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isBlue ? Colors.white70 : const Color(0xFF94A3B8),
                size: widget.iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}