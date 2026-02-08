import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'core/helpers/helpers.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/categories/channels_bloc.dart';
import 'logic/blocs/categories/live_caty_bloc.dart';
import 'logic/blocs/categories/movie_caty_bloc.dart';
import 'logic/blocs/categories/series_caty_bloc.dart';
import 'logic/cubits/favorites/favorites_cubit.dart';
import 'logic/cubits/settings/settings_cubit.dart';
import 'presentation/screens/screens.dart';
import 'repository/api/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await GetStorage.init("favorites");

  // Set orientation for TVs
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Repository Providers could be here if needed
    final api = IpTvApi();
    final authRepo = AuthApi();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(authRepo)),
        BlocProvider(create: (context) => LiveCatyBloc(api)),
        BlocProvider(create: (context) => MovieCatyBloc(api)),
        BlocProvider(create: (context) => SeriesCatyBloc(api)),
        BlocProvider(create: (context) => ChannelsBloc(api)),
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => FavoritesCubit()),
      ],
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return GetMaterialApp(
            title: kAppName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeData(context),
            initialRoute: screenSplash,
            getPages: [
              GetPage(name: screenSplash, page: () => const SplashScreen()),
              GetPage(
                  name: screenDeviceSelection,
                  page: () => const DeviceSelectionScreen()),
              GetPage(name: screenIntro, page: () => const IntroScreen()),
              GetPage(name: screenWelcome, page: () => const WelcomeScreen()),
              GetPage(name: screenRegister, page: () => const RegisterScreen()),
              GetPage(
                  name: screenRegisterTv, page: () => const RegisterUserTv()),
              GetPage(
                  name: screenLiveCategories,
                  page: () => const LiveCategoriesScreen()),
              GetPage(
                  name: screenMovieChannels,
                  page: () => const MovieChannelsScreen()),
              GetPage(
                  name: screenMovieDetails,
                  page: () => const MovieDetailsScreen()),
              GetPage(
                  name: screenSeriesCategories,
                  page: () => const SeriesCategoriesScreen()),
              GetPage(
                  name: screenSeriesChannels,
                  page: () => const SeriesChannelsScreen()),
              GetPage(
                  name: screenSeriesDetails,
                  page: () => const SeriesDetailsScreen()),
              GetPage(name: screenSettings, page: () => const SettingsScreen()),
              GetPage(
                  name: screenFavourite, page: () => const FavoriteScreen()),
              GetPage(name: screenCatchUp, page: () => const CatchUpScreen()),
              GetPage(
                  name: screenPlayer, page: () => const VideoPlayerScreen()),
            ],
          );
        },
      ),
    );
  }
}
