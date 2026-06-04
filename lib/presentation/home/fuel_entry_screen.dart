import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/firestore_ids.dart';
import '../../core/providers.dart';
import '../../data/repositories/fuel_repository.dart';
import '../../domain/models/fuel_entry.dart';

class FuelEntryScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  const FuelEntryScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<FuelEntryScreen> createState() => _FuelEntryScreenState();
}

class _FuelEntryScreenState extends ConsumerState<FuelEntryScreen> {
  final _litersController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _litersController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addEntry() async {
    if (_litersController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Remplir tous les champs')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final entry = FuelEntry(
        id: newFirestoreId(),
        vehicleId: widget.vehicleId,
        liters: double.parse(_litersController.text),
        amount: double.parse(_amountController.text),
        date: DateTime.now(),
      );
      await ref.read(fuelRepositoryProvider).addFuelEntry(entry);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Plein enregistré !')));
        _litersController.clear();
        _amountController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final fuelEntries = ref.watch(fuelByVehicleProvider(widget.vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plein de carburant'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _litersController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Litres',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_gas_station),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Montant (MAD)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Enregistrer'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Historique',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: fuelEntries.when(
                data:
                    (list) =>
                        list.isEmpty
                            ? const Center(child: Text('Aucune entrée'))
                            : ListView.builder(
                              itemCount: list.length,
                              itemBuilder:
                                  (_, i) => Card(
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.local_gas_station,
                                        color: Colors.blue,
                                      ),
                                      title: Text('${list[i].liters} L'),
                                      subtitle: Text(
                                        '${list[i].date.day}/${list[i].date.month}/${list[i].date.year}',
                                      ),
                                      trailing: Text(
                                        '${list[i].amount} MAD',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                            ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erreur: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
