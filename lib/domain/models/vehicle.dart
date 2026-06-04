class Vehicle {
  final String id;
  final String name;
  final String plate;

  Vehicle({required this.id, required this.name, required this.plate});

  factory Vehicle.fromJson(Map<String, dynamic> json, String id) =>
      Vehicle(id: id, name: json['name'], plate: json['plate']);

  Map<String, dynamic> toJson() => {'name': name, 'plate': plate};
}
