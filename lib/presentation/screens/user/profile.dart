part of '../screens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FocusNode _addFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthLoadProfiles());
  }

  @override
  void dispose() {
    _addFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTvDevice = isTv(context);
    final isWide = size.width >= 650;
    
    // Determine grid columns based on screen width
    int crossAxisCount = 1;
    if (size.width >= 1200) {
      crossAxisCount = 4;
    } else if (size.width >= 900) {
      crossAxisCount = 3;
    } else if (size.width >= 600) {
      crossAxisCount = 2;
    }

    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("LIST USERS",
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FocusableCard(
              focusNode: _addFocus,
              onTap: () => Get.toNamed(screenIntro),
              scale: 1.05,
              showFocusBorder: false,
              builder: (context, isFocused) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isFocused ? Colors.white : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isFocused ? Colors.white : Colors.white24,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Icon(Icons.add, color: isFocused ? Colors.black : Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text("ADD USER", style: TextStyle(color: isFocused ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Get.offAllNamed(screenHome);
          } else if (state is AuthFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
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

          if (profiles.isEmpty) {
            return Center(
              child: Text(
                "No profiles found. Please add a user.",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 18),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTvDevice || isWide ? 40.0 : 16.0, vertical: 20.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 100, // Fixed height for the Row layout
              ),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final user = profiles[index];
                final isActive = _isActive(user, activeUser);
                return _buildProfileCard(context, user, isActive, index == 0);
              },
            ),
          );
        },
      ),
    );
  }

  bool _isActive(UserModel user, UserModel? activeUser) {
    if (activeUser == null) return false;
    if (user.connectionType != activeUser.connectionType) return false;
    if (user.connectionType == ConnectionType.xtream) {
      return user.userInfo?.username == activeUser.userInfo?.username &&
          user.serverInfo?.url == activeUser.serverInfo?.url;
    } else {
      return user.m3uUrl == activeUser.m3uUrl;
    }
  }

  Widget _buildProfileCard(
      BuildContext context, UserModel user, bool isActive, bool autoFocus) {
    final name = user.userInfo?.username ?? user.name ?? "Playlist";
    final sub = user.connectionType == ConnectionType.xtream
        ? (user.serverInfo?.url ?? "Xtream Codes")
        : "M3U Playlist";

    return FocusableCard(
      autoFocus: autoFocus,
      onTap: () => context.read<AuthBloc>().add(AuthSwitchProfile(user)),
      scale: 1.05,
      child: Container(
        decoration: BoxDecoration(
          color: kColorCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? kColorPrimary : Colors.white.withValues(alpha: 0.1),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: kColorPrimary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isActive ? kColorPrimary : Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: isActive ? Colors.white : Colors.white70,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content (Name, Sub, and Active Tag)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kColorPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "ACTIVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Delete Icon
              InkWell(
                onTap: () => _confirmDelete(context, user),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                ),
              ),
            ],
          ),
        ),
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

extension UserDisplay on UserModel {
  String? get name {
    return userInfo?.username;
  }
}
