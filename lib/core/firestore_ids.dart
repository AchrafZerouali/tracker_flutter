import 'package:cloud_firestore/cloud_firestore.dart';

String newFirestoreId() =>
    FirebaseFirestore.instance.collection('_ids').doc().id;
