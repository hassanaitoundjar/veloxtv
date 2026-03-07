part of '../screens.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  bool _isTesting = false;
  double _progress = 0.0;
  double _speedMbps = 0.0;
  String _status = "Ready";

  // Use a reliable CDN file for testing (Cloudflare 10MB)
  final String _testUrl = "https://speed.cloudflare.com/__down?bytes=10000000";
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _startTest() async {
    setState(() {
      _isTesting = true;
      _progress = 0.0;
      _speedMbps = 0.0;
      _status = "Connecting...";
      _cancelToken = CancelToken();
    });

    final dio = Dio();
    final stopwatch = Stopwatch()..start();

    int downloadedBytes = 0;

    try {
      await dio.get(
        _testUrl,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          downloadedBytes = received;

          final duration = stopwatch.elapsedMilliseconds / 1000.0; // Seconds
          if (duration > 0) {
            // bits per second
            final bps = (received * 8) / duration;
            // Mbps
            final mbps = bps / 1000000.0;

            setState(() {
              _progress = (total > 0) ? (received / total) : 0.0;
              _speedMbps = mbps;
              _status = "Downloading...";
            });
          }
        },
      );

      final totalDuration = stopwatch.elapsedMilliseconds / 1000.0;
      final finalMbps = (downloadedBytes * 8) / totalDuration / 1000000.0;

      setState(() {
        _isTesting = false;
        _progress = 1.0;
        _speedMbps = finalMbps; // Ensure we show the final average
        _status = "Test Completed";
      });
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        setState(() => _status = "Cancelled");
      } else {
        setState(() => _status = "Error: ${e.message}");
      }
      setState(() => _isTesting = false);
    } catch (e) {
      setState(() {
        _status = "Error occurred";
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: const Text("Internet Speed Test"),
        backgroundColor: kColorCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          width: 80.w,
          constraints: BoxConstraints(maxHeight: 80.h),
          decoration: kDecorCard,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gauge / Circle
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 15,
                          backgroundColor: Colors.white10,
                          color: _getSpeedColor(_speedMbps),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _speedMbps.toStringAsFixed(1),
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "Mbps",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  _status,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 24),

                if (!_isTesting)
                  ElevatedButton.icon(
                    onPressed: _startTest,
                    icon: const Icon(Icons.speed),
                    label: const Text("Start Speed Test"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kColorPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      _cancelToken?.cancel();
                      setState(() {
                        _isTesting = false;
                        _status = "Cancelled";
                      });
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text("Stop Test"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kColorError,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSpeedColor(double mbps) {
    if (mbps < 5) return Colors.red;
    if (mbps < 20) return Colors.orange;
    if (mbps < 50) return Colors.yellow;
    if (mbps < 100) return Colors.lightGreen;
    return kColorPrimary;
  }
}
