import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/vehicle.dart';

final vehicleRepositoryProvider = Provider((ref) => VehicleRepository());

class VehicleRepository {
  final _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _col =>
      _db.collection('users').doc(_uid).collection('vehicles');

  Future<void> addVehicle(Vehicle v) => _col.doc(v.id).set(v.toJson());

  Stream<List<Vehicle>> getVehicles() => _col.snapshots().map(
    (snap) =>
        snap.docs
            .map(
              (d) => Vehicle.fromJson(d.data() as Map<String, dynamic>, d.id),
            )
            .toList(),
  );
}
