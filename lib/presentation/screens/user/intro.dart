part of '../screens.dart';

/// Responsive size tokens for IntroScreen across all device classes.
class _IntroSizes {
  final double logoSize;
  final double titleFont;
  final double proFont;
  final double cardMaxWidth;
  final double cardPadding;
  final double horizontalMargin;
  final double buttonHeight;
  final double buttonFontSize;
  final double buttonIconSize;
  final double buttonGap;
  final double bottomButtonWidth;
  final bool isWide;

  const _IntroSizes({
    required this.logoSize,
    required this.titleFont,
    required this.proFont,
    required this.cardMaxWidth,
    required this.cardPadding,
    required this.horizontalMargin,
    required this.buttonHeight,
    required this.buttonFontSize,
    required this.buttonIconSize,
    required this.buttonGap,
    required this.bottomButtonWidth,
    required this.isWide,
  });

  factory _IntroSizes.of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTvDevice = isTv(context);

    // --- Small phone (< 360) ---
    if (width < 360) {
      return const _IntroSizes(
        logoSize: 28.0,
        titleFont: 14.0,
        proFont: 9.0,
        cardMaxWidth: 340.0,
        cardPadding: 16.0,
        horizontalMargin: 12.0,
        buttonHeight: 50.0,
        buttonFontSize: 11.0,
        buttonIconSize: 20.0,
        buttonGap: 10.0,
        bottomButtonWidth: double.infinity,
        isWide: false,
      );
    }
    // --- Standard phone (360 - 599) ---
    if (width < 600) {
      return const _IntroSizes(
        logoSize: 36.0,
        titleFont: 16.0,
        proFont: 10.0,
        cardMaxWidth: 500.0,
        cardPadding: 20.0,
        horizontalMargin: 16.0,
        buttonHeight: 56.0,
        buttonFontSize: 13.0,
        buttonIconSize: 22.0,
        buttonGap: 12.0,
        bottomButtonWidth: double.infinity,
        isWide: false,
      );
    }
    // --- Tablet portrait (600 - 899) ---
    if (width < 900) {
      return const _IntroSizes(
        logoSize: 48.0,
        titleFont: 22.0,
        proFont: 13.0,
        cardMaxWidth: 700.0,
        cardPadding: 28.0,
        horizontalMargin: 40.0,
        buttonHeight: 64.0,
        buttonFontSize: 13.0,
        buttonIconSize: 24.0,
        buttonGap: 16.0,
        bottomButtonWidth: 300.0,
        isWide: true,
      );
    }
    // --- Tablet landscape / small desktop (900 - 1279) ---
    if (width < 1280) {
      return const _IntroSizes(
        logoSize: 56.0,
        titleFont: 26.0,
        proFont: 14.0,
        cardMaxWidth: 860.0,
        cardPadding: 32.0,
        horizontalMargin: 60.0,
        buttonHeight: 64.0,
        buttonFontSize: 14.0,
        buttonIconSize: 24.0,
        buttonGap: 16.0,
        bottomButtonWidth: 300.0,
        isWide: true,
      );
    }
    // --- TV / large desktop (>= 1280) ---
    return _IntroSizes(
      logoSize: isTvDevice ? 72.0 : 64.0,
      titleFont: isTvDevice ? 34.0 : 30.0,
      proFont: isTvDevice ? 18.0 : 16.0,
      cardMaxWidth: isTvDevice ? 1300.0 : 1200.0,
      cardPadding: isTvDevice ? 56.0 : 48.0,
      horizontalMargin: isTvDevice ? 100.0 : 80.0,
      buttonHeight: isTvDevice ? 80.0 : 72.0,
      buttonFontSize: isTvDevice ? 19.0 : 17.0,
      buttonIconSize: isTvDevice ? 32.0 : 28.0,
      buttonGap: isTvDevice ? 32.0 : 24.0,
      bottomButtonWidth: isTvDevice ? 400.0 : 360.0,
      isWide: true,
    );
  }
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = _IntroSizes.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Original dark color scheme
        decoration: kDecorBackground,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top-left Logo ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: s.horizontalMargin,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      kIconSplash,
                      width: s.logoSize,
                      height: s.logoSize,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: kAppName.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: s.titleFont,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: "  PRO",
                            style: GoogleFonts.outfit(
                              fontSize: s.proFont,
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
                      horizontal: s.horizontalMargin,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: s.cardMaxWidth),
                      child: Container(
                        padding: EdgeInsets.all(s.cardPadding),
                        decoration: BoxDecoration(
                          color: kColorCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kColorBorder.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 40,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: s.isWide
                            ? _buildWideLayout(s)
                            : _buildNarrowLayout(s),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Wide: 2-column grid + centered bottom button ──
  Widget _buildWideLayout(_IntroSizes s) {
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
                    label: "LOAD YOUR PLAYLIST OR FILE/URL",
                    highlighted: true,
                    onTap: () => Get.toNamed(screenRegisterM3u),
                    autoFocus: true,
                    height: s.buttonHeight,
                    fontSize: s.buttonFontSize,
                    iconSize: s.buttonIconSize,
                  ),
                ),
              ),
              SizedBox(width: s.buttonGap),
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(2),
                  child: _SmOption(
                    icon: Icons.api_rounded,
                    label: "LOGIN WITH XTREAM CODES API",
                    onTap: () => Get.toNamed(screenRegister),
                    autoFocus: false,
                    height: s.buttonHeight,
                    fontSize: s.buttonFontSize,
                    iconSize: s.buttonIconSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: s.buttonGap),
          // Centered "List Users" button
          Center(
            child: SizedBox(
              width: s.bottomButtonWidth,
              child: FocusTraversalOrder(
                order: const NumericFocusOrder(3),
                child: _SmOption(
                  icon: Icons.people_alt_rounded,
                  label: "LIST USERS",
                  onTap: () => Get.toNamed(screenProfiles),
                  height: s.buttonHeight,
                  fontSize: s.buttonFontSize,
                  iconSize: s.buttonIconSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Narrow: stacked list ──
  Widget _buildNarrowLayout(_IntroSizes s) {
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
              height: s.buttonHeight,
              fontSize: s.buttonFontSize,
              iconSize: s.buttonIconSize,
            ),
          ),
          SizedBox(height: s.buttonGap),
          FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: _SmOption(
              icon: Icons.api_rounded,
              label: "LOGIN WITH XTREAM CODES API",
              onTap: () => Get.toNamed(screenRegister),
              autoFocus: false,
              height: s.buttonHeight,
              fontSize: s.buttonFontSize,
              iconSize: s.buttonIconSize,
            ),
          ),
          SizedBox(height: s.buttonGap),
          FocusTraversalOrder(
            order: const NumericFocusOrder(3),
            child: _SmOption(
              icon: Icons.people_alt_rounded,
              label: "LIST USERS",
              onTap: () => Get.toNamed(screenProfiles),
              height: s.buttonHeight,
              fontSize: s.buttonFontSize,
              iconSize: s.buttonIconSize,
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
            color: isBlue ? null : kColorCardLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isBlue ? kColorPrimary : kColorBorder,
              width: isBlue ? 2 : 1.5,
            ),
            boxShadow: isBlue
                ? [
                    BoxShadow(
                      color: kColorPrimary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
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
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isBlue ? Colors.white70 : kColorTextSecondary,
                size: widget.iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}