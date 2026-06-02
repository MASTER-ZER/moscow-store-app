import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moscow_store/app.dart';
import 'package:moscow_store/screens/mobile/splash_screen.dart';
import 'package:moscow_store/screens/mobile/home_screen.dart';
import 'package:moscow_store/screens/mobile/games_screen.dart';
import 'package:moscow_store/screens/mobile/game_detail_screen.dart';
import 'package:moscow_store/screens/mobile/order_screen.dart';
import 'package:moscow_store/screens/mobile/my_orders_screen.dart';
import 'package:moscow_store/screens/mobile/profile_screen.dart';
import 'package:moscow_store/screens/mobile/login_screen.dart';
import 'package:moscow_store/screens/mobile/register_screen.dart';
import 'package:moscow_store/screens/mobile/wallet_screen.dart';
import 'package:moscow_store/screens/admin/dashboard_screen.dart';
import 'package:moscow_store/screens/admin/games_admin_screen.dart';
import 'package:moscow_store/screens/admin/packages_admin_screen.dart';
import 'package:moscow_store/screens/admin/orders_admin_screen.dart';
import 'package:moscow_store/screens/admin/accounts_admin_screen.dart';
import 'package:moscow_store/screens/admin/customers_admin_screen.dart';
import 'package:moscow_store/screens/admin/settings_admin_screen.dart';
import 'package:moscow_store/models/game.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String games = '/games';
  static const String gameDetail = '/games/:slug';
  static const String order = '/order';
  static const String myOrders = '/my-orders';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';
  static const String wallet = '/wallet';
  static const String adminDashboard = '/admin';
  static const String adminGames = '/admin/games';
  static const String adminPackages = '/admin/packages';
  static const String adminOrders = '/admin/orders';
  static const String adminAccounts = '/admin/accounts';
  static const String adminCustomers = '/admin/customers';
  static const String adminSettings = '/admin/settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (_, __) => const SplashScreen()),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: home, builder: (_, __) => const HomeScreen()),
          GoRoute(path: games, builder: (_, __) => const GamesScreen()),
          GoRoute(
            path: gameDetail,
            builder: (_, state) {
              final game = state.extra as Game;
              return GameDetailScreen(game: game);
            },
          ),
          GoRoute(
            path: order,
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>;
              return OrderScreen(
                game: extra['game'] as Game,
                package: extra['package'],
              );
            },
          ),
          GoRoute(path: myOrders, builder: (_, __) => const MyOrdersScreen()),
          GoRoute(path: profile, builder: (_, __) => const ProfileScreen()),
          GoRoute(path: login, builder: (_, __) => const LoginScreen()),
          GoRoute(path: register, builder: (_, __) => const RegisterScreen()),
          GoRoute(path: wallet, builder: (_, __) => const WalletScreen()),
        ],
      ),
      GoRoute(path: adminDashboard, builder: (_, __) => const DashboardScreen()),
      GoRoute(path: adminGames, builder: (_, __) => const GamesAdminScreen()),
      GoRoute(path: adminPackages, builder: (_, __) => const PackagesAdminScreen()),
      GoRoute(path: adminOrders, builder: (_, __) => const OrdersAdminScreen()),
      GoRoute(path: adminAccounts, builder: (_, __) => const AccountsAdminScreen()),
      GoRoute(path: adminCustomers, builder: (_, __) => const CustomersAdminScreen()),
      GoRoute(path: adminSettings, builder: (_, __) => const SettingsAdminScreen()),
    ],
  );
}
