import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tap2eat_admin/firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/break_slots_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/canteen_admin/dashboard_screen.dart';
import 'screens/canteen_admin/menu_management_screen.dart';
import 'screens/master_admin/dashboard_screen.dart' as master;
import 'screens/master_admin/break_slots_management_screen.dart';
import 'screens/shared/not_authorized_screen.dart';
import 'screens/shared/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Note: You'll need to run `flutterfire configure` to generate firebase_options.dart
  await Firebase.initializeApp(
         options: DefaultFirebaseOptions.currentPlatform,
       );

  runApp(const Tap2EatAdminApp());
}

class Tap2EatAdminApp extends StatelessWidget {
  const Tap2EatAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => BreakSlotsProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Tap2Eat Admin',
            theme: AppTheme.darkTheme,
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: Routes.splash,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isInitialized = authProvider.isInitialized;
        final isLoggedIn = authProvider.isAuthenticated;
        final currentPath = state.matchedLocation;

        // Phase 1: Show splash while initializing auth state
        if (!isInitialized) {
          return currentPath == Routes.splash ? null : Routes.splash;
        }

        // Phase 2: After initialization, handle authentication
        if (!isLoggedIn) {
          // Not logged in - redirect to login unless already there
          return currentPath == Routes.login ? null : Routes.login;
        }

        // Phase 3: User is logged in - handle redirects from splash/login
        if (currentPath == Routes.splash || currentPath == Routes.login) {
          // Redirect from splash/login to role-specific dashboard
          if (authProvider.userRole == 'canteen_admin') {
            return Routes.canteenDashboard;
          } else if (authProvider.userRole == 'master_admin') {
            return Routes.masterDashboard;
          } else {
            return Routes.notAuthorized;
          }
        }

        // Allow navigation to requested route
        return null;
      },
      routes: [
        GoRoute(
          path: Routes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.canteenDashboard,
          builder: (context, state) => const CanteenDashboardScreen(),
        ),
        GoRoute(
          path: Routes.canteenMenu,
          builder: (context, state) => const MenuManagementScreen(),
        ),
        GoRoute(
          path: Routes.masterDashboard,
          builder: (context, state) => const master.MasterDashboardScreen(),
        ),
        GoRoute(
          path: Routes.masterBreakSlots,
          builder: (context, state) => const BreakSlotsManagementScreen(),
        ),
        GoRoute(
          path: Routes.notAuthorized,
          builder: (context, state) => const NotAuthorizedScreen(),
        ),
      ],
    );
  }
}
