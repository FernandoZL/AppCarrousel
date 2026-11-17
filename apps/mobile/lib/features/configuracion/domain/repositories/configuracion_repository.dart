import 'package:carrousel_app/features/configuracion/domain/entities/configuracion_empresa.dart';

/// Configuración que el administrador puede ajustar en su propia empresa.
abstract class ConfiguracionRepository {
  Future<ConfiguracionEmpresa> cargar(String empresaId);

  Future<void> guardar({
    required String empresaId,
    required String zonaHoraria,
    required int gpsPrecisionMaximaMetros,
  });
}
