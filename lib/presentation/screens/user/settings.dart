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
    "Date & Time",
    "Speed Test",
    "About"
  ];
  final List<IconData> _icons = [
    Icons.person,
    Icons.lock,
    Icons.play_circle_filled,
    Icons.access_time,
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
        return _buildDateTimeSettings();
      case 4:
        return _buildSpeedTestPreview();
      case 5:
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

  /// Generic radio option for any enum [T] keyed by [T.name].
  Widget _buildEnumRadioOption<T extends Enum>(
    String label,
    T value,
    T groupValue,
    Future<void> Function(T) onSelected,
  ) {
    final isSelected = value.name == groupValue.name;
    return InkWell(
      onTap: () async {
        await onSelected(value);
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
          mainAxisSize: MainAxisSize.min,
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

  Widget _buildDateTimeSettings() {
    final timeFormat = DateTimeFormatService.getTimeFormat();
    final dateFormat = DateTimeFormatService.getDateFormat();
    final tzMode = DateTimeFormatService.getTimezoneMode();
    final activeTz = DateTimeFormatService.getActiveTimezone();
    final manualTzId = _storage.read(DateTimeFormatService.getManualTzKey());

    // Sample DateTime used to preview formatting choices.
    final sample = DateTime.now();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Date & Time", style: Get.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            "Configure how dates and times are displayed across the app, "
            "and pick the timezone used for the TV guide.",
            style: Get.textTheme.bodyMedium
                ?.copyWith(color: kColorTextSecondary),
          ),
          const SizedBox(height: 20),

          // ----- Time format -----
          Container(
            padding: const EdgeInsets.all(24),
            decoration: kDecorCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Time Format",
                    style:
                        TextStyle(color: kColorTextSecondary, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  "Preview: ${DateTimeFormatService.formatTime(sample)}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildEnumRadioOption<TimeFormatOption>(
                        "24-hour (21:30)", TimeFormatOption.h24, timeFormat,
                        (v) async {
                      await DateTimeFormatService.setTimeFormat(v);
                      setState(() {});
                    }),
                    const SizedBox(width: 20),
                    _buildEnumRadioOption<TimeFormatOption>(
                        "12-hour (09:30 PM)", TimeFormatOption.h12, timeFormat,
                        (v) async {
                      await DateTimeFormatService.setTimeFormat(v);
                      setState(() {});
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ----- Date format -----
          Container(
            padding: const EdgeInsets.all(24),
            decoration: kDecorCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Date Format",
                    style:
                        TextStyle(color: kColorTextSecondary, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  "Preview: ${DateTimeFormatService.formatDate(sample)}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildEnumRadioOption<DateFormatOption>(
                        "Jun 6, 2026", DateFormatOption.mmmDY, dateFormat,
                        (v) async {
                      await DateTimeFormatService.setDateFormat(v);
                      setState(() {});
                    }),
                    _buildEnumRadioOption<DateFormatOption>(
                        "06/06/2026", DateFormatOption.ddmmyyyy, dateFormat,
                        (v) async {
                      await DateTimeFormatService.setDateFormat(v);
                      setState(() {});
                    }),
                    _buildEnumRadioOption<DateFormatOption>(
                        "2026-06-06", DateFormatOption.yyyymmdd, dateFormat,
                        (v) async {
                      await DateTimeFormatService.setDateFormat(v);
                      setState(() {});
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ----- Timezone -----
          Container(
            padding: const EdgeInsets.all(24),
            decoration: kDecorCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Timezone",
                    style:
                        TextStyle(color: kColorTextSecondary, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  "Active: ${activeTz.label} (${activeTz.offsetLabel})",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (tzMode == TimezoneMode.auto)
                  Text(
                    "Detected from device: "
                    "${DateTimeFormatService.detectDeviceTimezone().label}",
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildEnumRadioOption<TimezoneMode>(
                        "Auto-detect", TimezoneMode.auto, tzMode,
                        (v) async {
                      await DateTimeFormatService.setTimezoneMode(v);
                      setState(() {});
                    }),
                    const SizedBox(width: 20),
                    _buildEnumRadioOption<TimezoneMode>(
                        "Manual", TimezoneMode.manual, tzMode,
                        (v) async {
                      await DateTimeFormatService.setTimezoneMode(v);
                      setState(() {});
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kColorCardLight,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        icon: const Icon(Icons.public,
                            color: kColorPrimary, size: 18),
                        label: const Text("Auto-detect by country",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(const SnackBar(
                              content: Text(
                                  "Detecting country, please wait...")));
                          final tz = await DateTimeFormatService
                              .detectTimezoneByCountry();
                          await DateTimeFormatService.setTimezoneMode(
                              TimezoneMode.manual);
                          await DateTimeFormatService
                              .setManualTimezone(tz.id);
                          if (mounted) {
                            setState(() {});
                            messenger.showSnackBar(SnackBar(
                                content: Text(
                                    "Detected timezone: ${tz.label} (${tz.country})")));
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (tzMode == TimezoneMode.manual) ...[
                  const SizedBox(height: 20),
                  _buildTimezoneDropdown(manualTzId),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimezoneDropdown(String? currentId) {
    final selectedId = currentId ??
        DateTimeFormatService.getActiveTimezone().id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Timezone",
            style: TextStyle(color: kColorTextSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: kColorCardLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: kColorCard,
              value: kTimezones.any((t) => t.id == selectedId)
                  ? selectedId
                  : kTimezones.first.id,
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              items: kTimezones.map((tz) {
                return DropdownMenuItem<String>(
                  value: tz.id,
                  child: Text(
                      "${tz.label} (${tz.country}) - ${tz.offsetLabel}"),
                );
              }).toList(),
              onChanged: (val) async {
                if (val == null) return;
                await DateTimeFormatService.setManualTimezone(val);
                setState(() {});
              },
            ),
          ),
        ),
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
