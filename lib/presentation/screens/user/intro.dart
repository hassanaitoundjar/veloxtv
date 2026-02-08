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
              flex: 3,
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
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Watch Your Favorite\nTV Channels & Movies",
                      textAlign: TextAlign.center,
                      style: Get.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "The best streaming experience on your device.\nLogin with your Xtream Codes credentials.",
                      textAlign: TextAlign.center,
                      style: Get.textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 80.w,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(screenRegister);
                        },
                        child: Text("Get Started"),
                      ),
                    ),
                    const SizedBox(height: 20),
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
