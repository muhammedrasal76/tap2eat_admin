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
import 'screens/auth/login_screen.dart';
import 'screens/canteen_admin/dashboard_screen.dart';
import 'screens/canteen_admin/menu_management_screen.dart';
import 'screens/master_admin/dashboard_screen.dart' as master;
import 'screens/shared/not_authorized_screen.dart';

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
      initialLocation: Routes.login,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == Routes.login;

        if (!isLoggedIn && !isLoggingIn) {
          return Routes.login;
        }

        if (isLoggedIn && isLoggingIn) {
          // Role-based redirect after login
          if (authProvider.userRole == 'canteen_admin') {
            return Routes.canteenDashboard;
          } else if (authProvider.userRole == 'master_admin') {
            return Routes.masterDashboard;
          } else {
            return Routes.notAuthorized;
          }
        }

        return null;
      },
      routes: [
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
          path: Routes.notAuthorized,
          builder: (context, state) => const NotAuthorizedScreen(),
        ),
      ],
    );
  }
}
