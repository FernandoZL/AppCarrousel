import 'package:carrousel_app/features/equipo/data/mappers/registro_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registroPendienteDesdeMapa conserva el puesto declarado', () {
    final registro = registroPendienteDesdeMapa({
      'id': 'r1',
      'empresa_id': 'empresa-id',
      'usuario_id': 'usuario-id',
      'email': 'ana@carrousel.test',
      'nombre_completo': 'Ana Pérez',
      'puesto': 'Técnico de juegos',
      'estado': 'pendiente',
      'creado_en': '2026-11-17T12:00:00Z',
    });

    expect(registro.puesto, 'Técnico de juegos');
    expect(registro.pendiente, isTrue);
  });
}
