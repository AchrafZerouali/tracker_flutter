import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/providers.dart';
import '../../data/repositories/maintenance_repository.dart';
import '../../domain/models/maintenance.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  const MaintenanceScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _addMaintenance() async {
    if (_descController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Remplir tous les champs')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final m = Maintenance(
        id: FirebaseFirestore.instance.collection('tmp').doc().id,
        vehicleId: widget.vehicleId,
        categoryId: 'general',
        amount: double.parse(_amountController.text),
        description: _descController.text.trim(),
        date: _selectedDate,
      );
      await ref.read(maintenanceRepositoryProvider).addMaintenance(m);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maintenance enregistrée !')),
        );
        _descController.clear();
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
    final maintenances = ref.watch(
      maintenanceByVehicleProvider(widget.vehicleId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Changer date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addMaintenance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
              child: maintenances.when(
                data:
                    (list) =>
                        list.isEmpty
                            ? const Center(child: Text('Aucune maintenance'))
                            : ListView.builder(
                              itemCount: list.length,
                              itemBuilder:
                                  (_, i) => Card(
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.build,
                                        color: Colors.orange,
                                      ),
                                      title: Text(list[i].description),
                                      subtitle: Text(
                                        '${list[i].date.day}/${list[i].date.month}/${list[i].date.year}',
                                      ),
                                      trailing: Text(
                                        '${list[i].amount} MAD',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
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
