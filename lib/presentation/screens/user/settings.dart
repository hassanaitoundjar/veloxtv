part of '../screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;
  bool _showMobileDetails = false;
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
    final isLandscape =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    final isTvDevice = isTv(context);
    final isTvLayout = isLandscape || isTvDevice;

    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: isTvLayout ? _buildTvLayout() : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildTvLayout() {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final padding = isPhone ? 16.0 : 40.0;
    final iconSize = isPhone ? 28.0 : 40.0;
    final topMargin = isPhone ? 2.h : 5.h;

    return Row(
      children: [
        // Left Panel
        Expanded(
          flex: isPhone ? 2 : 1,
          child: Container(
            color: kColorPanel,
            child: Column(
              children: [
                SizedBox(height: topMargin),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
                Icon(Icons.settings, size: iconSize, color: Colors.white),
                const SizedBox(height: 10),
                Text("Settings",
                    style: isPhone
                        ? Get.textTheme.titleMedium
                        : Get.textTheme.titleLarge),
                SizedBox(height: isPhone ? 20 : 40),
                Expanded(
                  child: ListView.builder(
                    itemCount: _titles.length,
                    itemBuilder: (context, index) {
                      return _buildSettingItem(
                        icon: _icons[index],
                        title: _titles[index],
                        isSelected: _selectedIndex == index,
                        onTap: () => setState(() => _selectedIndex = index),
                        isPhone: isPhone,
                      );
                    },
                  ),
                ),
                _buildSettingItem(
                  icon: Icons.logout,
                  title: "Logout",
                  color: kColorError,
                  onTap: () {
                    context.read<AuthBloc>().add(AuthLogout());
                    Get.offAllNamed(screenSplash);
                  },
                  isPhone: isPhone,
                ),
                SizedBox(height: topMargin),
              ],
            ),
          ),
        ),

        // Right Panel (Content)
        Expanded(
          flex: isPhone ? 3 : 2,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: SingleChildScrollView(child: _buildRightPanel(isPhone)),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    if (_showMobileDetails) {
      return SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => setState(() => _showMobileDetails = false),
                  ),
                  const SizedBox(width: 8),
                  Text(_titles[_selectedIndex],
                      style: Get.textTheme.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildRightPanel(),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 8),
                Text("Settings", style: Get.textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _titles.length + 1,
              itemBuilder: (context, index) {
                if (index == _titles.length) {
                  return _buildSettingItem(
                    icon: Icons.logout,
                    title: "Logout",
                    color: kColorError,
                    onTap: () {
                      context.read<AuthBloc>().add(AuthLogout());
                      Get.offAllNamed(screenSplash);
                    },
                  );
                }
                return _buildSettingItem(
                  icon: _icons[index],
                  title: _titles[index],
                  isSelected: false,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                      _showMobileDetails = true;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel([bool isPhone = false]) {
    switch (_selectedIndex) {
      case 0:
        return _buildAccountSettings(isPhone);
      case 1:
        return _buildParentalControlSettings(isPhone);
      case 2:
        return _buildPlayerSettings(isPhone);
      case 3:
        return _buildDateTimeSettings(isPhone);
      case 4:
        return _buildSpeedTestPreview(isPhone);
      case 5:
        return _buildAboutSettings(isPhone);
      default:
        // Default to About just in case, or empty
        return const SizedBox();
    }
  }

  Widget _buildAccountSettings(bool isPhone) {
    final titleStyle =
        isPhone ? Get.textTheme.titleLarge : Get.textTheme.headlineMedium;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          final info = state.user.userInfo!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Account Information", style: titleStyle),
              SizedBox(height: isPhone ? 10 : 20),
              _buildInfoTile("Username", info.username ?? "-",
                  isPhone: isPhone),
              _buildInfoTile("Status", info.status ?? "-", isPhone: isPhone),
              _buildInfoTile(
                  "Expiry Date", formatExpiration(info.expDate ?? "Unlimited"),
                  isPhone: isPhone),
              _buildInfoTile("Active Connections", info.activeCons ?? "0",
                  isPhone: isPhone),
              _buildInfoTile("Max Connections", info.maxConnections ?? "1",
                  isPhone: isPhone),
            ],
          );
        }
        return const Center(child: Text("No User Information"));
      },
    );
  }

  Widget _buildParentalControlSettings(bool isPhone) {
    final titleStyle =
        isPhone ? Get.textTheme.titleLarge : Get.textTheme.headlineMedium;
    final padding = isPhone ? 16.0 : 24.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Parental Control", style: titleStyle),
        SizedBox(height: isPhone ? 10 : 20),
        Container(
          padding: EdgeInsets.all(padding),
          decoration: kDecorCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Protect sensitive content with a PIN code.",
                style: TextStyle(
                    color: kColorTextSecondary, fontSize: isPhone ? 14 : 16),
              ),
              SizedBox(height: isPhone ? 16 : 24),
              Builder(
                builder: (context) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is! AuthSuccess) return const SizedBox();
                  final userId = authState.user.id;
                  final enabled =
                      _storage.read("parental_control_enabled_$userId") ?? true;
                  void toggleParentalControl(bool val) {
                    if (val) {
                      _storage.write("parental_control_enabled_$userId", true);
                      setState(() {});
                    } else {
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
                  }

                  return FocusableCard(
                    onTap: () => toggleParentalControl(!enabled),
                    child: SwitchListTile(
                      title: const Text("Enable Parental Control",
                          style: TextStyle(color: Colors.white)),
                      activeColor: kColorPrimary,
                      value: enabled,
                      onChanged: toggleParentalControl,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Builder(builder: (context) {
                void changePin() {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is! AuthSuccess) return;
                  final userId = authState.user.id;

                  Get.dialog(
                    ParentalControlWidget(
                      userId: userId,
                      mode: ParentalMode.verify,
                      onVerifySuccess: () {
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
                }

                return FocusableCard(
                  onTap: changePin,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kColorPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    icon: const Icon(Icons.lock_reset),
                    label: const Text("Change PIN",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: changePin,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSettings(bool isPhone) {
    final format = _storage.read("stream_format") ?? "default";
    final titleStyle =
        isPhone ? Get.textTheme.titleLarge : Get.textTheme.headlineMedium;
    final padding = isPhone ? 16.0 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Player Settings", style: titleStyle),
        SizedBox(height: isPhone ? 10 : 20),
        Container(
          padding: EdgeInsets.all(padding),
          decoration: kDecorCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Stream Format",
                  style: TextStyle(
                      color: kColorTextSecondary, fontSize: isPhone ? 14 : 16)),
              SizedBox(height: isPhone ? 10 : 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildRadioOption("Default (Auto)", "default", format,
                      isPhone: isPhone),
                  _buildRadioOption("MPEG-TS (.ts)", "ts", format,
                      isPhone: isPhone),
                  _buildRadioOption("HLS (.m3u8)", "m3u8", format,
                      isPhone: isPhone),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                  "Default works best for most servers. Use 'ts' for speed or 'm3u8' for stability.",
                  style: TextStyle(
                      color: Colors.white38, fontSize: isPhone ? 10 : 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, String value, String groupValue,
      {bool isPhone = false}) {
    final isSelected = value == groupValue;
    return FocusableCard(
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

  Widget _buildEnumRadioOption<T extends Enum>(
    String label,
    T value,
    T groupValue,
    Future<void> Function(T) onSelected, {
    bool isPhone = false,
  }) {
    final isSelected = value.name == groupValue.name;
    return FocusableCard(
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

  Widget _buildAboutSettings(bool isPhone) {
    final titleStyle =
        isPhone ? Get.textTheme.titleLarge : Get.textTheme.headlineMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("About", style: titleStyle),
        SizedBox(height: isPhone ? 10 : 20),
        _buildInfoTile("App Name", kAppName, isPhone: isPhone),
        _buildInfoTile("Version", "1.0.0", isPhone: isPhone),
        _buildInfoTile("Developer", "Dev Team", isPhone: isPhone),
      ],
    );
  }

  Widget _buildDateTimeSettings(bool isPhone) {
    final timeFormat = DateTimeFormatService.getTimeFormat();
    final dateFormat = DateTimeFormatService.getDateFormat();
    final tzMode = DateTimeFormatService.getTimezoneMode();
    final activeTz = DateTimeFormatService.getActiveTimezone();
    final manualTzId = _storage.read(DateTimeFormatService.getManualTzKey());

    // Sample DateTime used to preview formatting choices.
    final sample = DateTime.now();

    final titleStyle =
        isPhone ? Get.textTheme.titleLarge : Get.textTheme.headlineMedium;
    final padding = isPhone ? 16.0 : 24.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Date & Time", style: titleStyle),
          const SizedBox(height: 8),
          Text(
            "Configure how dates and times are displayed across the app, "
            "and pick the timezone used for the TV guide.",
            style:
                Get.textTheme.bodyMedium?.copyWith(color: kColorTextSecondary),
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
                    style: TextStyle(color: kColorTextSecondary, fontSize: 16)),
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
                    style: TextStyle(color: kColorTextSecondary, fontSize: 16)),
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
                    style: TextStyle(color: kColorTextSecondary, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  "Active: ${activeTz.label} (${activeTz.offsetLabel})",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (tzMode == TimezoneMode.auto)
                  Text(
                    "Detected from device: "
                    "${DateTimeFormatService.detectDeviceTimezone().label}",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildEnumRadioOption<TimezoneMode>(
                        "Auto-detect", TimezoneMode.auto, tzMode, (v) async {
                      await DateTimeFormatService.setTimezoneMode(v);
                      setState(() {});
                    }),
                    const SizedBox(width: 20),
                    _buildEnumRadioOption<TimezoneMode>(
                        "Manual", TimezoneMode.manual, tzMode, (v) async {
                      await DateTimeFormatService.setTimezoneMode(v);
                      setState(() {});
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Builder(builder: (context) {
                        Future<void> detectCountry() async {
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(const SnackBar(
                              content:
                                  Text("Detecting country, please wait...")));
                          final tz = await DateTimeFormatService
                              .detectTimezoneByCountry();
                          await DateTimeFormatService.setTimezoneMode(
                              TimezoneMode.manual);
                          await DateTimeFormatService.setManualTimezone(tz.id);
                          if (mounted) {
                            setState(() {});
                            messenger.showSnackBar(SnackBar(
                                content: Text(
                                    "Detected timezone: ${tz.label} (${tz.country})")));
                          }
                        }

                        return FocusableCard(
                          onTap: detectCountry,
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
                            onPressed: detectCountry,
                          ),
                        );
                      }),
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
    final selectedId =
        currentId ?? DateTimeFormatService.getActiveTimezone().id;
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
                  child:
                      Text("${tz.label} (${tz.country}) - ${tz.offsetLabel}"),
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
    bool isPhone = false,
  }) {
    return FocusableCard(
      onTap: onTap,
      scale: 1.02,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: isPhone ? 14 : 20, horizontal: isPhone ? 16 : 24),
        color: isSelected ? kColorPrimary.withOpacity(0.1) : null,
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? kColorPrimary : kColorTextSecondary,
                size: isPhone ? 20 : 24),
            SizedBox(width: isPhone ? 12 : 16),
            Text(
              title,
              style: TextStyle(
                color: color == kColorError
                    ? kColorError
                    : (isSelected ? kColorPrimary : kColorTextSecondary),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isPhone ? 14 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {bool isPhone = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isPhone ? 10 : 16),
      padding: EdgeInsets.all(isPhone ? 14 : 20),
      decoration: kDecorCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  (isPhone ? Get.textTheme.bodyMedium : Get.textTheme.bodyLarge)
                      ?.copyWith(color: kColorTextSecondary)),
          Text(value,
              style: (isPhone
                      ? Get.textTheme.titleSmall
                      : Get.textTheme.titleMedium)
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSpeedTestPreview(bool isPhone) {
    final titleStyle =
        isPhone ? Get.textTheme.titleLarge : Get.textTheme.headlineMedium;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.speed, size: isPhone ? 60 : 80, color: kColorPrimary),
        SizedBox(height: isPhone ? 12 : 20),
        Text("Internet Speed Test", style: titleStyle),
        SizedBox(height: isPhone ? 6 : 10),
        Text("Check your internet connection speed to ensure smooth streaming.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: kColorTextSecondary, fontSize: isPhone ? 12 : 14)),
        SizedBox(height: isPhone ? 20 : 30),
        FocusableCard(
          onTap: () {
            Get.to(() => const SpeedTestScreen());
          },
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kColorPrimary,
              padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 24 : 32, vertical: isPhone ? 12 : 16),
            ),
            icon: Icon(Icons.play_arrow, size: isPhone ? 20 : 24),
            label: Text("Start Test",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isPhone ? 14 : 16)),
            onPressed: () {
              Get.to(() => const SpeedTestScreen());
            },
          ),
        ),
      ],
    );
  }
}
