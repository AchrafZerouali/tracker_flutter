import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/category_maintenance.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

class CategoryRepository {
  final _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _col =>
      _db.collection('users').doc(_uid).collection('categories');

  static const _defaults = [
    ('vidange', 'Vidange'),
    ('pneus', 'Pneus'),
    ('freins', 'Freins'),
    ('general', 'Général'),
  ];

  Future<void> ensureDefaultCategories() async {
    for (final (id, name) in _defaults) {
      final doc = await _col.doc(id).get();
      if (!doc.exists) {
        await _col.doc(id).set(CategoryMaintenance(id: id, name: name).toJson());
      }
    }
  }

  Stream<List<CategoryMaintenance>> getCategories() => _col.snapshots().map(
        (snap) => snap.docs
            .map(
              (d) => CategoryMaintenance.fromJson(
                d.data() as Map<String, dynamic>,
                d.id,
              ),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name)),
      );
}
