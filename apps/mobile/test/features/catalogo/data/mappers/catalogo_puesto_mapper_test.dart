import 'package:carrousel_app/features/catalogo/data/mappers/catalogo_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('puestoDesdeMapa', () {
    test('mapea un puesto activo con descripción', () {
      final puesto = puestoDesdeMapa({
        'id': 'p1',
        'empresa_id': 'e1',
        'codigo': 'OP',
        'nombre': 'Operador',
        'descripcion': 'Opera las atracciones.',
        'activo': true,
      });

      expect(puesto.id, 'p1');
      expect(puesto.empresaId, 'e1');
      expect(puesto.codigo, 'OP');
      expect(puesto.nombre, 'Operador');
      expect(puesto.descripcion, 'Opera las atracciones.');
      expect(puesto.activo, isTrue);
    });

    test('tolera descripción nula y activo ausente', () {
      final puesto = puestoDesdeMapa({
        'id': 'p2',
        'empresa_id': 'e1',
        'codigo': 'ADM',
        'nombre': 'Administrativo',
      });

      expect(puesto.descripcion, isNull);
      expect(puesto.activo, isTrue);
    });
  });
}
