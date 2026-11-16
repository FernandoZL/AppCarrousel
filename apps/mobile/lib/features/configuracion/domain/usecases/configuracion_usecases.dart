import 'package:carrousel_app/features/configuracion/domain/entities/configuracion_empresa.dart';
import 'package:carrousel_app/features/configuracion/domain/repositories/configuracion_repository.dart';

class CargarConfiguracion {
  const CargarConfiguracion(this._repo);

  final ConfiguracionRepository _repo;

  Future<ConfiguracionEmpresa> call(String empresaId) =>
      _repo.cargar(empresaId);
}

class GuardarConfiguracion {
  const GuardarConfiguracion(this._repo);

  final ConfiguracionRepository _repo;

  Future<void> call({
    required String empresaId,
    required String zonaHoraria,
    required int gpsPrecisionMaximaMetros,
  }) => _repo.guardar(
    empresaId: empresaId,
    zonaHoraria: zonaHoraria,
    gpsPrecisionMaximaMetros: gpsPrecisionMaximaMetros,
  );
}
