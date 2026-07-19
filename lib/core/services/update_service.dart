import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../presentation/widgets/widgets.dart';

class UpdateService {
  // Replace with the actual URL where you will host your version.json
  // Example version.json structure:
  // {
  //   "version": "1.0.2",
  //   "download_url": "https://vantoplayer.com/downloads/vanto_player_v1.0.2.apk",
  //   "release_notes": "Added external player support, fixed EPG bugs."
  // }
  
  static const String updateUrl = "https://vantoplayer.com/api/version.json";

  static Future<void> checkForUpdates(BuildContext context,
      {bool showNoUpdateMessage = false}) async {
    try {
      final dio = Dio();
      // Added a timeout so the app doesn't hang if the URL is unreachable
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get(updateUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            response.data is String ? jsonDecode(response.data) : response.data;

        final String latestVersion = data['version'] ?? "1.0.0";
        final String downloadUrl = data['download_url'] ?? "";
        final String releaseNotes =
            data['release_notes'] ?? "Bug fixes and performance improvements.";
        final bool isMandatory = data['mandatory'] == true;

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;

        // Simple version string comparison (assuming Semantic Versioning like 1.0.1)
        if (_isUpdateAvailable(currentVersion, latestVersion)) {
          if (context.mounted) {
            _showUpdateDialog(
                context, latestVersion, releaseNotes, downloadUrl, isMandatory);
          }
        } else if (showNoUpdateMessage) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Your app is up to date!")),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
      if (showNoUpdateMessage && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to check for updates: $e")),
        );
      }
    }
  }

  static bool _isUpdateAvailable(String currentVersion, String latestVersion) {
    List<int> currentParts =
        currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts =
        latestVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Ensure both have at least 3 parts
    while (currentParts.length < 3) currentParts.add(0);
    while (latestParts.length < 3) latestParts.add(0);

    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, String version,
      String releaseNotes, String downloadUrl, bool isMandatory) {
    showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Update Available",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Version $version is now available.",
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              const Text("Release Notes:",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(releaseNotes, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            if (!isMandatory)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Later",
                    style: TextStyle(color: Colors.white54)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                if (!isMandatory) Navigator.pop(dialogContext);
                _downloadAndInstall(context, downloadUrl, version);
              },
              child: const Text("Update Now",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _downloadAndInstall(
      BuildContext context, String url, String version) async {
    // Prepare download path
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    String savePath = "${dir.path}/vanto_player_update_$version.apk";

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext progressContext) {
          return DownloadProgressDialog(url: url, savePath: savePath);
        },
      );
    }
  }
}

class DownloadProgressDialog extends StatefulWidget {
  final String url;
  final String savePath;

  const DownloadProgressDialog(
      {super.key, required this.url, required this.savePath});

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _progress = 0;
  String _status = "Downloading...";
  final CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      final dio = Dio();
      await dio.download(
        widget.url,
        widget.savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
              _status =
                  "Downloading... ${(_progress * 100).toStringAsFixed(0)}%";
            });
          }
        },
      );

      setState(() {
        _status = "Download Complete. Installing...";
      });

      // Install the APK
      final result = await OpenFilex.open(widget.savePath);
      if (result.type != ResultType.done) {
        setState(() {
          _status = "Failed to install: ${result.message}";
        });
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (CancelToken.isCancel(e as DioException)) {
        debugPrint("Download cancelled");
      } else {
        setState(() {
          _status = "Download failed: $e";
        });
      }
    }
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Updating App", style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_status, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: _progress),
        ],
      ),
      actions: [
        if (_status.contains("failed") || _status.contains("cancelled"))
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }
}
