import 'package:carrousel_app/features/registro/domain/entities/mi_registro.dart';
import 'package:carrousel_app/features/registro/domain/repositories/registro_repository.dart';

class SolicitarRegistro {
  const SolicitarRegistro(this._repo);

  final RegistroRepository _repo;

  Future<String> call({
    required String codigoEmpresa,
    required String nombreCompleto,
    required String puesto,
  }) => _repo.solicitar(
    codigoEmpresa: codigoEmpresa,
    nombreCompleto: nombreCompleto,
    puesto: puesto,
  );
}

class ConsultarMiRegistro {
  const ConsultarMiRegistro(this._repo);

  final RegistroRepository _repo;

  Future<MiRegistro?> call() => _repo.miRegistro();
}
