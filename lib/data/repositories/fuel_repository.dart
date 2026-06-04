import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fuel_entry.dart';

final fuelRepositoryProvider = Provider((ref) => FuelRepository());

class FuelRepository {
  final _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _col =>
      _db.collection('users').doc(_uid).collection('fuel_entries');

  Future<void> addFuelEntry(FuelEntry entry) =>
      _col.doc(entry.id).set(entry.toJson());

  Stream<List<FuelEntry>> getFuelEntries(String vehicleId) => _col
      .where('vehicleId', isEqualTo: vehicleId)
      .snapshots()
      .map(
        (snap) =>
            snap.docs
                .map(
                  (d) => FuelEntry.fromJson(
                    d.data() as Map<String, dynamic>,
                    d.id,
                  ),
                )
                .toList(),
      );

  Stream<List<FuelEntry>> getAllFuelEntries() => _col.snapshots().map(
    (snap) =>
        snap.docs
            .map(
              (d) => FuelEntry.fromJson(d.data() as Map<String, dynamic>, d.id),
            )
            .toList(),
  );
}
