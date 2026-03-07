part of '../screens.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect orientation or screen width
    final isPortrait = MediaQuery.of(context).size.width < 600 ||
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width;
    final isMobile = Device.screenType == ScreenType.mobile;

    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        // New Modern Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Deep Dark Blue
              Color(0xFF1E293B), // Slate Blue
              Color(0xFF020617), // Almost Black
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section with New Logo
              Expanded(
                flex: isMobile ? 3 : 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kColorPrimary.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: kColorPrimary.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: isMobile ? 80 : 120,
                        height: isMobile ? 80 : 120,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      kAppName.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 28 : 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: kColorPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: kColorPrimary.withOpacity(0.3)),
                      ),
                      child: Text(
                        "PREMIUM IPTV PLAYER",
                        style: GoogleFonts.outfit(
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: kColorPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Content - Cards
              Expanded(
                flex: isMobile ? 5 : 4,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.0 : 5.w,
                    vertical: 24.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    border: Border(
                      top: BorderSide(
                          color: Colors.white.withOpacity(0.05), width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Select Connection Method",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Choose how you want to access your content",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 14 : 16,
                          color: kColorTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: isPortrait
                            ? _buildMobileLayout()
                            : _buildTvLayout(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ConnectionCard(
            icon: Icons.api_rounded,
            color: kColorPrimary,
            title: "Xtream Codes",
            subtitle: "Login with API Credentials",
            onTap: () => Get.toNamed(screenRegister),
          ),
          const SizedBox(height: 16),
          _ConnectionCard(
            icon: Icons.playlist_play_rounded,
            color: Colors.orange,
            title: "M3U Playlist",
            subtitle: "Load from URL or File",
            onTap: () => Get.toNamed(screenRegisterM3u),
          ),
          const SizedBox(height: 16),
          _ConnectionCard(
            icon: Icons.settings_ethernet_rounded,
            color: Colors.purple,
            title: "Stalker Portal",
            subtitle: "MAC Address Authentication",
            onTap: () => Get.toNamed(screenRegisterStalker),
          ),
        ],
      ),
    );
  }

  Widget _buildTvLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ConnectionCard(
            icon: Icons.api_rounded,
            color: kColorPrimary,
            title: "Xtream Codes",
            subtitle: "Recommended\nBest Experience",
            onTap: () => Get.toNamed(screenRegister),
            isTv: true,
            autoFocus: true,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _ConnectionCard(
            icon: Icons.playlist_play_rounded,
            color: Colors.orange,
            title: "M3U Playlist",
            subtitle: "Classic Method\nURL Loading",
            onTap: () => Get.toNamed(screenRegisterM3u),
            isTv: true,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _ConnectionCard(
            icon: Icons.settings_ethernet_rounded,
            color: Colors.purple,
            title: "Stalker Portal",
            subtitle: "MAG Device\nEmulation",
            onTap: () => Get.toNamed(screenRegisterStalker),
            isTv: true,
          ),
        ),
      ],
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isTv;
  final bool autoFocus;

  const _ConnectionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isTv = false,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    // Modern Glassmorphism Card Style
    final cardContent = Container(
      padding: EdgeInsets.all(isTv ? 24 : 16),
      decoration: BoxDecoration(
        color: kColorCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: isTv
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.2), width: 2),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: kColorTextSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.2), width: 1),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: kColorTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white54, size: 14),
                ),
              ],
            ),
    );

    return FocusableCard(
      onTap: onTap,
      autoFocus: autoFocus,
      scale: 1.02,
      child: cardContent,
    );
  }
}
