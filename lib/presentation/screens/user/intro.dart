part of '../screens.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Column(
          children: [
            Expanded(
              flex: Device.screenType == ScreenType.mobile
                  ? 3
                  : 3, // Reduced image height on mobile
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(kImageIntro),
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        kColorBackground,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: Device.screenType == ScreenType.mobile
                  ? 5
                  : 2, // More space for content
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical:
                        Device.screenType == ScreenType.mobile ? 10.0 : 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Watch Your Favorite\nTV Channels & Movies",
                      textAlign: TextAlign.center,
                      style: Get.textTheme.displaySmall?.copyWith(
                        fontSize: Device.screenType == ScreenType.mobile
                            ? 20.sp
                            : null, // Slightly smaller
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10), // Reduced from 16
                    Text(
                      "The best streaming experience on your device.\nLogin with your Xtream Codes credentials.",
                      textAlign: TextAlign.center,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontSize: Device.screenType == ScreenType.mobile
                            ? 14.sp
                            : null, // Slightly smaller
                        color: kColorTextSecondary,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width:
                          Device.screenType == ScreenType.mobile ? 90.w : 60.w,
                      height: 50, // Reduced from 55
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(screenRegister);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kColorPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text("Get Started",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10), // Reduced from 20
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
