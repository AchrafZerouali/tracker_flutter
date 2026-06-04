import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/maintenance_repository.dart';
import '../../domain/models/category_maintenance.dart';
import '../../domain/models/maintenance.dart';

final categoriesProvider = StreamProvider<List<CategoryMaintenance>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});

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
  DateTime? _filterFrom;
  DateTime? _filterTo;
  String _selectedCategoryId = 'general';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryRepositoryProvider).ensureDefaultCategories();
    });
  }

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

  Future<void> _pickFilterFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _filterFrom = picked);
  }

  Future<void> _pickFilterTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _filterTo = picked);
  }

  void _clearFilters() => setState(() {
        _filterFrom = null;
        _filterTo = null;
      });

  List<Maintenance> _applyDateFilter(List<Maintenance> list) {
    return list.where((m) {
      if (_filterFrom != null && m.date.isBefore(_filterFrom!)) return false;
      if (_filterTo != null) {
        final endOfDay = DateTime(
          _filterTo!.year,
          _filterTo!.month,
          _filterTo!.day,
          23,
          59,
          59,
        );
        if (m.date.isAfter(endOfDay)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _addMaintenance() async {
    if (_descController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplir tous les champs')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final m = Maintenance(
        id: FirebaseFirestore.instance.collection('tmp').doc().id,
        vehicleId: widget.vehicleId,
        categoryId: _selectedCategoryId,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final maintenances = ref.watch(
      maintenanceByVehicleProvider(widget.vehicleId),
    );
    final categories = ref.watch(categoriesProvider);

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
            categories.when(
              data: (cats) {
                if (cats.isEmpty) return const SizedBox.shrink();
                return DropdownButtonFormField<String>(
                  value: cats.any((c) => c.id == _selectedCategoryId)
                      ? _selectedCategoryId
                      : cats.first.id,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: cats
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCategoryId = v);
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
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
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enregistrer'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Historique — filtre par date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFilterFrom,
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(
                      _filterFrom == null
                          ? 'Du'
                          : '${_filterFrom!.day}/${_filterFrom!.month}/${_filterFrom!.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFilterTo,
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(
                      _filterTo == null
                          ? 'Au'
                          : '${_filterTo!.day}/${_filterTo!.month}/${_filterTo!.year}',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Effacer filtres',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: maintenances.when(
                data: (list) {
                  final filtered = _applyDateFilter(list);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        list.isEmpty
                            ? 'Aucune maintenance'
                            : 'Aucun résultat pour cette période',
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.build,
                          color: Colors.orange,
                        ),
                        title: Text(filtered[i].description),
                        subtitle: Text(
                          '${filtered[i].date.day}/${filtered[i].date.month}/${filtered[i].date.year}'
                          ' — ${filtered[i].categoryId}',
                        ),
                        trailing: Text(
                          '${filtered[i].amount} MAD',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
