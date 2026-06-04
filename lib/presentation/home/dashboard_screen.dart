import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../data/repositories/auth_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    final totalFuel = ref.watch(totalFuelAmountProvider);
    final totalMaintenance = ref.watch(totalMaintenanceAmountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats 70% / 30%
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Gasoil',
                    percent: '70%',
                    color: Colors.blue,
                    icon: Icons.local_gas_station,
                    amount: totalFuel.whenOrNull(data: (v) => v) ?? 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Maintenance',
                    percent: '30%',
                    color: Colors.orange,
                    icon: Icons.build,
                    amount: totalMaintenance.whenOrNull(data: (v) => v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Mes Véhicules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Liste des véhicules
            vehicles.when(
              data:
                  (list) =>
                      list.isEmpty
                          ? const Center(child: Text('Aucun véhicule ajouté'))
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder:
                                (_, i) => Card(
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.directions_car,
                                      color: Colors.blue,
                                    ),
                                    title: Text(list[i].name),
                                    subtitle: Text(list[i].plate),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.local_gas_station,
                                            color: Colors.blue,
                                          ),
                                          onPressed:
                                              () => context.push(
                                                '/fuel-entry/${list[i].id}',
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.build,
                                            color: Colors.orange,
                                          ),
                                          onPressed:
                                              () => context.push(
                                                '/maintenance/${list[i].id}',
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur: $e'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-vehicle'),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter véhicule'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String percent;
  final Color color;
  final IconData icon;
  final double amount;

  const _StatCard({
    required this.label,
    required this.percent,
    required this.color,
    required this.icon,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              percent,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${amount.toStringAsFixed(2)} MAD',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
