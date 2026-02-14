part of 'api.dart';

/// Parses M3U/M3U8 playlist files and converts them into
/// CategoryModel and ChannelLive objects.
class M3uParser {
  /// Parsed channels grouped by group-title
  static Future<Map<String, List<ChannelLive>>> parseFromUrl(
      String m3uUrl) async {
    try {
      final response = await _dio.get<String>(m3uUrl);
      if (response.statusCode == 200 && response.data != null) {
        return _parseContent(response.data!);
      }
      return {};
    } catch (e) {
      debugPrint("M3U Parse Error: $e");
      return {};
    }
  }

  /// Parse raw M3U content into grouped channels
  static Map<String, List<ChannelLive>> _parseContent(String content) {
    final Map<String, List<ChannelLive>> groups = {};
    final lines = content.split('\n');

    String? currentName;
    String? currentLogo;
    String? currentGroup;
    String? currentId;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXTINF:')) {
        // Parse EXTINF line
        // Format: #EXTINF:-1 tvg-id="id" tvg-name="name" tvg-logo="logo" group-title="group",Channel Name
        currentId = _extractAttribute(line, 'tvg-id');
        currentName = _extractAttribute(line, 'tvg-name');
        currentLogo = _extractAttribute(line, 'tvg-logo');
        currentGroup =
            _extractAttribute(line, 'group-title') ?? 'Uncategorized';

        // Fallback: channel name after the last comma
        if (currentName == null || currentName.isEmpty) {
          final commaIndex = line.lastIndexOf(',');
          if (commaIndex != -1 && commaIndex < line.length - 1) {
            currentName = line.substring(commaIndex + 1).trim();
          }
        }
      } else if (line.isNotEmpty &&
          !line.startsWith('#') &&
          currentName != null) {
        // This is the URL line
        final channel = ChannelLive(
          num: groups.values.fold(0, (sum, list) => sum + list.length) + 1,
          name: currentName,
          streamIcon: currentLogo,
          streamId: currentId ?? '${currentName.hashCode}',
          directSource: line, // Store the direct URL
          categoryId: currentGroup,
          epgChannelId: currentId,
        );

        groups.putIfAbsent(currentGroup!, () => []);
        groups[currentGroup]!.add(channel);

        // Reset
        currentName = null;
        currentLogo = null;
        currentGroup = null;
        currentId = null;
      }
    }

    return groups;
  }

  /// Extract an attribute value from an EXTINF line
  static String? _extractAttribute(String line, String attribute) {
    final regex = RegExp('$attribute="([^"]*)"');
    final match = regex.firstMatch(line);
    return match?.group(1);
  }

  /// Convert parsed groups into CategoryModel list
  static List<CategoryModel> groupsToCategories(
      Map<String, List<ChannelLive>> groups) {
    int id = 1;
    return groups.keys.map((groupName) {
      return CategoryModel(
        categoryId: (id++).toString(),
        categoryName: groupName,
        parentId: 0,
      );
    }).toList();
  }

  /// Get all channels for a specific group name
  static List<ChannelLive> getChannelsForGroup(
      Map<String, List<ChannelLive>> groups, String groupName) {
    return groups[groupName] ?? [];
  }

  /// Validate if a URL is a valid M3U file
  static Future<bool> validateM3uUrl(String url) async {
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!.trim();
        return data.startsWith('#EXTM3U') || data.contains('#EXTINF:');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
