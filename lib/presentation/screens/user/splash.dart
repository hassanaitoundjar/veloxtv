part of '../screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _navigate(String route) {
    Future.delayed(const Duration(seconds: 2)).then((_) {
      Get.offNamed(route);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isTv(context)) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
      // Check if device type is selected
      final deviceType = GetStorage().read(kPrefDeviceType);

      if (deviceType == null) {
        Get.offNamed(screenDeviceSelection);
        return;
      }

      // Check if logged in
      final Map<String, dynamic>? userMap = GetStorage().read('user');
      if (userMap != null) {
        // You might use this later or trigger auto-login
      }

      // Initialize settings and auth check
      context.read<SettingsCubit>().getSettingsCode();
      context.read<AuthBloc>().add(AuthGetUser());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Preload categories here if needed
            _navigate(screenWelcome);
          } else if (state is AuthFailed) {
            if (isTv(context)) {
              _navigate(screenRegisterTv);
            } else {
              _navigate(screenIntro);
            }
          }
        },
        child: Container(
          width: 100.w,
          height: 100.h,
          decoration: kDecorBackground,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                kIconSplash,
                width: 20.w,
                height: 20.w,
              ),
              const SizedBox(height: 20),
              Text(
                kAppName,
                style: Get.textTheme.displayMedium,
              ),
              const SizedBox(height: 40),
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
      ),
    );
  }
}
