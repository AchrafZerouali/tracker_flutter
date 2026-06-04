import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/home/add_vehicle_screen.dart';
import '../../presentation/home/dashboard_screen.dart';
import '../../presentation/home/fuel_entry_screen.dart';
import '../../presentation/home/maintenance_screen.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<User?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final refresh = _AuthRefreshNotifier(authRepo.authStateChanges);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final onLogin = state.matchedLocation == '/login';

      if (user == null && !onLogin) return '/login';
      if (user != null && onLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/add-vehicle',
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/fuel-entry/:vehicleId',
        builder: (context, state) => FuelEntryScreen(
          vehicleId: state.pathParameters['vehicleId']!,
        ),
      ),
      GoRoute(
        path: '/maintenance/:vehicleId',
        builder: (context, state) => MaintenanceScreen(
          vehicleId: state.pathParameters['vehicleId']!,
        ),
      ),
    ],
  );
});
