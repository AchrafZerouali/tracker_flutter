import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/fuel_repository.dart';
import '../data/repositories/maintenance_repository.dart';
import '../data/repositories/vehicle_repository.dart';
import '../domain/models/category_maintenance.dart';
import '../domain/models/fuel_entry.dart';
import '../domain/models/maintenance.dart';
import '../domain/models/vehicle.dart';

final categoriesProvider = StreamProvider<List<CategoryMaintenance>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories();
});

bool _isCurrentMonth(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month;
}

final vehiclesProvider = StreamProvider<List<Vehicle>>(
  (ref) => ref.watch(vehicleRepositoryProvider).getVehicles(),
);

final fuelByVehicleProvider = StreamProvider.family<List<FuelEntry>, String>(
  (ref, vehicleId) =>
      ref.watch(fuelRepositoryProvider).getFuelEntries(vehicleId),
);

final maintenanceByVehicleProvider =
    StreamProvider.family<List<Maintenance>, String>(
  (ref, vehicleId) =>
      ref.watch(maintenanceRepositoryProvider).getMaintenances(vehicleId),
);

final totalFuelAmountProvider = StreamProvider<double>((ref) {
  return ref.watch(fuelRepositoryProvider).getAllFuelEntries().map(
        (entries) => entries
            .where((e) => _isCurrentMonth(e.date))
            .fold<double>(0, (sum, e) => sum + e.amount),
      );
});

final totalMaintenanceAmountProvider = StreamProvider<double>((ref) {
  return ref.watch(maintenanceRepositoryProvider).getAllMaintenances().map(
        (entries) => entries
            .where((e) => _isCurrentMonth(e.date))
            .fold<double>(0, (sum, e) => sum + e.amount),
      );
});

class VehicleMonthlyFuelStats {
  final String vehicleId;
  final String name;
  final double liters;
  final double amount;

  const VehicleMonthlyFuelStats({
    required this.vehicleId,
    required this.name,
    required this.liters,
    required this.amount,
  });
}

final allFuelEntriesProvider = StreamProvider<List<FuelEntry>>(
  (ref) => ref.watch(fuelRepositoryProvider).getAllFuelEntries(),
);

final vehicleMonthlyFuelStatsProvider =
    Provider<AsyncValue<List<VehicleMonthlyFuelStats>>>((ref) {
  final vehicles = ref.watch(vehiclesProvider);
  final fuel = ref.watch(allFuelEntriesProvider);

  return vehicles.when(
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
    data: (vehicleList) => fuel.when(
      loading: () => const AsyncValue.loading(),
      error: AsyncValue.error,
      data: (fuelList) => AsyncValue.data(
        vehicleList.map((vehicle) {
          final monthEntries = fuelList.where(
            (e) => e.vehicleId == vehicle.id && _isCurrentMonth(e.date),
          );
          return VehicleMonthlyFuelStats(
            vehicleId: vehicle.id,
            name: vehicle.name,
            liters: monthEntries.fold<double>(0, (s, e) => s + e.liters),
            amount: monthEntries.fold<double>(0, (s, e) => s + e.amount),
          );
        }).toList(),
      ),
    ),
  );
});
