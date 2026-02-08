part of '../screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                    const Icon(Icons.settings, size: 40, color: Colors.white),
                    const SizedBox(height: 10),
                    Text("Settings", style: Get.textTheme.titleLarge),
                    const SizedBox(height: 40),
                    _buildSettingItem(
                      icon: Icons.person,
                      title: "Account",
                      isSelected: true,
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.monitor,
                      title: "Player",
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.info,
                      title: "About",
                      onTap: () {},
                    ),
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
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthSuccess) {
                      final info = state.user.userInfo!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Account Information",
                              style: Get.textTheme.headlineMedium),
                          const SizedBox(height: 20),
                          _buildInfoTile("Username", info.username ?? "-"),
                          _buildInfoTile("Status", info.status ?? "-"),
                          _buildInfoTile(
                              "Expiry Date", info.expDate ?? "Unlimited"),
                          _buildInfoTile(
                              "Active Connections", info.activeCons ?? "0"),
                          _buildInfoTile(
                              "Max Connections", info.maxConnections ?? "1"),
                        ],
                      );
                    }
                    return const Center(child: Text("No User Information"));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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
}
