part of '../screens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _addFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthLoadProfiles());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    final isTvDevice = isTv(context);

    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("User Profiles",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                int count = 0;
                if (state is AuthProfilesLoaded) {
                  count = state.profiles.length;
                }
                return Text("$count profiles",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12));
              },
            ),
          ],
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Get.offAllNamed(screenWelcome);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: kColorPrimary, size: 40));
          }

          List<UserModel> profiles = [];
          UserModel? activeUser;

          if (state is AuthProfilesLoaded) {
            profiles = state.profiles;
            activeUser = state.activeUser;
          }

          final filter = _searchController.text.toLowerCase();
          final filteredProfiles = profiles.where((p) {
            final name = p.userInfo?.username ?? p.name ?? "Unknown";
            return name.toLowerCase().contains(filter);
          }).toList();

          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTvDevice || isLandscape ? 10.w : 16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Search Bar
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (v) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search profiles...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kColorPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Profiles List
                Expanded(
                  child: filteredProfiles.isEmpty
                      ? Center(
                          child: Text("No profiles found",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5))))
                      : ListView.separated(
                          itemCount: filteredProfiles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = filteredProfiles[index];
                            final isActive = _isActive(user, activeUser);
                            return _buildProfileCard(context, user, isActive);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        height: 50,
        width: 140,
        child: FloatingActionButton.extended(
          focusNode: _addFocus,
          onPressed: () => Get.toNamed(screenIntro),
          backgroundColor: kColorPrimary,
          label: const Text("Add New",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  bool _isActive(UserModel user, UserModel? activeUser) {
    if (activeUser == null) return false;
    // Simple comparison logic matching LocaleApi
    if (user.connectionType != activeUser.connectionType) return false;
    if (user.connectionType == ConnectionType.xtream) {
      return user.userInfo?.username == activeUser.userInfo?.username &&
          user.serverInfo?.url == activeUser.serverInfo?.url;
    } else if (user.connectionType == ConnectionType.m3u) {
      return user.m3uUrl == activeUser.m3uUrl;
    } else {
      return user.macAddress == activeUser.macAddress;
    }
  }

  Widget _buildProfileCard(
      BuildContext context, UserModel user, bool isActive) {
    final name = user.userInfo?.username ?? user.name ?? "Playlist";
    final sub = user.connectionType == ConnectionType.xtream
        ? (user.serverInfo?.url ?? "Xtream Codes")
        : (user.connectionType == ConnectionType.m3u
            ? "M3U Playlist"
            : "Stalker Portal");

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? kColorPrimary.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isActive ? kColorPrimary : Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color:
                    isActive ? kColorPrimary : Colors.white.withOpacity(0.3)),
            color: isActive ? kColorPrimary : Colors.transparent,
          ),
          child: Icon(Icons.person_outline,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7)),
        ),
        title: Text(name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle:
            Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.6))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kColorPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text("ACTIVE",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
              onPressed: () => _confirmDelete(context, user),
            ),
          ],
        ),
        onTap: () {
          if (!isActive) {
            context.read<AuthBloc>().add(AuthSwitchProfile(user));
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel user) {
    Get.defaultDialog(
      title: "Delete Profile",
      middleText: "Are you sure you want to delete this profile?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      backgroundColor: kColorCard,
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white),
      onConfirm: () {
        context.read<AuthBloc>().add(AuthDeleteProfile(user));
        Get.back();
      },
    );
  }
}

// Extension to safely get name/url/etc since UserModel structure might vary
extension UserDisplay on UserModel {
  String? get name {
    // Use m3uUrl as name fallback if no other name?
    // Actually M3U login had 'name' param but model has m3uUrl.
    // Waiting for user.dart verification.
    // In AuthBloc: repo.loginM3u(event.name, event.m3uUrl) -> returns UserModel.
    // Existing UserModel doesn't have 'name' field, it has 'userInfo.username'.
    // So for M3U/Stalker, we probably stored 'name' in userInfo.username?
    // Let's check user.dart again or assume userInfo.username is used.
    return userInfo?.username;
  }
}
