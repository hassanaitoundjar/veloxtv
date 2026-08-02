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

    final paint = Paint()..color = Colors.white.withValues(alpha: 0.4);
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
              Colors.white.withValues(alpha: (1 - dist / connectionDistance) * 0.3);
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
    // Scale particle count with screen area — small phones get ~20, 4K TVs get ~80.
    final double sf = (size.shortestSide / 600.0).clamp(0.5, 2.0);
    final int particleCount = (30 * sf).round().clamp(20, 80);
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
    final mq = MediaQuery.of(context);
    final size = mq.size;
    _initParticles(size);

    // Auto-adaptive scale factor — same approach as Home screen.
    // Anchor at 600dp. Clamp between 0.5 (small phone) and 1.8 (4K TV).
    final double sf = (size.shortestSide / 600.0).clamp(0.5, 1.8);

    // Logo takes up a portion of the width — scales naturally with sf.
    // On a small phone it fills ~70%, on a large TV it stays at ~40%.
    final double logoWidthFraction = (0.70 / sf).clamp(0.35, 0.80);
    final double logoWidth = (size.width * logoWidthFraction).clamp(180.0, 450.0);
    final double loadingSize = (40.0 * sf).clamp(28.0, 72.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- Glowing V Monogram ---
                        SizedBox(
                          width: logoWidth,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: 280,
                              height: 240,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer glow ring
                                  Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFF265eb4).withValues(alpha: 0.3),
                                          const Color(0xFF265eb4).withValues(alpha: 0.0),
                                        ],
                                        stops: const [0.3, 1.0],
                                      ),
                                    ),
                                  ),
                                  // Inner circle background
                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.05),
                                      border: Border.all(
                                        color: const Color(0xFF265eb4).withValues(alpha: 0.6),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  // Streaming scan lines — left
                                  Positioned(
                                    left: 0,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: List.generate(5, (i) {
                                        final widths = [40.0, 28.0, 18.0, 28.0, 40.0];
                                        final opacities = [0.15, 0.25, 0.40, 0.25, 0.15];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: Container(
                                            width: widths[i],
                                            height: 2,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(1),
                                              color: kAccentColor.withValues(alpha: opacities[i]),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  // Streaming scan lines — right
                                  Positioned(
                                    right: 0,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: List.generate(5, (i) {
                                        final widths = [40.0, 28.0, 18.0, 28.0, 40.0];
                                        final opacities = [0.15, 0.25, 0.40, 0.25, 0.15];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: Container(
                                            width: widths[i],
                                            height: 2,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(1),
                                              color: kAccentColor.withValues(alpha: opacities[i]),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  // The bold gradient "V"
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFF4A90E2),
                                        Color(0xFF265eb4),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ).createShader(bounds),
                                    child: Text(
                                      "V",
                                      style: GoogleFonts.rubik(
                                        fontSize: 110,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.0,
                                        shadows: [
                                          Shadow(
                                            color: const Color(0xFF265eb4).withValues(alpha: 0.8),
                                            blurRadius: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: (16.0 * sf).clamp(8.0, 28.0)),
                        // Brand name
                        Text(
                          "V A N T O",
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: (28.0 * sf).clamp(16.0, 48.0),
                            letterSpacing: (8.0 * sf).clamp(4.0, 16.0),
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: (6.0 * sf).clamp(4.0, 12.0)),
                        // Subtitle
                        Text(
                          "IPTV PLAYER",
                          style: GoogleFonts.rubik(
                            color: kAccentColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w300,
                            fontSize: (13.0 * sf).clamp(9.0, 22.0),
                            letterSpacing: (6.0 * sf).clamp(3.0, 12.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: (60.0 * sf).clamp(24.0, 100.0)),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: loadingSize,
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
