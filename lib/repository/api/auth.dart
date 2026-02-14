part of 'api.dart';

class AuthApi {
  /// Xtream Codes login
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

  /// M3U Playlist login — auto-detects Xtream URLs and extracts credentials
  Future<UserModel?> loginM3u(String name, String m3uUrl) async {
    try {
      // Try to extract Xtream credentials from the M3U URL
      final xtreamCredentials = _extractXtreamCredentials(m3uUrl);

      if (xtreamCredentials != null) {
        // Xtream URL detected — use the full Xtream Codes API
        debugPrint("M3U: Detected Xtream URL, extracting credentials...");
        debugPrint("  Server: ${xtreamCredentials['server']}");
        debugPrint("  Username: ${xtreamCredentials['username']}");

        final user = await login(
          xtreamCredentials['username']!,
          xtreamCredentials['password']!,
          xtreamCredentials['server']!,
        );

        return user;
      }

      // Not an Xtream URL — fall back to raw M3U parsing
      debugPrint("M3U: Non-Xtream URL, using raw M3U parser...");
      final isValid = await M3uParser.validateM3uUrl(m3uUrl);
      if (!isValid) {
        return null;
      }

      // Create a virtual user for pure M3U
      final user = UserModel(
        connectionType: ConnectionType.m3u,
        m3uUrl: m3uUrl,
        userInfo: UserInfo(
          username: name,
          password: '',
          auth: '1',
          status: 'Active',
        ),
        serverInfo: ServerInfo(
          serverUrl: m3uUrl,
          url: m3uUrl,
          port: '',
        ),
      );

      await LocaleApi.saveUser(user);
      return user;
    } catch (e) {
      debugPrint("M3U Login Error: $e");
      return null;
    }
  }

  /// Extract Xtream Codes credentials from an M3U URL
  /// Supports formats like:
  ///   http://server.com:port/get.php?username=X&password=Y&type=m3u
  ///   http://server.com:port/username/password/...
  Map<String, String>? _extractXtreamCredentials(String m3uUrl) {
    try {
      final uri = Uri.parse(m3uUrl);

      // Format 1: /get.php?username=X&password=Y
      if (uri.path.contains('get.php') || uri.path.contains('player_api.php')) {
        final username = uri.queryParameters['username'];
        final password = uri.queryParameters['password'];

        if (username != null &&
            username.isNotEmpty &&
            password != null &&
            password.isNotEmpty) {
          // Reconstruct server URL: scheme + host + port
          final port = uri.port != 80 && uri.port != 443 ? ':${uri.port}' : '';
          final server = '${uri.scheme}://${uri.host}$port';
          return {
            'server': server,
            'username': username,
            'password': password,
          };
        }
      }

      // Format 2: http://server.com:port/username/password/12345
      final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (pathSegments.length >= 2) {
        // Check if it looks like a stream URL (not get.php)
        final possibleUsername = pathSegments[0];
        final possiblePassword = pathSegments[1];

        // Validate: username/password shouldn't be common path segments
        if (!['get.php', 'player_api.php', 'xmltv.php', 'panel_api.php']
            .contains(possibleUsername)) {
          final port = uri.port != 80 && uri.port != 443 ? ':${uri.port}' : '';
          final server = '${uri.scheme}://${uri.host}$port';
          return {
            'server': server,
            'username': possibleUsername,
            'password': possiblePassword,
          };
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Stalker Portal login — authenticates via MAC address
  Future<UserModel?> loginStalker(
      String name, String portalUrl, String macAddress) async {
    try {
      // Authenticate via Stalker handshake
      final authenticated =
          await StalkerApi.authenticate(portalUrl, macAddress);
      if (!authenticated) {
        return null;
      }

      // Create a virtual user for Stalker
      final user = UserModel(
        connectionType: ConnectionType.stalker,
        macAddress: macAddress,
        userInfo: UserInfo(
          username: name,
          password: '',
          auth: '1',
          status: 'Active',
        ),
        serverInfo: ServerInfo(
          serverUrl: portalUrl,
          url: portalUrl,
          port: '',
        ),
      );

      await LocaleApi.saveUser(user);
      return user;
    } catch (e) {
      debugPrint("Stalker Login Error: $e");
      return null;
    }
  }
}
