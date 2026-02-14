part of 'widgets.dart';

class AppBarWelcome extends StatefulWidget {
  final String expiration;

  const AppBarWelcome({super.key, required this.expiration});

  @override
  State<AppBarWelcome> createState() => _AppBarWelcomeState();
}

class _AppBarWelcomeState extends State<AppBarWelcome> {
  late Timer _timer;
  late String _currentTime;
  late String _currentDate;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('hh:mm a').format(now);
      _currentDate = DateFormat('MMM d, yyyy').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Row(
        children: [
          Image.asset(kIconSplash, width: 40, height: 40),
          const SizedBox(width: 12),
          Text(kAppName, style: Get.textTheme.headlineMedium),
          Container(
            height: 30,
            width: 1,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          const Spacer(),

          // CENTER: Clock and Date
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_currentTime,
                  style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: kColorPrimary)),
              Container(
                  width: 1,
                  height: 14,
                  color: Colors.white54,
                  margin: const EdgeInsets.symmetric(horizontal: 10)),
              Text(_currentDate,
                  style: Get.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white70)),
            ],
          ),

          const Spacer(),

          // RIGHT: Expiration and Settings
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Expiration: ${formatExpiration(widget.expiration)}",
                style: Get.textTheme.bodySmall
                    ?.copyWith(color: kColorTextSecondary),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => Get.toNamed(screenSettings),
                icon: const Icon(FontAwesomeIcons.gear),
                tooltip: "Settings",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardWelcomeTv extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final VoidCallback onTap;
  final bool autoFocus;

  const CardWelcomeTv({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onTap: onTap,
      autoFocus: autoFocus,
      scale: 1.05,
      child: Container(
        decoration: kDecorCard.copyWith(color: kColorCard),
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, width: 8.w, height: 8.w),
              SizedBox(height: 2.h),
              Text(title, style: Get.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Get.textTheme.bodyMedium
                    ?.copyWith(color: kColorTextSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardWelcomeSetting extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  final bool autoFocus;

  const CardWelcomeSetting({
    super.key,
    required this.title,
    required this.icon,
    this.autoFocus = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onTap: onTap,
      autoFocus: autoFocus,
      scale: 1.02,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: kDecorCard.copyWith(
          color: kColorCardLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: kDecorIconCircle,
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(title, style: Get.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
