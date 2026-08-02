part of '../api/api.dart';

class RecentLocale {
  static String _key(String userId) => "recent_live_$userId";

  /// Save Channel Live as recent, keeping maximum 10 items.
  static Future<void> saveRecentLive(ChannelLive channel, String userId) async {
    final key = _key(userId);
    final List<dynamic> list =
        (recentLocale.read(key) as List<dynamic>?) ?? [];

    // Remove if already exists so we can move it to the top
    list.removeWhere((element) => element['stream_id'] == channel.streamId);

    // Insert at the beginning
    list.insert(0, channel.toJson());

    // Keep only the last 10 channels
    if (list.length > 10) {
      list.removeLast();
    }

    await recentLocale.write(key, list);
  }

  static Future<void> removeRecentLive(String streamId, String userId) async {
    final key = _key(userId);
    final List<dynamic> list =
        (recentLocale.read(key) as List<dynamic>?) ?? [];
    list.removeWhere((element) => element['stream_id'] == streamId);
    await recentLocale.write(key, list);
  }

  static Future<void> clearRecentLive(String userId) async {
    final key = _key(userId);
    await recentLocale.remove(key);
  }

  static Future<List<ChannelLive>> getRecentLive(String userId) async {
    final key = _key(userId);
    List<dynamic>? list = recentLocale.read(key) as List<dynamic>?;

    list ??= [];

    return list.map((e) => ChannelLive.fromJson(e)).toList();
  }
}
