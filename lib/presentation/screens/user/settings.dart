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

  bool _autoStartEnabled = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoStartEnabled = _prefs?.getBool("auto_start_enabled") ?? false;
    });
  }

  final List<String> _titles = [
    "Account",
    "Parental Control",
    "Player",
    "Date & Time",
    "Speed Test",
    "About"
  ];
  final List<String> _subtitles = [
    "Subscription & connection info",
    "PIN protection for sensitive content",
    "Stream format & playback",
    "Clock, timezone & formats",
    "Test your connection speed",
    "App version & info"
  ];
  final List<IconData> _icons = [
    Icons.person_rounded,
    Icons.shield_rounded,
    Icons.play_circle_fill_rounded,
    Icons.access_time_filled_rounded,
    Icons.speed_rounded,
    Icons.info_rounded
  ];

  // ---- Responsive breakpoints ----
  static const double _kPhoneMax = 600;
  static const double _kTabletMax = 1024;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isTvDevice = isTv(context);
    final isTvLayout = isLandscape || isTvDevice;

    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: isTvLayout ? _buildTvLayout(size) : _buildMobileLayout(),
      ),
    );
  }

  // ============================================================
  // TV / TABLET / LANDSCAPE LAYOUT
  // ============================================================
  Widget _buildTvLayout(Size size) {
    final isPhone = size.shortestSide < _kPhoneMax;
    final isTablet = !isPhone && size.shortestSide < _kTabletMax;

    final sidebarWidth = isPhone
        ? size.width * 0.34
        : isTablet
            ? 280.0
            : 320.0;

    final padding = isPhone ? 16.0 : (isTablet ? 28.0 : 40.0);
    final iconSize = isPhone ? 26.0 : (isTablet ? 32.0 : 36.0);
    final topMargin = isPhone ? 12.0 : 28.0;

    return Row(
      children: [
        // ---------------- Sidebar ----------------
        Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            color: kColorPanel,
            border: Border(
              right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: topMargin),
              // Header: back + brand
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isPhone ? 12.0 : 20.0),
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Get.back(),
                      size: isPhone ? 36 : 42,
                    ),
                    SizedBox(width: isPhone ? 10 : 14),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kColorPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.settings_rounded,
                          size: iconSize * 0.6, color: kColorPrimary),
                    ),
                    SizedBox(width: isPhone ? 8 : 12),
                    Expanded(
                      child: Text(
                        "Settings",
                        style: (isPhone
                                ? Get.textTheme.titleMedium
                                : Get.textTheme.titleLarge)
                            ?.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isPhone ? 18 : 32),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06),
                  height: 1,
                  indent: isPhone ? 12 : 20,
                  endIndent: isPhone ? 12 : 20),
              SizedBox(height: isPhone ? 10 : 16),

              // Nav list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: isPhone ? 10 : 16, vertical: 4),
                  itemCount: _titles.length,
                  itemBuilder: (context, index) {
                    return _buildNavItem(
                      icon: _icons[index],
                      title: _titles[index],
                      subtitle: _subtitles[index],
                      isSelected: _selectedIndex == index,
                      onTap: () => setState(() => _selectedIndex = index),
                      isPhone: isPhone,
                      showSubtitle: !isPhone,
                    );
                  },
                ),
              ),

              Divider(
                  color: Colors.white.withValues(alpha: 0.06),
                  height: 1,
                  indent: isPhone ? 12 : 20,
                  endIndent: isPhone ? 12 : 20),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 10 : 16, vertical: isPhone ? 8 : 14),
                child: _buildNavItem(
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  isDestructive: true,
                  onTap: () {
                    context.read<AuthBloc>().add(AuthLogout());
                    Get.offAllNamed(screenSplash);
                  },
                  isPhone: isPhone,
                ),
              ),
              SizedBox(height: topMargin * 0.5),
            ],
          ),
        ),

        // ---------------- Content ----------------
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: _buildRightPanel(isPhone),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE / PORTRAIT LAYOUT
  // ============================================================
  Widget _buildMobileLayout() {
    if (_showMobileDetails) {
      return SafeArea(
        child: Column(
          children: [
            _buildMobileAppBar(
              title: _titles[_selectedIndex],
              onBack: () => setState(() => _showMobileDetails = false),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: _buildRightPanel(true),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          _buildMobileAppBar(title: "Settings", onBack: () => Get.back()),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _titles.length + 1,
              itemBuilder: (context, index) {
                if (index == _titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildNavItem(
                      icon: Icons.logout_rounded,
                      title: "Logout",
                      isDestructive: true,
                      isCard: true,
                      onTap: () {
                        context.read<AuthBloc>().add(AuthLogout());
                        Get.offAllNamed(screenSplash);
                      },
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildNavItem(
                    icon: _icons[index],
                    title: _titles[index],
                    subtitle: _subtitles[index],
                    isCard: true,
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.3)),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                        _showMobileDetails = true;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAppBar(
      {required String title, required VoidCallback onBack}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const SizedBox(width: 10),
          Text(title,
              style: Get.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ============================================================
  // Shared nav item (used by sidebar AND mobile list)
  // ============================================================
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isSelected = false,
    bool isDestructive = false,
    bool isCard = false,
    bool showSubtitle = true,
    Widget? trailing,
    bool isPhone = false,
    required VoidCallback onTap,
  }) {
    final Color fg = isDestructive
        ? kColorError
        : (isSelected ? kColorPrimary : Colors.white);
    final Color iconBg = isDestructive
        ? kColorError.withValues(alpha: 0.12)
        : (isSelected
            ? kColorPrimary.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.06));

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.symmetric(
          horizontal: isPhone ? 14 : 16, vertical: isPhone ? 12 : 14),
      decoration: BoxDecoration(
        color: isCard
            ? kColorCard
            : (isSelected
                ? kColorPrimary.withValues(alpha: 0.10)
                : Colors.transparent),
        borderRadius: BorderRadius.circular(14),
        border: isSelected && !isCard
            ? Border(
                left: BorderSide(color: kColorPrimary, width: 3),
              )
            : (isCard
                ? Border.all(color: Colors.white.withValues(alpha: 0.05))
                : null),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: isPhone ? 18 : 20, color: fg),
          ),
          SizedBox(width: isPhone ? 12 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: fg,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: isPhone ? 14 : 15,
                  ),
                ),
                if (subtitle != null && showSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: isPhone ? 11 : 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );

    return FocusableCard(onTap: onTap, scale: 1.02, child: content);
  }

  // ============================================================
  // Right panel router
  // ============================================================
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
        return const SizedBox();
    }
  }

  // ---- Section header helper ----
  Widget _sectionHeader(String title, IconData icon, bool isPhone,
      {String? caption}) {
    final titleStyle =
        isPhone ? Get.textTheme.titleLarge : Get.textTheme.headlineMedium;
    return Padding(
      padding: EdgeInsets.only(bottom: isPhone ? 14 : 22),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kColorPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kColorPrimary, size: isPhone ? 20 : 24),
          ),
          SizedBox(width: isPhone ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: titleStyle?.copyWith(fontWeight: FontWeight.w700)),
                if (caption != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(caption,
                        style: TextStyle(
                            color: kColorTextSecondary,
                            fontSize: isPhone ? 12 : 13)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, required double padding}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: kColorCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: child,
    );
  }

  // ============================================================
  // ACCOUNT
  // ============================================================
  Widget _buildAccountSettings(bool isPhone) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          final info = state.user.userInfo!;
          final isActive = (info.status ?? "").toLowerCase() == "active";
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader("Account", Icons.person_rounded, isPhone,
                  caption: "Subscription & connection details"),
              _card(
                padding: isPhone ? 16 : 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: isPhone ? 24 : 30,
                          backgroundColor:
                              kColorPrimary.withValues(alpha: 0.16),
                          child: Icon(Icons.person_rounded,
                              color: kColorPrimary, size: isPhone ? 26 : 32),
                        ),
                        SizedBox(width: isPhone ? 14 : 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(info.username ?? "-",
                                  style: (isPhone
                                          ? Get.textTheme.titleMedium
                                          : Get.textTheme.titleLarge)
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              _StatusPill(
                                  label: info.status ?? "-", active: isActive),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isPhone ? 16 : 22),
                    Divider(color: Colors.white.withValues(alpha: 0.06)),
                    SizedBox(height: isPhone ? 12 : 16),
                    _buildInfoRow("Expiry Date",
                        formatExpiration(info.expDate ?? "Unlimited"),
                        icon: Icons.event_rounded, isPhone: isPhone),
                    _buildInfoRow("Active Connections", info.activeCons ?? "0",
                        icon: Icons.wifi_tethering_rounded, isPhone: isPhone),
                    _buildInfoRow("Max Connections", info.maxConnections ?? "1",
                        icon: Icons.devices_rounded,
                        isPhone: isPhone,
                        isLast: true),
                  ],
                ),
              ),
            ],
          );
        }
        return const Center(child: Text("No User Information"));
      },
    );
  }

  Widget _buildInfoRow(String label, String value,
      {required IconData icon, bool isPhone = false, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : (isPhone ? 12 : 16)),
      child: Row(
        children: [
          Icon(icon, size: isPhone ? 16 : 18, color: kColorTextSecondary),
          SizedBox(width: isPhone ? 10 : 12),
          Expanded(
            child: Text(label,
                style: (isPhone
                        ? Get.textTheme.bodyMedium
                        : Get.textTheme.bodyLarge)
                    ?.copyWith(color: kColorTextSecondary)),
          ),
          Text(value,
              style: (isPhone
                      ? Get.textTheme.titleSmall
                      : Get.textTheme.titleMedium)
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ============================================================
  // PARENTAL CONTROL
  // ============================================================
  Widget _buildParentalControlSettings(bool isPhone) {
    final padding = isPhone ? 16.0 : 24.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Parental Control", Icons.shield_rounded, isPhone,
            caption: "Protect sensitive content with a PIN code"),
        _card(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isPhone ? 14 : 18,
                          vertical: isPhone ? 6 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Enable Parental Control",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: isPhone ? 14 : 15,
                                fontWeight: FontWeight.w600)),
                        subtitle: Text("Locks restricted categories",
                            style: TextStyle(
                                color: kColorTextSecondary,
                                fontSize: isPhone ? 11 : 12)),
                        activeThumbColor: kColorPrimary,
                        value: enabled,
                        onChanged: toggleParentalControl,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: isPhone ? 14 : 18),
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: isPhone ? 14 : 16),
                      ),
                      icon: const Icon(Icons.lock_reset_rounded),
                      label: const Text("Change PIN",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: changePin,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PLAYER
  // ============================================================
  Widget _buildPlayerSettings(bool isPhone) {
    final format = _storage.read("stream_format") ?? "default";
    final padding = isPhone ? 16.0 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Player", Icons.play_circle_fill_rounded, isPhone,
            caption: "Choose how streams are delivered"),
        _card(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Stream Format",
                  style: TextStyle(
                      color: kColorTextSecondary,
                      fontSize: isPhone ? 14 : 16,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: isPhone ? 12 : 16),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _buildRadioOption("Default (Auto)", "default", format,
                      isPhone: isPhone),
                  _buildRadioOption("MPEG-TS (.ts)", "ts", format,
                      isPhone: isPhone),
                  _buildRadioOption("HLS (.m3u8)", "m3u8", format,
                      isPhone: isPhone),
                ],
              ),
              SizedBox(height: isPhone ? 12 : 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: isPhone ? 14 : 16, color: Colors.white38),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          "Default works best for most servers. Use 'ts' for speed or 'm3u8' for stability.",
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: isPhone ? 11 : 12)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isPhone ? 16 : 24),
              Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              SizedBox(height: isPhone ? 16 : 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Auto-Start on Boot",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: isPhone ? 14 : 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                            "Automatically launch the app when the TV box is turned on",
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: isPhone ? 11 : 12)),
                      ],
                    ),
                  ),
                  FocusableCard(
                    onTap: () {
                      if (_prefs == null) return;
                      final newVal = !_autoStartEnabled;
                      setState(() {
                        _autoStartEnabled = newVal;
                      });
                      _prefs!.setBool("auto_start_enabled", newVal);
                    },
                    child: Switch(
                      value: _autoStartEnabled,
                      activeColor: kColorPrimary,
                      onChanged: (val) {
                        if (_prefs == null) return;
                        setState(() {
                          _autoStartEnabled = val;
                        });
                        _prefs!.setBool("auto_start_enabled", val);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: isPhone ? 16 : 24),
              Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              SizedBox(height: isPhone ? 16 : 24),
              // ── External Player ──
              Text("Video Player",
                  style: TextStyle(
                      color: kColorTextSecondary,
                      fontSize: isPhone ? 14 : 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                  "Choose how to play streams – use the built-in player or send to an external app like VLC or MX Player.",
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: isPhone ? 11 : 12)),
              SizedBox(height: isPhone ? 12 : 16),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _buildPlayerModeOption("Built-in", "builtin",
                      Icons.play_circle_filled, isPhone: isPhone),
                  _buildPlayerModeOption("External App", "external",
                      Icons.open_in_new_rounded, isPhone: isPhone),
                  _buildPlayerModeOption("Always Ask", "ask",
                      Icons.help_outline_rounded, isPhone: isPhone),
                ],
              ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
            horizontal: isPhone ? 14 : 16, vertical: isPhone ? 9 : 11),
        decoration: BoxDecoration(
          color:
              isSelected ? kColorPrimary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? kColorPrimary
                  : Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: Colors.white,
                size: isPhone ? 16 : 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isPhone ? 12.5 : 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerModeOption(String label, String value, IconData icon,
      {bool isPhone = false}) {
    final groupValue = ExternalPlayerService.playerMode;
    final isSelected = value == groupValue;
    return FocusableCard(
      onTap: () {
        ExternalPlayerService.setPlayerMode(value);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
            horizontal: isPhone ? 14 : 16, vertical: isPhone ? 9 : 11),
        decoration: BoxDecoration(
          color:
              isSelected ? kColorPrimary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? kColorPrimary
                  : Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: isPhone ? 16 : 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isPhone ? 12.5 : 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500)),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
            horizontal: isPhone ? 12 : 16, vertical: isPhone ? 8 : 10),
        decoration: BoxDecoration(
          color:
              isSelected ? kColorPrimary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? kColorPrimary
                  : Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: Colors.white,
                size: isPhone ? 16 : 20),
            SizedBox(width: isPhone ? 6 : 8),
            Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isPhone ? 12 : 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================
  Widget _buildAboutSettings(bool isPhone) {
    Future<void> launchLink(String urlString) async {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $urlString')));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("About", Icons.info_rounded, isPhone,
            caption: "App version & details"),
        _card(
          padding: isPhone ? 16 : 22,
          child: Column(
            children: [
              _buildInfoRow("App Name", kAppName,
                  icon: Icons.apps_rounded, isPhone: isPhone),
              _buildInfoRow("Version", "1.0.0",
                  icon: Icons.numbers_rounded, isPhone: isPhone),
              _buildInfoRow("Developer", "Dev Team",
                  icon: Icons.code_rounded, isPhone: isPhone, isLast: true),
            ],
          ),
        ),
        SizedBox(height: isPhone ? 16 : 22),
        _sectionHeader("Legal & Support", Icons.gavel_rounded, isPhone,
            caption: "Terms, Privacy, and Contact"),
        _card(
          padding: isPhone ? 8 : 12,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.description_rounded, color: kColorPrimary, size: isPhone ? 20 : 24),
                title: Text("Terms of Service", style: TextStyle(color: Colors.white, fontSize: isPhone ? 14 : 16)),
                trailing: Icon(Icons.open_in_new_rounded, color: Colors.white54, size: isPhone ? 16 : 20),
                onTap: () => launchLink('https://vantoplayer.com/terms'),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              ListTile(
                leading: Icon(Icons.privacy_tip_rounded, color: kColorPrimary, size: isPhone ? 20 : 24),
                title: Text("Privacy Policy", style: TextStyle(color: Colors.white, fontSize: isPhone ? 14 : 16)),
                trailing: Icon(Icons.open_in_new_rounded, color: Colors.white54, size: isPhone ? 16 : 20),
                onTap: () => launchLink('https://vantoplayer.com/privacy'),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              ListTile(
                leading: Icon(Icons.contact_support_rounded, color: kColorPrimary, size: isPhone ? 20 : 24),
                title: Text("Contact Us", style: TextStyle(color: Colors.white, fontSize: isPhone ? 14 : 16)),
                trailing: Icon(Icons.open_in_new_rounded, color: Colors.white54, size: isPhone ? 16 : 20),
                onTap: () => launchLink('mailto:support@vantoplayer.com'),
              ),
            ],
          ),
        ),
        SizedBox(height: isPhone ? 16 : 22),
        FocusableCard(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Checking for updates...")),
            );
            UpdateService.checkForUpdates(context, showNoUpdateMessage: true);
          },
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kColorPrimary.withValues(alpha: 0.2),
                foregroundColor: kColorPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 16 : 24,
                  vertical: isPhone ? 14 : 18
                ),
              ),
              icon: Icon(Icons.system_update_rounded, size: isPhone ? 20 : 24),
              label: Text("Check for Updates", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: isPhone ? 14 : 16)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Checking for updates...")),
                );
                UpdateService.checkForUpdates(context, showNoUpdateMessage: true);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE & TIME
  // ============================================================
  Widget _buildDateTimeSettings(bool isPhone) {
    final timeFormat = DateTimeFormatService.getTimeFormat();
    final tzMode = DateTimeFormatService.getTimezoneMode();
    final activeTz = DateTimeFormatService.getActiveTimezone();
    final manualTzId = _storage.read(DateTimeFormatService.getManualTzKey());
    final sample = DateTime.now();
    final padding = isPhone ? 16.0 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Date & Time", Icons.access_time_filled_rounded, isPhone,
            caption: "Formats & timezone used across the app"),

        // ----- Time format -----
        _card(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Time Format",
                  style: TextStyle(
                      color: kColorTextSecondary,
                      fontSize: isPhone ? 13 : 16,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: isPhone ? 4 : 6),
              Text(
                "Preview: ${DateTimeFormatService.formatTime(sample)}",
                style: TextStyle(
                    color: Colors.white70, fontSize: isPhone ? 12 : 14),
              ),
              SizedBox(height: isPhone ? 12 : 16),
              Wrap(
                spacing: isPhone ? 8 : 20,
                runSpacing: isPhone ? 8 : 12,
                children: [
                  _buildEnumRadioOption<TimeFormatOption>(
                      "24-hour (21:30)", TimeFormatOption.h24, timeFormat,
                      (v) async {
                    await DateTimeFormatService.setTimeFormat(v);
                    setState(() {});
                  }, isPhone: isPhone),
                  _buildEnumRadioOption<TimeFormatOption>(
                      "12-hour (09:30 PM)", TimeFormatOption.h12, timeFormat,
                      (v) async {
                    await DateTimeFormatService.setTimeFormat(v);
                    setState(() {});
                  }, isPhone: isPhone),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: isPhone ? 14 : 20),

        // ----- Timezone -----
        _card(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Timezone",
                  style: TextStyle(
                      color: kColorTextSecondary,
                      fontSize: isPhone ? 13 : 16,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: isPhone ? 6 : 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.public_rounded,
                            size: isPhone ? 14 : 16, color: kColorPrimary),
                        const SizedBox(width: 8),
                        Text(
                          "${activeTz.label} (${activeTz.offsetLabel})",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isPhone ? 12 : 14),
                        ),
                      ],
                    ),
                    if (tzMode == TimezoneMode.auto)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 22),
                        child: Text(
                          "Detected from device: "
                          "${DateTimeFormatService.detectDeviceTimezone().label}",
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: isPhone ? 11 : 12),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: isPhone ? 12 : 16),
              Wrap(
                spacing: isPhone ? 8 : 20,
                runSpacing: isPhone ? 8 : 12,
                children: [
                  _buildEnumRadioOption<TimezoneMode>(
                      "Auto-detect", TimezoneMode.auto, tzMode, (v) async {
                    await DateTimeFormatService.setTimezoneMode(v);
                    setState(() {});
                  }, isPhone: isPhone),
                  _buildEnumRadioOption<TimezoneMode>(
                      "Manual", TimezoneMode.manual, tzMode, (v) async {
                    await DateTimeFormatService.setTimezoneMode(v);
                    setState(() {});
                  }, isPhone: isPhone),
                ],
              ),
              SizedBox(height: isPhone ? 12 : 16),
              Builder(builder: (context) {
                Future<void> detectCountry() async {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(const SnackBar(
                      content: Text("Detecting country, please wait...")));
                  final tz =
                      await DateTimeFormatService.detectTimezoneByCountry();
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorCardLight,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(
                            horizontal: isPhone ? 12 : 16,
                            vertical: isPhone ? 12 : 14),
                      ),
                      icon: Icon(Icons.public_rounded,
                          color: kColorPrimary, size: isPhone ? 16 : 18),
                      label: Text("Auto-detect by country",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isPhone ? 12 : 14,
                              fontWeight: FontWeight.w600)),
                      onPressed: detectCountry,
                    ),
                  ),
                );
              }),
              if (tzMode == TimezoneMode.manual) ...[
                SizedBox(height: isPhone ? 14 : 20),
                _buildTimezoneDropdown(manualTzId),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimezoneDropdown(String? currentId) {
    final selectedId =
        currentId ?? DateTimeFormatService.getActiveTimezone().id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Timezone",
            style: TextStyle(
                color: kColorTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: kColorCardLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: kColorCard,
              value: kTimezones.any((t) => t.id == selectedId)
                  ? selectedId
                  : kTimezones.first.id,
              iconEnabledColor: kColorPrimary,
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

  // ============================================================
  // SPEED TEST
  // ============================================================
  Widget _buildSpeedTestPreview(bool isPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Speed Test", Icons.speed_rounded, isPhone,
            caption: "Check your internet connection"),
        _card(
          padding: isPhone ? 24 : 36,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isPhone ? 18 : 24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kColorPrimary.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.speed_rounded,
                    size: isPhone ? 48 : 64, color: kColorPrimary),
              ),
              SizedBox(height: isPhone ? 16 : 22),
              Text("Internet Speed Test",
                  style: (isPhone
                          ? Get.textTheme.titleLarge
                          : Get.textTheme.headlineMedium)
                      ?.copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: isPhone ? 6 : 10),
              Text(
                  "Check your internet connection speed to ensure smooth streaming.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: kColorTextSecondary, fontSize: isPhone ? 12 : 14)),
              SizedBox(height: isPhone ? 20 : 28),
              FocusableCard(
                onTap: () => Get.to(() => const SpeedTestScreen()),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kColorPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(
                          horizontal: isPhone ? 24 : 32,
                          vertical: isPhone ? 13 : 16),
                    ),
                    icon:
                        Icon(Icons.play_arrow_rounded, size: isPhone ? 20 : 24),
                    label: Text("Start Test",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isPhone ? 14 : 16)),
                    onPressed: () => Get.to(() => const SpeedTestScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Small reusable widgets
// ============================================================
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onTap: onTap,
      scale: 1.05,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool active;

  const _StatusPill({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? kColorSuccess : kColorError;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
