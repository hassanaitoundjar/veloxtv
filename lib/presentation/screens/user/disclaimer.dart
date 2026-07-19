part of '../screens.dart';

class _DisclaimerSizes {
  final double maxWidth;
  final double horizontalMargin;
  final double containerPadding;
  final double borderRadius;
  final double iconPadding;
  final double iconSize;
  final double spacingAfterIcon;
  final double titleFontSize;
  final double titleLetterSpacing;
  final double spacingAfterTitle;
  final double bodyFontSize;
  final double bodyLineHeight;
  final double spacingBeforeButton;
  final double buttonHeight;
  final double buttonFontSize;
  final double buttonLetterSpacing;

  const _DisclaimerSizes({
    required this.maxWidth,
    required this.horizontalMargin,
    required this.containerPadding,
    required this.borderRadius,
    required this.iconPadding,
    required this.iconSize,
    required this.spacingAfterIcon,
    required this.titleFontSize,
    required this.titleLetterSpacing,
    required this.spacingAfterTitle,
    required this.bodyFontSize,
    required this.bodyLineHeight,
    required this.spacingBeforeButton,
    required this.buttonHeight,
    required this.buttonFontSize,
    required this.buttonLetterSpacing,
  });

  // Small phones (< 360)
  static const compact = _DisclaimerSizes(
    maxWidth: 340,
    horizontalMargin: 12,
    containerPadding: 20,
    borderRadius: 16,
    iconPadding: 12,
    iconSize: 36,
    spacingAfterIcon: 16,
    titleFontSize: 18,
    titleLetterSpacing: 0.8,
    spacingAfterTitle: 16,
    bodyFontSize: 12.5,
    bodyLineHeight: 1.5,
    spacingBeforeButton: 28,
    buttonHeight: 48,
    buttonFontSize: 14,
    buttonLetterSpacing: 1.0,
  );

  // Standard phones (360–599)
  static const phone = _DisclaimerSizes(
    maxWidth: 500,
    horizontalMargin: 24,
    containerPadding: 32,
    borderRadius: 20,
    iconPadding: 16,
    iconSize: 48,
    spacingAfterIcon: 24,
    titleFontSize: 24,
    titleLetterSpacing: 1.2,
    spacingAfterTitle: 24,
    bodyFontSize: 14,
    bodyLineHeight: 1.6,
    spacingBeforeButton: 40,
    buttonHeight: 56,
    buttonFontSize: 16,
    buttonLetterSpacing: 1.5,
  );

  // Tablets (600–899)
  static const tablet = _DisclaimerSizes(
    maxWidth: 600,
    horizontalMargin: 32,
    containerPadding: 40,
    borderRadius: 22,
    iconPadding: 18,
    iconSize: 52,
    spacingAfterIcon: 28,
    titleFontSize: 26,
    titleLetterSpacing: 1.2,
    spacingAfterTitle: 28,
    bodyFontSize: 15,
    bodyLineHeight: 1.6,
    spacingBeforeButton: 44,
    buttonHeight: 60,
    buttonFontSize: 17,
    buttonLetterSpacing: 1.5,
  );

  // Small TV / large tablet (900–1279)
  static const tvSmall = _DisclaimerSizes(
    maxWidth: 720,
    horizontalMargin: 40,
    containerPadding: 44,
    borderRadius: 24,
    iconPadding: 18,
    iconSize: 54,
    spacingAfterIcon: 30,
    titleFontSize: 27,
    titleLetterSpacing: 1.2,
    spacingAfterTitle: 30,
    bodyFontSize: 15.5,
    bodyLineHeight: 1.6,
    spacingBeforeButton: 46,
    buttonHeight: 62,
    buttonFontSize: 17.5,
    buttonLetterSpacing: 1.5,
  );

  // Large TV (>= 1280)
  static const tv = _DisclaimerSizes(
    maxWidth: 800,
    horizontalMargin: 48,
    containerPadding: 48,
    borderRadius: 24,
    iconPadding: 16,
    iconSize: 56,
    spacingAfterIcon: 32,
    titleFontSize: 28,
    titleLetterSpacing: 1.2,
    spacingAfterTitle: 32,
    bodyFontSize: 16,
    bodyLineHeight: 1.6,
    spacingBeforeButton: 48,
    buttonHeight: 64,
    buttonFontSize: 18,
    buttonLetterSpacing: 1.5,
  );

  static _DisclaimerSizes of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isTv(context)) {
      return width >= 1280 ? tv : tvSmall;
    }
    if (width < 360) return compact;
    if (width < 600) return phone;
    if (width < 900) return tablet;
    return tvSmall;
  }
}

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  void _acceptDisclaimer() {
    GetStorage().write('disclaimer_accepted', true);
    Get.offNamed(screenDeviceSelection);
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _DisclaimerSizes.of(context);
    final safeMargins = getTvSafeMargins(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: kDecorBackground,
        padding: safeMargins,
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sizes.maxWidth),
              child: Container(
                padding: EdgeInsets.all(sizes.containerPadding),
                margin:
                    EdgeInsets.symmetric(horizontal: sizes.horizontalMargin),
                decoration: BoxDecoration(
                  color: kColorCard,
                  borderRadius: BorderRadius.circular(sizes.borderRadius),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(sizes.iconPadding),
                      decoration: BoxDecoration(
                        color: kColorPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.gavel_rounded,
                        color: kColorPrimary,
                        size: sizes.iconSize,
                      ),
                    ),
                    SizedBox(height: sizes.spacingAfterIcon),
                    Text(
                      'IMPORTANT DISCLAIMER',
                      style: GoogleFonts.outfit(
                        fontSize: sizes.titleFontSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: sizes.titleLetterSpacing,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: sizes.spacingAfterTitle),
                    Text(
                      'This application is a media player intended for playing user-provided content.\n\n'
                      '• We do not provide, host, or supply any media content, streams, or playlists.\n'
                      '• You must use your own legal content.\n'
                      '• We do not endorse the streaming of copyright-protected material without permission from the copyright holder.',
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: kColorTextSecondary,
                        height: sizes.bodyLineHeight,
                        fontSize: sizes.bodyFontSize,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: sizes.spacingBeforeButton),
                    FocusableCard(
                      onTap: _acceptDisclaimer,
                      scale: 1.02,
                      child: Container(
                        width: double.infinity,
                        height: sizes.buttonHeight,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kColorPrimary, kColorPrimaryDark],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "I ACCEPT",
                            style: GoogleFonts.outfit(
                              fontSize: sizes.buttonFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: sizes.buttonLetterSpacing,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
