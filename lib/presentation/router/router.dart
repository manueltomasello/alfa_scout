import 'package:alfa_scout/presentation/screens/details/details_loader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alfa_scout/presentation/screens/animation/logo_alfa.dart';
import 'package:alfa_scout/presentation/router/path.dart';
import 'package:alfa_scout/presentation/screens/details/details_screen.dart';
import 'package:alfa_scout/presentation/screens/home/home_screen.dart';
import 'package:alfa_scout/presentation/screens/favorites/favorites_screen.dart';
import 'package:alfa_scout/presentation/screens/profile/profile_screen.dart';
import 'package:alfa_scout/presentation/screens/settings/settings_screen.dart';
import 'package:alfa_scout/presentation/screens/auth/login_screen.dart';
import 'package:alfa_scout/presentation/screens/auth/registration_screen.dart';
import 'package:alfa_scout/presentation/screens/auth/verification_screen.dart';
import 'package:alfa_scout/presentation/screens/shell/app_shell.dart';
import 'package:alfa_scout/domain/models/pub_auto.dart';
import'package:alfa_scout/presentation/screens/pub/add_pub_screen.dart';
import 'package:alfa_scout/presentation/screens/xstats/stats_screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: AppPaths.login,
  redirect: (context, state) {
  final user = FirebaseAuth.instance.currentUser;
  final isLoggingIn = state.fullPath == AppPaths.login;
  final isRegistering = state.fullPath == AppPaths.registration;
  final isVerifying = state.fullPath == AppPaths.verifyEmail;

  // Se l'utente non è loggato, lascialo navigare tra login e registrazione
  if (user == null) {
    if (!isLoggingIn && !isRegistering) {
      return AppPaths.login;
    }
    return null;
  }

  // Se è loggato ma NON ha verificato l'email
  if (!user.emailVerified && !isVerifying) {
    return AppPaths.verifyEmail;
  }

  // Tutto ok, nessun redirect
    return null;
 },
  routes: [
    GoRoute(
      path: AppPaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppPaths.addPub,
      builder: (context, state) => const AddPubScreen(),
    ),
    GoRoute(
      path: AppPaths.registration,
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: AppPaths.verifyEmail,
      builder: (context, state) => const EmailVerificationScreen(),
    ),
    GoRoute(
      path: AppPaths.welcome,
      builder: (context, state) => const WelcomeAnimationScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppPaths.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppPaths.favorites,
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: AppPaths.stats,
          builder: (context, state) => const StatsScreen(),
    ),
        GoRoute(
          path: AppPaths.profile,
          builder: (context, state) => const UserProfileScreen(),
        ),
        GoRoute(
          path: AppPaths.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppPaths.detailsLoader,
          builder: (context, state) => DetailsLoaderScreen(pubId: state.pathParameters['id']!),
),
      ],
    ),
    GoRoute(
      path: AppPaths.details,
      builder: (context, state) {
        final pub = state.extra as Pub;
        return DetailsScreen(pub: pub);
      },
    ),
    GoRoute(
      path: AppPaths.editPub,
      builder: (context, state) {
        final pub = state.extra as Pub;
        return AddPubScreen(initialPub: pub);
      },
    ),

  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('Pagina non trovata')),
  ),
);
