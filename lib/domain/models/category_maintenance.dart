class CategoryMaintenance {
  final String id;
  final String name;

  CategoryMaintenance({required this.id, required this.name});

  factory CategoryMaintenance.fromJson(Map<String, dynamic> json, String id) =>
      CategoryMaintenance(id: id, name: json['name']);

  Map<String, dynamic> toJson() => {'name': name};
}
