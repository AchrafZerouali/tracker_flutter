import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/maintenance.dart';

final maintenanceRepositoryProvider = Provider(
  (ref) => MaintenanceRepository(),
);

class MaintenanceRepository {
  final _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _col =>
      _db.collection('users').doc(_uid).collection('maintenances');

  Future<void> addMaintenance(Maintenance m) => _col.doc(m.id).set(m.toJson());

  Stream<List<Maintenance>> getMaintenances(String vehicleId) => _col
      .where('vehicleId', isEqualTo: vehicleId)
      .orderBy('date', descending: true)
      .snapshots()
      .map(
        (snap) =>
            snap.docs
                .map(
                  (d) => Maintenance.fromJson(
                    d.data() as Map<String, dynamic>,
                    d.id,
                  ),
                )
                .toList(),
      );

  Stream<List<Maintenance>> getAllMaintenances() => _col.snapshots().map(
    (snap) =>
        snap.docs
            .map(
              (d) =>
                  Maintenance.fromJson(d.data() as Map<String, dynamic>, d.id),
            )
            .toList(),
  );
}
