import 'package:carrousel_app/features/jornada/data/mappers/jornada_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conserva la foto de la geocerca devuelta por Realtime', () {
    final jornada = jornadaDesdeMapa({
      'id': 'jornada-1',
      'empresa_id': 'empresa-id',
      'empleado_id': 'empleado-id',
      'parque_id': 'parque-1',
      'entrada_en': '2026-11-17T08:00:00.000Z',
      'entrada_dentro_geocerca': true,
      'entrada_parque_lat': 14.6349,
      'entrada_parque_lon': -90.5069,
      'entrada_parque_radio_metros': 100,
    });

    expect(jornada.entradaParqueLat, 14.6349);
    expect(jornada.entradaParqueLon, -90.5069);
    expect(jornada.entradaParqueRadioMetros, 100);
  });

  test('acepta jornadas históricas sin foto de geocerca', () {
    final jornada = jornadaDesdeMapa({
      'id': 'jornada-2',
      'empresa_id': 'empresa-id',
      'empleado_id': 'empleado-id',
      'parque_id': 'parque-1',
      'entrada_en': '2026-11-01T08:00:00.000Z',
    });

    expect(jornada.entradaParqueLat, isNull);
    expect(jornada.entradaParqueLon, isNull);
    expect(jornada.entradaParqueRadioMetros, isNull);
  });
}
