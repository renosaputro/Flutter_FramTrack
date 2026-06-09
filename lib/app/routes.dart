import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/crop/presentation/screens/crop_list_screen.dart';
import '../features/crop/presentation/screens/crop_detail_screen.dart';
import '../features/crop/presentation/screens/add_crop_screen.dart';
import '../features/crop/presentation/screens/harvest_screen.dart';
import '../features/crop/presentation/screens/add_activity_screen.dart';
import '../features/harvest_history/presentation/screens/harvest_history_screen.dart';
import '../features/reminder/presentation/screens/reminder_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/settings/presentation/screens/dark_mode_screen.dart';
import '../features/settings/presentation/screens/manage_fields_screen.dart';
import '../features/settings/presentation/screens/notification_settings_screen.dart';
import '../features/settings/presentation/screens/language_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import 'shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [

    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),

    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (_, _, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', pageBuilder: (_, _) => const NoTransitionPage(child: DashboardScreen())),
        GoRoute(path: '/crops', pageBuilder: (_, _) => const NoTransitionPage(child: CropListScreen())),
        GoRoute(path: '/reminders', pageBuilder: (_, _) => const NoTransitionPage(child: ReminderScreen())),
        GoRoute(path: '/profile', pageBuilder: (_, _) => const NoTransitionPage(child: ProfileScreen())),
      ],
    ),

    GoRoute(path: '/crop/add', builder: (_, _) => const AddCropScreen()),
    GoRoute(
      path: '/crop/:id',
      builder: (_, state) => CropDetailScreen(cropId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/crop/:id/harvest',
      builder: (_, state) => HarvestScreen(cropId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/crop/:id/activity',
      builder: (_, state) => AddActivityScreen(
        cropId: state.pathParameters['id'] ?? '',
        cropNama: state.uri.queryParameters['nama'] ?? 'Tanaman',
      ),
    ),

    GoRoute(path: '/harvest-history', builder: (_, _) => const HarvestHistoryScreen()),

    GoRoute(path: '/profile/edit', builder: (_, _) => const EditProfileScreen()),
    GoRoute(path: '/settings/dark-mode', builder: (_, _) => const DarkModeScreen()),
    GoRoute(path: '/settings/fields', builder: (_, _) => const ManageFieldsScreen()),
    GoRoute(path: '/settings/notifications', builder: (_, _) => const NotificationSettingsScreen()),
    GoRoute(path: '/settings/language', builder: (_, _) => const LanguageScreen()),
    GoRoute(path: '/settings/about', builder: (_, _) => const AboutScreen()),
  ],
);
