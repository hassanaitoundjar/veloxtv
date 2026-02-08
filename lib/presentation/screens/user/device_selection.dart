part of '../screens.dart';

class DeviceSelectionScreen extends StatelessWidget {
  const DeviceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(kIconSplash, width: 15.w, height: 15.w),
              SizedBox(height: 5.h),
              Text(
                "Choose Your Experience",
                style: Get.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                "Select the device type to optimize your experience",
                style: Get.textTheme.bodyLarge
                    ?.copyWith(color: kColorTextSecondary),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DeviceOption(
                    icon: Icons.smartphone,
                    title: "Mobile / Tablet",
                    subtitle: "Touch Optimized",
                    onTap: () => _selectDevice(context, "mobile"),
                  ),
                  SizedBox(width: 5.w),
                  _DeviceOption(
                    icon: Icons.tv,
                    title: "TV",
                    subtitle: "Remote Optimized",
                    onTap: () => _selectDevice(context, "tv"),
                    autoFocus: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDevice(BuildContext context, String type) {
    final storage = GetStorage();
    storage.write(kPrefDeviceType, type);

    // Proceed based on auth state or just go to Intro
    // For now, let's go to Intro as per flow, or straight to Login if preferred.
    // The original flow went Splash -> Intro -> Login
    Get.offNamed(screenIntro);
  }
}

class _DeviceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool autoFocus;

  const _DeviceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onTap: onTap,
      autoFocus: autoFocus,
      scale: 1.1,
      child: Container(
        width: 25.w,
        height: 35.h,
        padding: const EdgeInsets.all(24),
        decoration: kDecorCard.copyWith(
          color: kColorCardLight.withOpacity(0.5),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 8.w, color: kColorPrimary),
            const Spacer(),
            Text(title,
                style: Get.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium
                  ?.copyWith(color: kColorTextSecondary),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
