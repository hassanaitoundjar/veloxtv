part of '../api/api.dart';

class FavoriteLocale {
  /// Save Channel Live
  static Future<void> saveChannelLive(ChannelLive channel) async {
    final List<dynamic> list = await favoritesLocale.read("live") ?? [];
    
    // Check if already exists
    final index = list.indexWhere((element) => element['stream_id'] == channel.streamId);
    if (index == -1) {
      list.add(channel.toJson());
      await favoritesLocale.write("live", list);
    }
  }

  static Future<void> removeChannelLive(String streamId) async {
    final List<dynamic> list = await favoritesLocale.read("live") ?? [];
    list.removeWhere((element) => element['stream_id'] == streamId);
    await favoritesLocale.write("live", list);
  }

  static Future<List<ChannelLive>> getChannelLive() async {
    final List<dynamic> list = await favoritesLocale.read("live") ?? [];
    return list.map((e) => ChannelLive.fromJson(e)).toList();
  }

  static bool isLikedLive(String streamId) {
    final List<dynamic> list = favoritesLocale.read("live") ?? [];
    return list.any((element) => element['stream_id'] == streamId);
  }

  /// Save Movie
  static Future<void> saveMovie(ChannelMovie movie) async {
    final List<dynamic> list = await favoritesLocale.read("movie") ?? [];
    
    final index = list.indexWhere((element) => element['stream_id'] == movie.streamId);
    if (index == -1) {
      list.add(movie.toJson());
      await favoritesLocale.write("movie", list);
    }
  }

  static Future<void> removeMovie(String streamId) async {
    final List<dynamic> list = await favoritesLocale.read("movie") ?? [];
    list.removeWhere((element) => element['stream_id'] == streamId);
    await favoritesLocale.write("movie", list);
  }

  static Future<List<ChannelMovie>> getMovies() async {
    final List<dynamic> list = await favoritesLocale.read("movie") ?? [];
    return list.map((e) => ChannelMovie.fromJson(e)).toList();
  }

  static bool isLikedMovie(String streamId) {
    final List<dynamic> list = favoritesLocale.read("movie") ?? [];
    return list.any((element) => element['stream_id'] == streamId);
  }
  
  /// Save Series
  static Future<void> saveSeries(ChannelSerie serie) async {
    final List<dynamic> list = await favoritesLocale.read("series") ?? [];
    
    final index = list.indexWhere((element) => element['series_id'] == serie.seriesId);
    if (index == -1) {
      list.add(serie.toJson());
      await favoritesLocale.write("series", list);
    }
  }

  static Future<void> removeSeries(String seriesId) async {
    final List<dynamic> list = await favoritesLocale.read("series") ?? [];
    list.removeWhere((element) => element['series_id'] == seriesId);
    await favoritesLocale.write("series", list);
  }

  static Future<List<ChannelSerie>> getSeries() async {
    final List<dynamic> list = await favoritesLocale.read("series") ?? [];
    return list.map((e) => ChannelSerie.fromJson(e)).toList();
  }

  static bool isLikedSeries(String seriesId) {
    final List<dynamic> list = favoritesLocale.read("series") ?? [];
    return list.any((element) => element['series_id'] == seriesId);
  }
}
