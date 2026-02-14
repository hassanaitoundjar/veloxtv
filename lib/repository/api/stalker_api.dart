part of 'api.dart';

/// Stalker Portal (Ministra) API adapter.
/// Handles MAC address authentication and channel fetching
/// from Stalker/MAG-style IPTV portals.
class StalkerApi {
  static String? _token;
  static String? _portalUrl;
  static String? _macAddress;

  /// Initialize with portal URL and MAC address
  static void init(String portalUrl, String macAddress) {
    _portalUrl = portalUrl.endsWith('/')
        ? portalUrl.substring(0, portalUrl.length - 1)
        : portalUrl;
    _macAddress = macAddress;
    _token = null;
  }

  /// Common headers for Stalker Portal requests
  static Map<String, String> _headers() {
    return {
      'User-Agent': 'Mozilla/5.0 (QtEmbedded; U; Linux; C)',
      'Cookie':
          'mac=${Uri.encodeComponent(_macAddress ?? "")}; stb_lang=en; timezone=Europe/London',
      'X-User-Agent': 'Model: MAG250; Link: WiFi',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  /// Handshake — get token from portal
  static Future<bool> handshake() async {
    try {
      final url =
          '$_portalUrl/portal.php?type=stb&action=handshake&JsHttpRequest=1-xml';
      final response = await _dio.get<String>(
        url,
        options: Options(headers: _headers()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = jsonDecode(response.data!);
        _token = json['js']?['token'];
        return _token != null && _token!.isNotEmpty;
      }
      return false;
    } catch (e) {
      debugPrint("Stalker Handshake Error: $e");
      return false;
    }
  }

  /// Get profile to verify authentication
  static Future<bool> getProfile() async {
    try {
      final url =
          '$_portalUrl/portal.php?type=stb&action=get_profile&JsHttpRequest=1-xml';
      final response = await _dio.get<String>(
        url,
        options: Options(headers: _headers()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = jsonDecode(response.data!);
        return json['js'] != null;
      }
      return false;
    } catch (e) {
      debugPrint("Stalker Profile Error: $e");
      return false;
    }
  }

  /// Authenticate: handshake + profile
  static Future<bool> authenticate(String portalUrl, String macAddress) async {
    init(portalUrl, macAddress);
    final handshakeOk = await handshake();
    if (!handshakeOk) return false;
    return await getProfile();
  }

  /// Get IPTV categories
  static Future<List<CategoryModel>> getCategories(
      {String type = 'itv'}) async {
    try {
      final url =
          '$_portalUrl/portal.php?type=$type&action=get_genres&JsHttpRequest=1-xml';
      final response = await _dio.get<String>(
        url,
        options: Options(headers: _headers()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = jsonDecode(response.data!);
        final List<dynamic> genres = json['js'] ?? [];
        return genres
            .map((g) => CategoryModel(
                  categoryId: g['id']?.toString() ?? '',
                  categoryName:
                      g['title']?.toString() ?? g['name']?.toString() ?? '',
                  parentId: 0,
                ))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Stalker Categories Error: $e");
      return [];
    }
  }

  /// Get IPTV channels for a specific genre
  static Future<List<ChannelLive>> getChannels({
    String type = 'itv',
    String? genreId,
    int page = 1,
  }) async {
    try {
      String url =
          '$_portalUrl/portal.php?type=$type&action=get_ordered_list&genre=${genreId ?? '*'}&fav=0&sortby=number&p=$page&JsHttpRequest=1-xml';
      final response = await _dio.get<String>(
        url,
        options: Options(headers: _headers()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = jsonDecode(response.data!);
        final data = json['js']?['data'] as List<dynamic>? ?? [];
        return data.map((ch) {
          // Stalker channel URLs are in cmd field, format: "ffmpeg http://..."
          String streamUrl = ch['cmd']?.toString() ?? '';
          if (streamUrl.startsWith('ffmpeg ')) {
            streamUrl = streamUrl.substring(7);
          }

          return ChannelLive(
            num: int.tryParse(ch['number']?.toString() ?? '') ?? 0,
            name: ch['name']?.toString(),
            streamIcon: ch['logo']?.toString(),
            streamId: ch['id']?.toString(),
            directSource: streamUrl,
            categoryId: genreId,
            epgChannelId: ch['epg_id']?.toString(),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Stalker Channels Error: $e");
      return [];
    }
  }

  /// Get VOD categories
  static Future<List<CategoryModel>> getVodCategories() async {
    return getCategories(type: 'vod');
  }

  /// Get VOD items
  static Future<List<ChannelMovie>> getVodItems({
    String? genreId,
    int page = 1,
  }) async {
    try {
      String url =
          '$_portalUrl/portal.php?type=vod&action=get_ordered_list&genre=${genreId ?? '*'}&sortby=added&p=$page&JsHttpRequest=1-xml';
      final response = await _dio.get<String>(
        url,
        options: Options(headers: _headers()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = jsonDecode(response.data!);
        final data = json['js']?['data'] as List<dynamic>? ?? [];
        return data.map((item) {
          String streamUrl = item['cmd']?.toString() ?? '';
          if (streamUrl.startsWith('ffmpeg ')) {
            streamUrl = streamUrl.substring(7);
          }

          return ChannelMovie(
            num: int.tryParse(item['number']?.toString() ?? '') ?? 0,
            name: item['name']?.toString(),
            streamIcon: item['screenshot_uri']?.toString(),
            streamId: item['id']?.toString(),
            directSource: streamUrl,
            categoryId: genreId,
            rating: item['rating_imdb']?.toString(),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Stalker VOD Error: $e");
      return [];
    }
  }

  /// Get series categories
  static Future<List<CategoryModel>> getSeriesCategories() async {
    return getCategories(type: 'series');
  }

  /// Get series items
  static Future<List<ChannelSerie>> getSeriesItems({
    String? genreId,
    int page = 1,
  }) async {
    try {
      String url =
          '$_portalUrl/portal.php?type=series&action=get_ordered_list&genre=${genreId ?? '*'}&sortby=name&p=$page&JsHttpRequest=1-xml';
      final response = await _dio.get<String>(
        url,
        options: Options(headers: _headers()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = jsonDecode(response.data!);
        final data = json['js']?['data'] as List<dynamic>? ?? [];
        return data.map((item) {
          return ChannelSerie(
            num: (int.tryParse(item['number']?.toString() ?? '') ?? 0)
                .toString(),
            name: item['name']?.toString(),
            cover: item['screenshot_uri']?.toString(),
            seriesId: item['id']?.toString(),
            categoryId: genreId,
            rating: item['rating_imdb']?.toString(),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Stalker Series Error: $e");
      return [];
    }
  }

  /// Create a link for Stalker channel playback
  static Future<String?> createLink(String cmd, {String type = 'itv'}) async {
    try {
      String encodedCmd = Uri.encodeComponent(cmd);
      final url =
          '$_portalUrl/portal.php?type=$type&action=create_link&cmd=$encodedCmd&series=&forced_storage=undefined&disable_ad=0&download=0&JsHttpRequest=1-xml';
      final response = await _dio.get<String>(
        url,
        options: Options(headers: _headers()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = jsonDecode(response.data!);
        String? link = json['js']?['cmd']?.toString();
        if (link != null && link.startsWith('ffmpeg ')) {
          link = link.substring(7);
        }
        return link;
      }
      return null;
    } catch (e) {
      debugPrint("Stalker CreateLink Error: $e");
      return null;
    }
  }
}
