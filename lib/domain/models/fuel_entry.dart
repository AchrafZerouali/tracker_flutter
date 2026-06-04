import 'package:cloud_firestore/cloud_firestore.dart';

class FuelEntry {
  final String id;
  final String vehicleId;
  final double liters;
  final double amount;
  final DateTime date;

  FuelEntry({
    required this.id,
    required this.vehicleId,
    required this.liters,
    required this.amount,
    required this.date,
  });

  factory FuelEntry.fromJson(Map<String, dynamic> json, String id) => FuelEntry(
    id: id,
    vehicleId: json['vehicleId'],
    liters: (json['liters'] as num).toDouble(),
    amount: (json['amount'] as num).toDouble(),
    date: (json['date'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    'vehicleId': vehicleId,
    'liters': liters,
    'amount': amount,
    'date': Timestamp.fromDate(date),
  };
}
