import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/home/dashboard_screen.dart';
import '../../presentation/home/add_vehicle_screen.dart';
import '../../presentation/home/fuel_entry_screen.dart';
import '../../presentation/home/maintenance_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
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
        builder:
            (context, state) =>
                FuelEntryScreen(vehicleId: state.pathParameters['vehicleId']!),
      ),
      GoRoute(
        path: '/maintenance/:vehicleId',
        builder:
            (context, state) => MaintenanceScreen(
              vehicleId: state.pathParameters['vehicleId']!,
            ),
      ),
    ],
  );
});
