part of '../screens.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Device.screenType == ScreenType.mobile;

    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Column(
          children: [
            // Top hero section
            Expanded(
              flex: isMobile ? 2 : 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(kImageIntro),
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        kColorBackground,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom content — connection methods
            Expanded(
              flex: isMobile ? 6 : 3,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20.0 : 5.w,
                  vertical: isMobile ? 8.0 : 16.0,
                ),
                child: Column(
                  children: [
                    Text(
                      "Choose Connection Type",
                      textAlign: TextAlign.center,
                      style: Get.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Select how you want to connect to your IPTV service",
                      textAlign: TextAlign.center,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: kColorTextSecondary,
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Connection method cards
                    Expanded(
                      child: isMobile ? _buildMobileLayout() : _buildTvLayout(),
                    ),
                    SizedBox(height: isMobile ? 8 : 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ConnectionCard(
            icon: Icons.api,
            color: kColorPrimary,
            title: "Xtream Codes API",
            subtitle: "Username, Password & Server URL",
            onTap: () => Get.toNamed(screenRegister),
          ),
          const SizedBox(height: 12),
          _ConnectionCard(
            icon: Icons.playlist_play,
            color: Colors.orange,
            title: "M3U Playlist",
            subtitle: "Load channels from an M3U URL",
            onTap: () => Get.toNamed(screenRegisterM3u),
          ),
          const SizedBox(height: 12),
          _ConnectionCard(
            icon: Icons.router,
            color: Colors.purple,
            title: "Stalker Portal",
            subtitle: "MAC address based portal login",
            onTap: () => Get.toNamed(screenRegisterStalker),
          ),
        ],
      ),
    );
  }

  Widget _buildTvLayout() {
    return Row(
      children: [
        Expanded(
          child: _ConnectionCard(
            icon: Icons.api,
            color: kColorPrimary,
            title: "Xtream Codes API",
            subtitle: "Username, Password\n& Server URL",
            onTap: () => Get.toNamed(screenRegister),
            isTv: true,
            autoFocus: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ConnectionCard(
            icon: Icons.playlist_play,
            color: Colors.orange,
            title: "M3U Playlist",
            subtitle: "Load channels from\nan M3U URL",
            onTap: () => Get.toNamed(screenRegisterM3u),
            isTv: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ConnectionCard(
            icon: Icons.router,
            color: Colors.purple,
            title: "Stalker Portal",
            subtitle: "MAC address based\nportal login",
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
    final cardContent = Container(
      padding: EdgeInsets.all(isTv ? 24 : 16),
      decoration: BoxDecoration(
        color: kColorCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: isTv
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: kColorTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: kColorTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: kColorTextSecondary, size: 16),
              ],
            ),
    );

    // Use FocusableCard for TV remote D-Pad navigation
    return FocusableCard(
      onTap: onTap,
      autoFocus: autoFocus,
      scale: 1.03,
      child: cardContent,
    );
  }
}
