part of '../api/api.dart';

class LocaleApi {
  static const String _keyUser = "user";
  static const String _keyProfiles = "profiles";

  /// Save the currently active user
  static Future<void> saveUser(UserModel user) async {
    await locale.write(_keyUser, user.toJson());
    await addProfile(user); // Also ensure it's in the profiles list
  }

  /// Get the currently active user
  static Future<UserModel?> getUser() async {
    final json = await locale.read(_keyUser);
    if (json != null) {
      return UserModel.fromJson(json, "");
    }
    return null;
  }

  /// Clear the currently active user (logout)
  static Future<void> clearUser() async {
    await locale.remove(_keyUser);
  }

  /// Get all saved profiles
  static List<UserModel> getProfiles() {
    final List<dynamic>? jsonList = locale.read(_keyProfiles);
    if (jsonList != null) {
      return jsonList.map((e) => UserModel.fromJson(e, "")).toList();
    }

    // Migration: If no profiles list but a user exists, create list with that user
    final currentUserJson = locale.read(_keyUser);
    if (currentUserJson != null) {
      final user = UserModel.fromJson(currentUserJson, "");
      saveProfiles([user]);
      return [user];
    }

    return [];
  }

  /// Save the entire list of profiles
  static Future<void> saveProfiles(List<UserModel> profiles) async {
    final jsonList = profiles.map((e) => e.toJson()).toList();
    await locale.write(_keyProfiles, jsonList);
  }

  /// Add or Update a profile in the list
  static Future<void> addProfile(UserModel user) async {
    final profiles = getProfiles();

    // Check if profile already exists (by username/url/mac/m3u)
    final index = profiles.indexWhere((p) => _isSameProfile(p, user));

    if (index >= 0) {
      profiles[index] = user; // Update existing
    } else {
      profiles.add(user); // Add new
    }

    await saveProfiles(profiles);
  }

  /// Remove a profile
  static Future<void> removeProfile(UserModel user) async {
    final profiles = getProfiles();
    profiles.removeWhere((p) => _isSameProfile(p, user));
    await saveProfiles(profiles);

    // If we removed the active user, clear it
    final activeUser = await getUser();
    if (activeUser != null && _isSameProfile(activeUser, user)) {
      await clearUser();
    }
  }

  /// Helper to check if two profiles represent the same account
  static bool _isSameProfile(UserModel a, UserModel b) {
    if (a.connectionType != b.connectionType) return false;

    switch (a.connectionType) {
      case ConnectionType.xtream:
        return a.userInfo?.username == b.userInfo?.username &&
            a.serverInfo?.url == b.serverInfo?.url;
      case ConnectionType.m3u:
        return a.m3uUrl == b.m3uUrl;
      case ConnectionType.stalker:
        return a.macAddress == b.macAddress &&
            a.serverInfo?.url == b.serverInfo?.url;
    }
  }
}
