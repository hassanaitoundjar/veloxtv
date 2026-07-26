part of '../screens.dart';

// --- Particle System ---
class _Particle {
  double x;
  double y;
  double dx;
  double dy;
  double radius;

  _Particle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.radius,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final paint = Paint()..color = Colors.white.withOpacity(0.4);
    final linePaint = Paint()..strokeWidth = 1.0;

    for (var p in particles) {
      p.x += p.dx;
      p.y += p.dy;

      if (p.x < 0 || p.x > size.width) p.dx = -p.dx;
      if (p.y < 0 || p.y > size.height) p.dy = -p.dy;
    }

    final connectionDistance = size.width > 800 ? 150.0 : 100.0;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = particles[i].x - particles[j].x;
        final dy = particles[i].y - particles[j].y;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < connectionDistance) {
          linePaint.color =
              Colors.white.withOpacity((1 - dist / connectionDistance) * 0.3);
          canvas.drawLine(
            Offset(particles[i].x, particles[i].y),
            Offset(particles[j].x, particles[j].y),
            linePaint,
          );
        }
      }
    }

    for (var p in particles) {
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
// --- End Particle System ---

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _logoScale;
  late Animation<double> _opacity;
  
  final List<_Particle> _particles = [];
  bool _particlesInitialized = false;

  void _navigate(String route) {
    Future.delayed(const Duration(seconds: 2)).then((_) {
      Get.offNamed(route);
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
    ]).animate(_controller);

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isTv(context)) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
      final disclaimerAccepted =
          GetStorage().read('disclaimer_accepted') ?? false;
      if (!disclaimerAccepted) {
        Get.offNamed(screenDisclaimer);
        return;
      }

      final deviceType = GetStorage().read(kPrefDeviceType);
      if (deviceType == null) {
        Get.offNamed(screenDeviceSelection);
        return;
      }

      final Map<String, dynamic>? userMap = GetStorage().read('user');
      if (userMap != null) {}

      context.read<AuthBloc>().add(AuthGetUser());
    });
  }

  void _initParticles(Size size) {
    if (_particlesInitialized) return;
    _particlesInitialized = true;
    final rand = Random();
    final particleCount = isTv(context) ? 60 : 30;
    for (int i = 0; i < particleCount; i++) {
      _particles.add(_Particle(
        x: rand.nextDouble() * size.width,
        y: rand.nextDouble() * size.height,
        dx: (rand.nextDouble() - 0.5) * 1.5,
        dy: (rand.nextDouble() - 0.5) * 1.5,
        radius: rand.nextDouble() * 2 + 1.5,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _initParticles(size);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Keep dark background
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _navigate(screenHome);
          } else if (state is AuthProfilesLoaded) {
            _navigate(screenProfiles);
          } else if (state is AuthFailed) {
            _navigate(screenIntro);
          }
        },
        child: Stack(
          children: [
            // Particle Background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter:
                        _ParticlePainter(_particles, _particleController.value),
                  );
                },
              ),
            ),

            // Logo overlay
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _opacity.value,
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: isTv(context) ? 55.w : 80.w,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Left Text
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                "VANTO",
                                style: GoogleFonts.rubik(
                                  color: kAccentColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 56,
                                  letterSpacing: 2,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Right side (TV shape with IPTV)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // TV Screen
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 24, right: 24, top: 12, bottom: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: kAccentColor, width: 5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "IPTV",
                                        style: GoogleFonts.rubik(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 52,
                                          letterSpacing: 4,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // 4 dots
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                            4,
                                            (index) => Container(
                                                  width: 6,
                                                  height: 6,
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 3),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: kAccentColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                )),
                                      ),
                                    ],
                                  ),
                                ),
                                // TV Stand neck
                                Container(
                                  width: 50,
                                  height: 10,
                                  color: kAccentColor,
                                ),
                                // TV Stand Base plate
                                Container(
                                  width: 120,
                                  height: 6,
                                  color: kAccentColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: 40,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
