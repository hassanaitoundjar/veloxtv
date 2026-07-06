part of 'api.dart';

class IpTvApi {
  /// Fetches content categories from the server.
  ///
  /// The [type] parameter determines the category type:
  /// - 'get_live_categories' for Live TV
  /// - 'get_vod_categories' for Movies
  /// - 'get_series_categories' for Series
  Future<List<CategoryModel>> getCategories(String type) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        debugPrint("User session is missing");
        return [];
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<String> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": type,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.data ?? "[]");
        final list = json.map((e) => CategoryModel.fromJson(e)).toList();
        return list;
      }

      return [];
    } catch (e) {
      debugPrint("Error fetching categories ($type): $e");
      return [];
    }
  }

  /// Fetches live TV channels.
  ///
  /// If [catyId] is provided, it filters channels by that specific category.
  Future<List<ChannelLive>> getLiveChannels(String? catyId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        throw Exception("User not found");
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      final query = {
        "password": user.userInfo!.password,
        "username": user.userInfo!.username,
        "action": "get_live_streams",
      };

      if (catyId != null) {
        query["category_id"] = catyId;
      }

      Response<List<dynamic>> response = await _dio.get(
        url,
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        final json = response.data ?? [];
        final list = json.map((e) => ChannelLive.fromJson(e)).toList();
        return list;
      }

      throw Exception("Failed to load live channels. Status code: ${response.statusCode}");
    } catch (e) {
      debugPrint("Error Channel $catyId: $e");
      throw Exception("Failed to load live channels: $e");
    }
  }

  /// Movie Channels
  Future<List<ChannelMovie>> getMovieChannels(String? catyId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        throw Exception("User not found");
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      final query = {
        "password": user.userInfo!.password,
        "username": user.userInfo!.username,
        "action": "get_vod_streams",
      };

      if (catyId != null) {
        query["category_id"] = catyId;
      }

      Response<List<dynamic>> response = await _dio.get(
        url,
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        final json = response.data ?? [];
        final list = json.map((e) => ChannelMovie.fromJson(e)).toList();
        return list;
      }

      throw Exception("Failed to load movie channels. Status code: ${response.statusCode}");
    } catch (e) {
      debugPrint("Error Movie Channel $catyId: $e");
      throw Exception("Failed to load movie channels: $e");
    }
  }

  /// Series Channels
  Future<List<ChannelSerie>> getSeriesChannels(String? catyId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        throw Exception("User not found");
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      final query = {
        "password": user.userInfo!.password,
        "username": user.userInfo!.username,
        "action": "get_series",
      };

      if (catyId != null) {
        query["category_id"] = catyId;
      }

      Response<List<dynamic>> response = await _dio.get(
        url,
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        final json = response.data ?? [];
        final list = json.map((e) => ChannelSerie.fromJson(e)).toList();
        return list;
      }

      throw Exception("Failed to load series channels. Status code: ${response.statusCode}");
    } catch (e) {
      debugPrint("Error Series Channel $catyId: $e");
      throw Exception("Failed to load series channels: $e");
    }
  }

  /// Movie Detail
  static Future<MovieDetail?> getMovieDetails(String movieId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        return null;
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<String> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": "get_vod_info",
          "vod_id": movieId,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.data ?? "[]");
        final movie = MovieDetail.fromJson(json);
        return movie;
      }

      return null;
    } catch (e) {
      debugPrint("Error Movie Detail $movieId: $e");
      return null;
    }
  }

  /// Serie Detail
  static Future<SerieDetails?> getSerieDetails(String serieId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        return null;
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<String> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": "get_series_info",
          "series_id": serieId,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.data ?? "");
        final serie = SerieDetails.fromJson(json);
        return serie;
      }

      return null;
    } catch (e) {
      debugPrint("Error Serie Detail $serieId: $e");
      return null;
    }
  }

  /// EPG LIVE
  static Future<List<EpgModel>> getEPGbyStreamId(String streamId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        return [];
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<String> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": "get_short_epg",
          "stream_id": streamId,
          "limit": 30,
        },
      );

      if (response.statusCode == 200) {
        return await compute(_parseEpgListings, response.data);
      }

      return [];
    } catch (e) {
      debugPrint("Error EPG $streamId: $e");
      return [];
    }
  }

  static List<EpgModel> _parseEpgListings(String? data) {
    final dynamic decoded = jsonDecode(data ?? "{}");

    if (decoded is Map<String, dynamic>) {
      if (decoded['epg_listings'] != null) {
        final List<dynamic> json = decoded['epg_listings'];
        return json.map((e) => EpgModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  /// Full EPG (including past programs) — used for Catch-Up archives.
  /// Uses `get_simple_data_table` which returns all available EPG entries.
  static Future<List<EpgModel>> getFullEPGbyStreamId(String streamId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        return [];
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<String> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": "get_simple_data_table",
          "stream_id": streamId,
        },
      );

      if (response.statusCode == 200) {
        return await compute(_parseEpgListings, response.data);
      }

      return [];
    } catch (e) {
      debugPrint("Error Full EPG $streamId: $e");
      return [];
    }
  }


  /// Construct Catch-up URL
  ///
  /// Xtream Codes path-based timeshift format:
  /// /timeshift/user/pass/duration/start/stream_id.ts (or .m3u8)
  static String constructCatchUpUrl({
    required String baseUrl,
    required String username,
    required String password,
    required String streamId,
    required String startTimestamp, // Unix Timestamp (seconds)
    required String duration, // Minutes
  }) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    // Use stream_format from GetStorage if available, fallback to .ts for timeshift 
    // .m3u8 timeshift streams take a long time to buffer on many Xtream servers
    // because the server has to generate the HLS playlist on the fly.
    final format = GetStorage().read('stream_format') == 'm3u8' ? 'm3u8' : 'ts';

    // Convert Unix timestamp to YYYY-MM-DD:HH-MM format
    final ts = int.tryParse(startTimestamp);
    if (ts != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
      final formatted =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}:${dt.hour.toString().padLeft(2, '0')}-${dt.minute.toString().padLeft(2, '0')}';
      return "$cleanBase/timeshift/$username/$password/$duration/$formatted/$streamId.$format";
    }

    // Fallback
    return "$cleanBase/timeshift/$username/$password/$duration/$startTimestamp/$streamId.$format";
  }
}
