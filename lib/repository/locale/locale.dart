part of '../api/api.dart';

class LocaleApi {
  static Future<void> saveUser(UserModel user) async {
    await locale.write("user", user.toJson());
  }

  static Future<UserModel?> getUser() async {
    final json = await locale.read("user");
    if (json != null) {
      // We need to pass the domain, but it's part of server_info in the saved json
      // So we handle it in fromJson
      return UserModel.fromJson(json, "");
    }
    return null;
  }

  static Future<void> clearUser() async {
    await locale.remove("user");
  }
}
