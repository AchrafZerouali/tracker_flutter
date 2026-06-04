import 'package:cloud_firestore/cloud_firestore.dart';

class Maintenance {
  final String id;
  final String vehicleId;
  final String categoryId;
  final double amount;
  final String description;
  final DateTime date;

  Maintenance({
    required this.id,
    required this.vehicleId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json, String id) =>
      Maintenance(
        id: id,
        vehicleId: json['vehicleId'],
        categoryId: json['categoryId'],
        amount: (json['amount'] as num).toDouble(),
        description: json['description'],
        date: (json['date'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toJson() => {
    'vehicleId': vehicleId,
    'categoryId': categoryId,
    'amount': amount,
    'description': description,
    'date': Timestamp.fromDate(date),
  };
}
