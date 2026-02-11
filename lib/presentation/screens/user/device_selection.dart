part of '../screens.dart';

class DeviceSelectionScreen extends StatelessWidget {
  const DeviceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect orientation or screen width
    final isPortrait = MediaQuery.of(context).size.width < 600 ||
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(kIconSplash, width: 15.w, height: 15.w),
                SizedBox(height: 5.h),
                Text(
                  "Choose Your Experience",
                  style: Get.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Select the device type to optimize your experience",
                    style: Get.textTheme.bodyLarge
                        ?.copyWith(color: kColorTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8.h),
                if (isPortrait)
                  Column(
                    children: [
                      _DeviceOption(
                        icon: Icons.smartphone,
                        title: "Mobile / Tablet",
                        subtitle: "Touch Optimized",
                        onTap: () => _selectDevice(context, "mobile"),
                        width: 85.w,
                        height: 20.h,
                        isHorizontal: true,
                      ),
                      SizedBox(height: 3.h),
                      _DeviceOption(
                        icon: Icons.tv,
                        title: "TV",
                        subtitle: "Remote Optimized",
                        onTap: () => _selectDevice(context, "tv"),
                        width: 85.w,
                        height: 20.h,
                        isHorizontal: true,
                      ),
                    ],
                  )
                else
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
      ),
    );
  }

  void _selectDevice(BuildContext context, String type) {
    final storage = GetStorage();
    storage.write(kPrefDeviceType, type);
    Get.offNamed(screenIntro);
  }
}

class _DeviceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool autoFocus;
  final double? width;
  final double? height;
  final bool isHorizontal;

  const _DeviceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.autoFocus = false,
    this.width,
    this.height,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onTap: onTap,
      autoFocus: autoFocus,
      scale: 1.05,
      child: Container(
        width: width ?? 25.w,
        height: height ?? 35.h,
        padding: const EdgeInsets.all(24),
        decoration: kDecorCard.copyWith(
          color: kColorCardLight.withOpacity(0.5),
          border: Border.all(color: Colors.white10),
        ),
        child: isHorizontal
            ? Row(
                children: [
                  Icon(icon, size: 8.w, color: kColorPrimary),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: Get.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: Get.textTheme.bodyMedium
                              ?.copyWith(color: kColorTextSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white54, size: 20),
                ],
              )
            : Column(
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
