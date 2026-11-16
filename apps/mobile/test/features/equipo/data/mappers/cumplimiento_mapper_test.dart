import 'package:carrousel_app/features/equipo/data/mappers/cumplimiento_mapper.dart';
import 'package:carrousel_app/features/equipo/domain/entities/cumplimiento_jornada.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cumplimientoDesdeMapa', () {
    test('interpreta incidencias conocidas y descarta las desconocidas', () {
      final jornada = cumplimientoDesdeMapa({
        'id': 'j1',
        'empresa_id': 'e1',
        'empleado_id': 'u1',
        'empleado': 'Ana Pérez',
        'entrada_en': '2026-11-10T15:00:00Z',
        'salida_en': '2026-11-10T23:00:00Z',
        'abierta': false,
        'horas': 8,
        'incidencias': ['llegada_tarde', 'parque_distinto', 'otra_cosa', null],
        'hora_entrada': '09:00:00',
        'hora_salida': '17:00:00',
        'minutos_tarde': 15,
        'minutos_temprano': 0,
        'parque_nombre': 'Parque Central',
      });

      expect(jornada.empleado, 'Ana Pérez');
      expect(jornada.abierta, isFalse);
      expect(jornada.puedeAjustar, isTrue);
      expect(jornada.incidencias, [
        TipoIncidencia.llegadaTarde,
        TipoIncidencia.parqueDistinto,
      ]);
      expect(jornada.horaEntradaProgramada, '09:00');
      expect(jornada.horaSalidaProgramada, '17:00');
      expect(jornada.minutosTarde, 15);
      expect(jornada.parqueNombre, 'Parque Central');
    });

    test('una jornada abierta no se puede ajustar', () {
      final jornada = cumplimientoDesdeMapa({
        'id': 'j1',
        'empresa_id': 'e1',
        'empleado_id': 'u1',
        'entrada_en': '2026-11-10T15:00:00Z',
        'abierta': true,
        'horas': 0,
        'incidencias': <String>[],
      });

      expect(jornada.abierta, isTrue);
      expect(jornada.puedeAjustar, isFalse);
      expect(jornada.empleado, 'Empleado');
      expect(jornada.incidencias, isEmpty);
      expect(jornada.horaEntradaProgramada, isNull);
    });
  });
}
