import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_flutter/domain/models/vehicle.dart';

void main() {
  test('Vehicle sérialise correctement depuis JSON', () {
    final vehicle = Vehicle.fromJson(
      {'name': 'Renault', 'plate': '123-A-45'},
      'abc',
    );

    expect(vehicle.id, 'abc');
    expect(vehicle.name, 'Renault');
    expect(vehicle.plate, '123-A-45');
    expect(vehicle.toJson(), {'name': 'Renault', 'plate': '123-A-45'});
  });
}
