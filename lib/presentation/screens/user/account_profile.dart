part of '../screens.dart';

/// Responsive size tokens for AccountProfileScreen across all device classes.
class _ProfileSizes {
  final double horizontalPadding;
  final double verticalPadding;
  final double maxContentWidth;
  final double titleFontSize;
  final double labelFontSize;
  final double valueFontSize;
  final double labelWidth;
  final double rowGap;
  final double rowSpacing;
  final double sectionSpacing;
  final double statusPadH;
  final double statusPadV;
  final double statusFontSize;
  final double buttonWidth;
  final double buttonFontSize;
  final double buttonVerticalPad;
  final bool stackLabelValue;

  const _ProfileSizes({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.maxContentWidth,
    required this.titleFontSize,
    required this.labelFontSize,
    required this.valueFontSize,
    required this.labelWidth,
    required this.rowGap,
    required this.rowSpacing,
    required this.sectionSpacing,
    required this.statusPadH,
    required this.statusPadV,
    required this.statusFontSize,
    required this.buttonWidth,
    required this.buttonFontSize,
    required this.buttonVerticalPad,
    required this.stackLabelValue,
  });

  factory _ProfileSizes.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isTvDevice = isTv(context);

    // --- Small phone (< 360) ---
    if (width < 360) {
      return const _ProfileSizes(
        horizontalPadding: 16,
        verticalPadding: 20,
        maxContentWidth: 360,
        titleFontSize: 16,
        labelFontSize: 13,
        valueFontSize: 13,
        labelWidth: 120,
        rowGap: 8,
        rowSpacing: 12,
        sectionSpacing: 20,
        statusPadH: 10,
        statusPadV: 5,
        statusFontSize: 11,
        buttonWidth: double.infinity,
        buttonFontSize: 14,
        buttonVerticalPad: 14,
        stackLabelValue: true,
      );
    }
    // --- Standard phone (360 - 599) ---
    if (width < 600) {
      return const _ProfileSizes(
        horizontalPadding: 20,
        verticalPadding: 24,
        maxContentWidth: 480,
        titleFontSize: 22,
        labelFontSize: 14,
        valueFontSize: 14,
        labelWidth: 140,
        rowGap: 10,
        rowSpacing: 14,
        sectionSpacing: 24,
        statusPadH: 12,
        statusPadV: 6,
        statusFontSize: 12,
        buttonWidth: double.infinity,
        buttonFontSize: 15,
        buttonVerticalPad: 15,
        stackLabelValue: true,
      );
    }
    // --- Tablet portrait / small (600 - 899) ---
    if (width < 900) {
      return const _ProfileSizes(
        horizontalPadding: 40,
        verticalPadding: 20,
        maxContentWidth: 560,
        titleFontSize: 26,
        labelFontSize: 16,
        valueFontSize: 16,
        labelWidth: 180,
        rowGap: 16,
        rowSpacing: 10,
        sectionSpacing: 32,
        statusPadH: 14,
        statusPadV: 7,
        statusFontSize: 13,
        buttonWidth: 280,
        buttonFontSize: 16,
        buttonVerticalPad: 16,
        stackLabelValue: false,
      );
    }
    // --- Tablet landscape / small desktop (900 - 1279) ---
    if (width < 1280) {
      return const _ProfileSizes(
        horizontalPadding: 60,
        verticalPadding: 36,
        maxContentWidth: 640,
        titleFontSize: 28,
        labelFontSize: 17,
        valueFontSize: 17,
        labelWidth: 220,
        rowGap: 20,
        rowSpacing: 18,
        sectionSpacing: 36,
        statusPadH: 14,
        statusPadV: 7,
        statusFontSize: 13,
        buttonWidth: 300,
        buttonFontSize: 16,
        buttonVerticalPad: 16,
        stackLabelValue: false,
      );
    }
    // --- TV / large desktop (>= 1280) ---
    return _ProfileSizes(
      horizontalPadding: 80,
      verticalPadding: 48,
      maxContentWidth: isTvDevice ? 760 : 700,
      titleFontSize: isTvDevice ? 36 : 32,
      labelFontSize: isTvDevice ? 20 : 18,
      valueFontSize: isTvDevice ? 20 : 18,
      labelWidth: isTvDevice ? 280 : 260,
      rowGap: 24,
      rowSpacing: 22,
      sectionSpacing: 48,
      statusPadH: 16,
      statusPadV: 8,
      statusFontSize: 14,
      buttonWidth: 320,
      buttonFontSize: 18,
      buttonVerticalPad: 18,
      stackLabelValue: false,
    );
  }
}

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = _ProfileSizes.of(context);

    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: FocusableCard(
          onTap: () => Get.back(),
          scale: 1.1,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        title: Text(
          "My Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: s.titleFontSize * 0.6,
          ),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthSuccess) {
            return const Center(
              child:
                  Text("Not logged in", style: TextStyle(color: Colors.white)),
            );
          }

          final user = state.user;
          final userInfo = user.userInfo;
          final serverInfo = user.serverInfo;

          final username = userInfo?.username ?? "Unknown";
          final dns = serverInfo?.url ?? user.m3uUrl ?? "Unknown DNS";
          final isTrial = userInfo?.isTrial == "1" ? "Yes" : "No";
          final maxConnections = userInfo?.maxConnections ?? "1";

          String expDateStr = "Unlimited";
          String remainingDaysStr = "Unlimited";

          if (userInfo?.expDate != null && userInfo!.expDate!.isNotEmpty) {
            final expDateNum = int.tryParse(userInfo.expDate!);
            if (expDateNum != null) {
              final date =
                  DateTime.fromMillisecondsSinceEpoch(expDateNum * 1000);
              expDateStr =
                  "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

              final now = DateTime.now();
              final diff = date.difference(now).inDays;
              remainingDaysStr = diff >= 0 ? "$diff Days" : "Expired";
            } else {
              expDateStr = userInfo.expDate!;
            }
          }

          String createdAtStr = "Unknown";
          if (userInfo?.createdAt != null && userInfo!.createdAt!.isNotEmpty) {
            final createdNum = int.tryParse(userInfo.createdAt!);
            if (createdNum != null) {
              final date =
                  DateTime.fromMillisecondsSinceEpoch(createdNum * 1000);
              createdAtStr =
                  "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
            } else {
              createdAtStr = userInfo.createdAt!;
            }
          }

          final activeCons = userInfo?.activeCons ?? "0";

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: s.horizontalPadding,
                vertical: s.verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: s.maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Subscription Info",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: s.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: s.sectionSpacing),
                      _buildInfoRow(
                        s,
                        "Username:",
                        Text(username,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: s.valueFontSize)),
                      ),
                      _buildInfoRow(
                        s,
                        "DNS / Server:",
                        Text(dns,
                            style: TextStyle(
                                color: Colors.white, fontSize: s.valueFontSize),
                            overflow: TextOverflow.ellipsis),
                      ),
                      _buildInfoRow(
                        s,
                        "Account Status:",
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: s.statusPadH, vertical: s.statusPadV),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text("Active",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: s.statusFontSize,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      _buildInfoRow(
                        s,
                        "Expiry Date:",
                        Text(expDateStr,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: s.valueFontSize)),
                      ),
                      _buildInfoRow(
                        s,
                        "Remaining Days:",
                        Text(remainingDaysStr,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: s.valueFontSize)),
                      ),
                      _buildInfoRow(
                        s,
                        "Is Trial:",
                        Text(isTrial,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: s.valueFontSize)),
                      ),
                      _buildInfoRow(
                        s,
                        "Active Connections:",
                        Text(activeCons,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: s.valueFontSize)),
                      ),
                      _buildInfoRow(
                        s,
                        "Created At:",
                        Text(createdAtStr,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: s.valueFontSize)),
                      ),
                      _buildInfoRow(
                        s,
                        "Max Connections:",
                        Text(maxConnections,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: s.valueFontSize,
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: s.sectionSpacing),
                      Align(
                        alignment: Alignment.center,
                        child: FocusableCard(
                          onTap: () => Get.toNamed(screenProfiles),
                          scale: 1.05,
                          child: Container(
                            width: s.buttonWidth,
                            padding: EdgeInsets.symmetric(
                                vertical: s.buttonVerticalPad),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  kColorPrimary,
                                  kColorPrimary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: kColorPrimary.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.switch_account,
                                    color: Colors.white,
                                    size: s.buttonFontSize + 4),
                                const SizedBox(width: 8),
                                Text(
                                  "Switch User",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: s.buttonFontSize,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(_ProfileSizes s, String label, Widget valueWidget) {
    final labelText = Text(
      label,
      style: TextStyle(color: Colors.white70, fontSize: s.labelFontSize),
    );

    if (s.stackLabelValue) {
      // Small screens: stack label above value to avoid squeezing/overflow
      return Padding(
        padding: EdgeInsets.only(bottom: s.rowSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelText,
            SizedBox(height: s.rowGap / 2),
            valueWidget,
          ],
        ),
      );
    }

    // Larger screens: side-by-side row, label fixed width, value flexible
    return Padding(
      padding: EdgeInsets.only(bottom: s.rowSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: s.labelWidth, child: labelText),
          SizedBox(width: s.rowGap),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: valueWidget,
            ),
          ),
        ],
      ),
    );
  }
}
