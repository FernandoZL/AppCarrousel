import 'package:carrousel_app/features/configuracion/domain/entities/configuracion_empresa.dart';

ConfiguracionEmpresa configuracionDesdeMapa(Map<String, dynamic> map) =>
    ConfiguracionEmpresa(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      zonaHoraria: map['zona_horaria'] as String? ?? 'America/Guatemala',
      gpsPrecisionMaximaMetros:
          (map['gps_precision_maxima_metros'] as num?)?.toInt() ?? 100,
    );
