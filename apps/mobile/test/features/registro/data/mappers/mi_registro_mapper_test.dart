import 'package:carrousel_app/features/registro/data/mappers/mi_registro_mapper.dart';
import 'package:carrousel_app/features/registro/domain/entities/mi_registro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('miRegistroDesdeMapa', () {
    test('mapea una solicitud rechazada con su motivo', () {
      final registro = miRegistroDesdeMapa({
        'id': 'r1',
        'empresa_id': 'e1',
        'email': 'ana@example.com',
        'nombre_completo': 'Ana Pérez',
        'estado': 'rechazado',
        'creado_en': '2026-11-10T12:00:00Z',
        'motivo_rechazo': 'El nombre no coincide con la planilla.',
        'revisado_en': '2026-11-11T12:00:00Z',
      });

      expect(registro.id, 'r1');
      expect(registro.empresaId, 'e1');
      expect(registro.email, 'ana@example.com');
      expect(registro.nombreCompleto, 'Ana Pérez');
      expect(registro.estado, EstadoMiRegistro.rechazado);
      expect(registro.rechazado, isTrue);
      expect(registro.motivoRechazo, isNotNull);
      expect(registro.revisadoEn, isNotNull);
    });

    test('una solicitud pendiente no tiene revisión ni motivo', () {
      final registro = miRegistroDesdeMapa({
        'id': 'r2',
        'empresa_id': 'e1',
        'email': 'ana@example.com',
        'nombre_completo': 'Ana Pérez',
        'estado': 'pendiente',
        'creado_en': '2026-11-10T12:00:00Z',
      });

      expect(registro.estado, EstadoMiRegistro.pendiente);
      expect(registro.pendiente, isTrue);
      expect(registro.motivoRechazo, isNull);
      expect(registro.revisadoEn, isNull);
    });
  });
}
