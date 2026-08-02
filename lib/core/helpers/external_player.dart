part of 'helpers.dart';

/// Manages external player preferences and launching.
///
/// Supported modes:
/// - 'builtin'   → Always use the built-in media_kit player
/// - 'external'  → Always launch in an external app (VLC, MX Player, etc.)
/// - 'ask'       → Show a dialog each time asking the user to choose
class ExternalPlayerService {
  static const String _storageKey = 'player_mode';
  static final _storage = GetStorage('settings');

  /// Get the current player mode preference.
  static String get playerMode => _storage.read(_storageKey) ?? 'builtin';

  /// Set the player mode preference.
  static void setPlayerMode(String mode) {
    _storage.write(_storageKey, mode);
  }

  /// Launch a stream URL in an external video player via Android Intent.
  ///
  /// On Android, this sends an ACTION_VIEW intent with MIME type video/*
  /// which triggers the system's app chooser (VLC, MX Player, etc.)
  /// On non-Android platforms, falls back to url_launcher.
  static Future<void> launchExternal(String url, {String? title}) async {
    try {
      if (GetPlatform.isAndroid) {
        final intent = AndroidIntent(
          action: 'action_view',
          data: url,
          type: 'video/*',
          arguments: <String, dynamic>{
            // VLC extras
            'title': title ?? 'Stream',
            // MX Player extras
            'decode_mode': 2, // HW+
          },
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } else {
        // Fallback for desktop/other platforms
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('External player launch error: $e');
      // Show a snackbar if no external player is installed
      Get.snackbar(
        'No External Player Found',
        'Please install VLC, MX Player, or another video player app.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kColorError.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Shows a bottom sheet dialog asking the user to pick Built-in or External player.
  ///
  /// Returns `true` if the user chose external, `false` for built-in,
  /// or `null` if dismissed.
  static Future<bool?> showPlayerChoiceDialog(BuildContext context) async {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: kColorCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kColorBorder.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Player',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'How do you want to play this?',
                style: TextStyle(color: kColorTextSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FocusableCard(
                      autoFocus: true,
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kColorPrimary, kColorPrimaryDark],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.play_circle_filled,
                                color: Colors.white, size: 36),
                            const SizedBox(height: 8),
                            Text('Built-in Player',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FocusableCard(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.open_in_new_rounded,
                                color: Colors.white70, size: 36),
                            const SizedBox(height: 8),
                            Text('External Player',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// Central decision function: Based on user preference, either open the
  /// built-in player, launch external, or ask.
  ///
  /// [context]       — BuildContext for showing dialogs
  /// [url]           — The stream URL to play
  /// [title]         — Title to display in the player
  /// [openBuiltIn]   — Callback to open the built-in MediaKitPlayerScreen
  /// [onPlay]        — Optional callback triggered when playback actually starts (e.g. for recents)
  ///
  /// If the preference is 'external', the built-in callback is never called.
  /// If 'ask', a dialog is shown first.
  static Future<void> play({
    required BuildContext context,
    required String url,
    required String title,
    required VoidCallback openBuiltIn,
    VoidCallback? onPlay,
  }) async {
    final mode = playerMode;

    if (mode == 'external') {
      onPlay?.call();
      await launchExternal(url, title: title);
    } else if (mode == 'ask') {
      final choice = await showPlayerChoiceDialog(context);
      if (choice == null) return; // Dismissed
      onPlay?.call();
      if (choice) {
        await launchExternal(url, title: title);
      } else {
        openBuiltIn();
      }
    } else {
      // 'builtin' (default)
      onPlay?.call();
      openBuiltIn();
    }
  }
}
