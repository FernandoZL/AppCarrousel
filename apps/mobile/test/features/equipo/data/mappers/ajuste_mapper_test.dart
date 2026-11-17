import 'package:carrousel_app/features/equipo/data/mappers/ajuste_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ajusteJornadaDesdeMapa', () {
    test('mapea el historial con fechas ISO y motivo', () {
      final ajuste = ajusteJornadaDesdeMapa({
        'id': 'a1',
        'jornada_id': 'j1',
        'empleado_id': 'e1',
        'ajustado_por': 'admin-1',
        'motivo': 'Se corrigió la hora de entrada reportada por el lector.',
        'entrada_en_anterior': '2026-11-17T13:00:00.000Z',
        'salida_en_anterior': '2026-11-17T21:00:00.000Z',
        'entrada_en_nueva': '2026-11-17T13:15:00.000Z',
        'salida_en_nueva': '2026-11-17T21:05:00.000Z',
        'creado_en': '2026-11-17T22:00:00.000Z',
      });

      expect(ajuste.id, 'a1');
      expect(ajuste.jornadaId, 'j1');
      expect(ajuste.empleadoId, 'e1');
      expect(ajuste.ajustadoPor, 'admin-1');
      expect(
        ajuste.motivo,
        'Se corrigió la hora de entrada reportada por el lector.',
      );
      expect(ajuste.entradaEnAnterior, DateTime.utc(2026, 11, 17, 13));
      expect(ajuste.salidaEnAnterior, DateTime.utc(2026, 11, 17, 21));
      expect(ajuste.entradaEnNueva, DateTime.utc(2026, 11, 17, 13, 15));
      expect(ajuste.salidaEnNueva, DateTime.utc(2026, 11, 17, 21, 5));
      expect(ajuste.creadoEn, DateTime.utc(2026, 11, 17, 22));
    });

    test('acepta fechas ya parseadas', () {
      final fecha = DateTime.utc(2026, 11, 17, 12);
      final ajuste = ajusteJornadaDesdeMapa({
        'id': 'a2',
        'jornada_id': 'j2',
        'empleado_id': 'e1',
        'ajustado_por': 'admin-1',
        'motivo': 'Corrección de cierre de jornada.',
        'entrada_en_anterior': fecha,
        'salida_en_anterior': fecha,
        'entrada_en_nueva': fecha,
        'salida_en_nueva': fecha,
        'creado_en': fecha,
      });

      expect(ajuste.creadoEn, fecha);
    });
  });
}
