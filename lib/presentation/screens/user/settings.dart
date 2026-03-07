part of '../screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;
  final _storage = GetStorage("settings");

  final List<String> _titles = [
    "Account",
    "Parental Control",
    "Player",
    "Speed Test",
    "About"
  ];
  final List<IconData> _icons = [
    Icons.person,
    Icons.lock,
    Icons.play_circle_filled,
    Icons.speed,
    Icons.info
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Row(
          children: [
            // Left Panel
            Expanded(
              flex: 1,
              child: Container(
                color: kColorPanel,
                child: Column(
                  children: [
                    SizedBox(height: 5.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ),
                    const Icon(Icons.settings, size: 40, color: Colors.white),
                    const SizedBox(height: 10),
                    Text("Settings", style: Get.textTheme.titleLarge),
                    const SizedBox(height: 40),
                    ...List.generate(_titles.length, (index) {
                      return _buildSettingItem(
                        icon: _icons[index],
                        title: _titles[index],
                        isSelected: _selectedIndex == index,
                        onTap: () => setState(() => _selectedIndex = index),
                      );
                    }),
                    const Spacer(),
                    _buildSettingItem(
                      icon: Icons.logout,
                      title: "Logout",
                      color: kColorError,
                      onTap: () {
                        context.read<AuthBloc>().add(AuthLogout());
                        Get.offAllNamed(screenSplash);
                      },
                    ),
                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),

            // Right Panel (Content)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: _buildRightPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    switch (_selectedIndex) {
      case 0:
        return _buildAccountSettings();
      case 1:
        return _buildParentalControlSettings();
      case 2:
        return _buildPlayerSettings();
      case 3:
        return _buildSpeedTestPreview();
      case 4:
        return _buildAboutSettings();
      default:
        // Default to About just in case, or empty
        return const SizedBox();
    }
  }

  Widget _buildAccountSettings() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          final info = state.user.userInfo!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Account Information", style: Get.textTheme.headlineMedium),
              const SizedBox(height: 20),
              _buildInfoTile("Username", info.username ?? "-"),
              _buildInfoTile("Status", info.status ?? "-"),
              _buildInfoTile(
                  "Expiry Date", formatExpiration(info.expDate ?? "Unlimited")),
              _buildInfoTile("Active Connections", info.activeCons ?? "0"),
              _buildInfoTile("Max Connections", info.maxConnections ?? "1"),
            ],
          );
        }
        return const Center(child: Text("No User Information"));
      },
    );
  }

  Widget _buildParentalControlSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Parental Control", style: Get.textTheme.headlineMedium),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: kDecorCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Protect sensitive content with a PIN code.",
                style: TextStyle(color: kColorTextSecondary, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Builder(
                builder: (context) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is! AuthSuccess) return const SizedBox();
                  final userId = authState.user.id;
                  final enabled =
                      _storage.read("parental_control_enabled_$userId") ?? true;
                  return SwitchListTile(
                    title: const Text("Enable Parental Control",
                        style: TextStyle(color: Colors.white)),
                    activeColor: kColorPrimary,
                    value: enabled,
                    onChanged: (val) {
                      if (val) {
                        // Enable directly
                        _storage.write(
                            "parental_control_enabled_$userId", true);
                        setState(() {});
                      } else {
                        // To disable, require PIN?
                        Get.dialog(
                          ParentalControlWidget(
                            userId: userId,
                            mode: ParentalMode.verify,
                            onVerifySuccess: () {
                              _storage.write(
                                  "parental_control_enabled_$userId", false);
                              setState(() {});
                            },
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                icon: const Icon(Icons.lock_reset),
                label: const Text("Change PIN",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  // Flow: Verify Old PIN first (if default 0000, maybe skip? No, always verify).
                  final authState = context.read<AuthBloc>().state;
                  if (authState is! AuthSuccess) return;
                  final userId = authState.user.id;

                  Get.dialog(
                    ParentalControlWidget(
                      userId: userId,
                      mode: ParentalMode.verify,
                      onVerifySuccess: () {
                        // Close the verify dialog is handled by widget,
                        // but we need to wait for it to close or open next one?
                        // My widget calls Get.back() on success.
                        // So we wait a bit then open the new one.
                        Future.delayed(const Duration(milliseconds: 300), () {
                          Get.dialog(
                            ParentalControlWidget(
                              userId: userId,
                              mode: ParentalMode.set,
                            ),
                          );
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSettings() {
    final format = _storage.read("stream_format") ?? "ts";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Player Settings", style: Get.textTheme.headlineMedium),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: kDecorCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Stream Format",
                  style: TextStyle(color: kColorTextSecondary, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildRadioOption("MPEG-TS (.ts)", "ts", format),
                  const SizedBox(width: 20),
                  _buildRadioOption("HLS (.m3u8)", "m3u8", format),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                  "Note: 'ts' is faster but 'm3u8' is more stable on slow connections.",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, String value, String groupValue) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () {
        _storage.write("stream_format", value);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kColorPrimary : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: isSelected ? kColorPrimary : Colors.white12),
        ),
        child: Row(
          children: [
            Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Colors.white,
                size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("About", style: Get.textTheme.headlineMedium),
        const SizedBox(height: 20),
        _buildInfoTile("App Name", kAppName),
        _buildInfoTile("Version", "1.0.0"),
        _buildInfoTile("Developer", "Dev Team"),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return FocusableCard(
      onTap: onTap,
      scale: 1.02,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        color: isSelected ? kColorPrimary.withOpacity(0.1) : null,
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? kColorPrimary : kColorTextSecondary,
                size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color == kColorError
                    ? kColorError
                    : (isSelected ? kColorPrimary : kColorTextSecondary),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: kDecorCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Get.textTheme.bodyLarge
                  ?.copyWith(color: kColorTextSecondary)),
          Text(value,
              style: Get.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSpeedTestPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.speed, size: 80, color: kColorPrimary),
        const SizedBox(height: 20),
        Text("Internet Speed Test", style: Get.textTheme.headlineMedium),
        const SizedBox(height: 10),
        const Text(
            "Check your internet connection speed to ensure smooth streaming.",
            textAlign: TextAlign.center,
            style: TextStyle(color: kColorTextSecondary)),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () {
            Get.to(const SpeedTestScreen());
          },
          child: const Text("Open Speed Test",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
