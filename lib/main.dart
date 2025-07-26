import 'package:alfa_scout/presentation/blocs/pub/pub_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'presentation/theme/theme.dart';
import 'presentation/router/router.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/blocs/auth/auth_cubit.dart';
import 'services/theme_service.dart';
import 'package:alfa_scout/presentation/blocs/favorites/favorite_cubit.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return FutureBuilder<ThemeMode>(
      future: themeService.loadThemeMode(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit(themeService)..loadTheme()),
            BlocProvider(create: (_) => AuthCubit()),
            BlocProvider(create: (_) => PubCubit()),
            BlocProvider(create: (_) => FavoriteCubit()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'AlfaScout',
                routerConfig: appRouter,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeMode,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('it'),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
