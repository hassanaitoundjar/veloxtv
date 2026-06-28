part of '../screens.dart';

class DeviceSelectionScreen extends StatefulWidget {
  const DeviceSelectionScreen({super.key});

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  late String _selected = _detectDeviceType();

  String _detectDeviceType() {
    final size = MediaQuery.of(context).size;
    final isLikelyTv = size.shortestSide >= 600 && size.width > size.height;
    return isLikelyTv ? "tv" : "mobile";
  }

  void _selectDevice(BuildContext context, String type) {
    final storage = GetStorage();
    storage.write(kPrefDeviceType, type);
    Get.offNamed(screenIntro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: kDecorBackground,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 650;
              final isTallEnough = constraints.maxHeight >= 600;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 800 : 450),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header Section
                        Image.asset(
                          kIconSplash,
                          width: isWide ? 90 : 70,
                          height: isWide ? 90 : 70,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Choose Your Experience",
                          style: Get.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "We've optimized the interface for your device type.\nPlease confirm your selection for the best performance.",
                          style: Get.textTheme.bodyLarge?.copyWith(
                            color: kColorTextSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isWide ? 48 : 32),

                        // Options Section
                        if (isWide)
                          Row(
                            children: [
                              Expanded(
                                child: _buildPremiumCard(
                                  id: "mobile",
                                  title: "Mobile / Tablet",
                                  subtitle: "Touch-optimized interface",
                                  icon: Icons.smartphone_rounded,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildPremiumCard(
                                  id: "tv",
                                  title: "Smart TV",
                                  subtitle: "Remote-optimized interface",
                                  icon: Icons.tv_rounded,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildPremiumCard(
                                id: "mobile",
                                title: "Mobile / Tablet",
                                subtitle: "Touch-optimized interface",
                                icon: Icons.smartphone_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildPremiumCard(
                                id: "tv",
                                title: "Smart TV",
                                subtitle: "Remote-optimized interface",
                                icon: Icons.tv_rounded,
                              ),
                            ],
                          ),

                        SizedBox(height: isWide ? 48 : 36),

                        // Save Button
                        FocusableCard(
                          onTap: () => _selectDevice(context, _selected),
                          autoFocus: true,
                          scale: 1.03,
                          child: Container(
                            width: isWide ? 300 : double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  kColorPrimary,
                                  kColorPrimary.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: kColorPrimary.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  "SAVE SELECTION",
                                  style: Get.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
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
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selected == id;
    
    return FocusableCard(
      onTap: () => setState(() => _selected = id),
      scale: 1.02,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected 
              ? kColorPrimary.withValues(alpha: 0.15) 
              : kColorCardLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kColorPrimary : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kColorPrimary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? kColorPrimary : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : kColorTextSecondary,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white70 : kColorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Custom Radio Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kColorPrimary : Colors.white38,
                  width: 2,
                ),
                color: isSelected ? kColorPrimary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}