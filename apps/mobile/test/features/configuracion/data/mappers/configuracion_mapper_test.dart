import 'package:carrousel_app/features/configuracion/data/mappers/configuracion_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('configuracionDesdeMapa', () {
    test('mapea zona horaria y umbral de GPS', () {
      final config = configuracionDesdeMapa({
        'id': 'e1',
        'nombre': 'Carrousel',
        'zona_horaria': 'America/Guatemala',
        'gps_precision_maxima_metros': 80,
      });

      expect(config.id, 'e1');
      expect(config.nombre, 'Carrousel');
      expect(config.zonaHoraria, 'America/Guatemala');
      expect(config.gpsPrecisionMaximaMetros, 80);
    });

    test('usa los valores por defecto cuando faltan columnas', () {
      final config = configuracionDesdeMapa({
        'id': 'e1',
        'nombre': 'Carrousel',
      });

      expect(config.zonaHoraria, 'America/Guatemala');
      expect(config.gpsPrecisionMaximaMetros, 100);
    });
  });
}
