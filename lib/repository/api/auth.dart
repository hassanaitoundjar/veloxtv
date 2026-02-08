part of 'api.dart';

class AuthApi {
  Future<UserModel?> login(String username, String password, String url) async {
    try {
      final link = "$url/player_api.php";

      Response<String> response = await _dio.get(
        link,
        queryParameters: {
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.data ?? "{}");

        if (json['user_info'] != null) {
          final user = UserModel.fromJson(json, url);
          // Check if account is active or valid
          if (user.userInfo?.auth == "0") {
             debugPrint("Auth failed: Invalid credentials");
             return null;
          }
          await LocaleApi.saveUser(user);
          return user;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }
}
