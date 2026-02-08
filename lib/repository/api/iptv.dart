part of 'api.dart';

class IpTvApi {
  /// Categories
  Future<List<CategoryModel>> getCategories(String type) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        debugPrint("User is Null");
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
      debugPrint("Error $type: $e");
      return [];
    }
  }

  /// Live Channels
  Future<List<ChannelLive>> getLiveChannels(String catyId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        return [];
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<List<dynamic>> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": "get_live_streams",
          "category_id": catyId
        },
      );

      if (response.statusCode == 200) {
        final json = response.data ?? [];
        final list = json.map((e) => ChannelLive.fromJson(e)).toList();
        return list;
      }

      return [];
    } catch (e) {
      debugPrint("Error Channel $catyId: $e");
      return [];
    }
  }

  /// Movie Channels
  Future<List<ChannelMovie>> getMovieChannels(String catyId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        return [];
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<List<dynamic>> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": "get_vod_streams",
          "category_id": catyId
        },
      );

      if (response.statusCode == 200) {
        final json = response.data ?? [];
        final list = json.map((e) => ChannelMovie.fromJson(e)).toList();
        return list;
      }

      return [];
    } catch (e) {
      debugPrint("Error Movie Channel $catyId: $e");
      return [];
    }
  }

  /// Series Channels
  Future<List<ChannelSerie>> getSeriesChannels(String catyId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        return [];
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<List<dynamic>> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": "get_series",
          "category_id": catyId
        },
      );

      if (response.statusCode == 200) {
        final json = response.data ?? [];
        final list = json.map((e) => ChannelSerie.fromJson(e)).toList();
        return list;
      }

      return [];
    } catch (e) {
      debugPrint("Error Series Channel $catyId: $e");
      return [];
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
        },
      );

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.data ?? "");
        if (jsonMap['epg_listings'] != null) {
          final List<dynamic> json = jsonMap['epg_listings'];
          final list = json.map((e) => EpgModel.fromJson(e)).toList();
          return list;
        }
      }

      return [];
    } catch (e) {
      debugPrint("Error EPG $streamId: $e");
      return [];
    }
  }
}
