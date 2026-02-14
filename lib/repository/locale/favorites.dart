part of '../api/api.dart';

class FavoriteLocale {
  static String _key(String type, String userId) => "${type}_$userId";

  /// Save Channel Live
  static Future<void> saveChannelLive(
      ChannelLive channel, String userId) async {
    final key = _key("live", userId);
    final List<dynamic> list = await favoritesLocale.read(key) ?? [];

    // Check if already exists
    final index =
        list.indexWhere((element) => element['stream_id'] == channel.streamId);
    if (index == -1) {
      list.add(channel.toJson());
      await favoritesLocale.write(key, list);
    }
  }

  static Future<void> removeChannelLive(String streamId, String userId) async {
    final key = _key("live", userId);
    final List<dynamic> list = await favoritesLocale.read(key) ?? [];
    list.removeWhere((element) => element['stream_id'] == streamId);
    await favoritesLocale.write(key, list);
  }

  static Future<void> clearLive(String userId) async {
    final key = _key("live", userId);
    await favoritesLocale.remove(key);
  }

  static Future<List<ChannelLive>> getChannelLive(String userId) async {
    final key = _key("live", userId);
    List<dynamic>? list = await favoritesLocale.read(key);

    // Migration Logic
    if (list == null) {
      final legacy = await favoritesLocale.read("live");
      if (legacy != null) {
        list = legacy;
        await favoritesLocale.write(key, list);
        await favoritesLocale.remove("live");
      } else {
        list = [];
      }
    }

    return list?.map((e) => ChannelLive.fromJson(e)).toList() ?? [];
  }

  static bool isLikedLive(String streamId, String userId) {
    final key = _key("live", userId);
    final List<dynamic> list = favoritesLocale.read(key) ?? [];
    return list.any((element) => element['stream_id'] == streamId);
  }

  /// Save Movie
  static Future<void> saveMovie(ChannelMovie movie, String userId) async {
    final key = _key("movie", userId);
    final List<dynamic> list = await favoritesLocale.read(key) ?? [];

    final index =
        list.indexWhere((element) => element['stream_id'] == movie.streamId);
    if (index == -1) {
      list.add(movie.toJson());
      await favoritesLocale.write(key, list);
    }
  }

  static Future<void> removeMovie(String streamId, String userId) async {
    final key = _key("movie", userId);
    final List<dynamic> list = await favoritesLocale.read(key) ?? [];
    list.removeWhere((element) => element['stream_id'] == streamId);
    await favoritesLocale.write(key, list);
  }

  static Future<void> clearMovies(String userId) async {
    final key = _key("movie", userId);
    await favoritesLocale.remove(key);
  }

  static Future<List<ChannelMovie>> getMovies(String userId) async {
    final key = _key("movie", userId);
    List<dynamic>? list = await favoritesLocale.read(key);

    // Migration Logic
    if (list == null) {
      final legacy = await favoritesLocale.read("movie");
      if (legacy != null) {
        list = legacy;
        await favoritesLocale.write(key, list);
        await favoritesLocale.remove("movie");
      } else {
        list = [];
      }
    }

    return list?.map((e) => ChannelMovie.fromJson(e)).toList() ?? [];
  }

  static bool isLikedMovie(String streamId, String userId) {
    final key = _key("movie", userId);
    final List<dynamic> list = favoritesLocale.read(key) ?? [];
    return list.any((element) => element['stream_id'] == streamId);
  }

  /// Save Series
  static Future<void> saveSeries(ChannelSerie serie, String userId) async {
    final key = _key("series", userId);
    final List<dynamic> list = await favoritesLocale.read(key) ?? [];

    final index =
        list.indexWhere((element) => element['series_id'] == serie.seriesId);
    if (index == -1) {
      list.add(serie.toJson());
      await favoritesLocale.write(key, list);
    }
  }

  static Future<void> removeSeries(String seriesId, String userId) async {
    final key = _key("series", userId);
    final List<dynamic> list = await favoritesLocale.read(key) ?? [];
    list.removeWhere((element) => element['series_id'] == seriesId);
    await favoritesLocale.write(key, list);
  }

  static Future<void> clearSeries(String userId) async {
    final key = _key("series", userId);
    await favoritesLocale.remove(key);
  }

  static Future<List<ChannelSerie>> getSeries(String userId) async {
    final key = _key("series", userId);
    List<dynamic>? list = await favoritesLocale.read(key);

    // Migration Logic
    if (list == null) {
      final legacy = await favoritesLocale.read("series");
      if (legacy != null) {
        list = legacy;
        await favoritesLocale.write(key, list);
        await favoritesLocale.remove("series");
      } else {
        list = [];
      }
    }

    return list?.map((e) => ChannelSerie.fromJson(e)).toList() ?? [];
  }

  static bool isLikedSeries(String seriesId, String userId) {
    final key = _key("series", userId);
    final List<dynamic> list = favoritesLocale.read(key) ?? [];
    return list.any((element) => element['series_id'] == seriesId);
  }
}
