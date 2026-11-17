import 'package:carrousel_app/features/registro/domain/entities/mi_registro.dart';

/// Contrato del alta propia con código de empresa. La implementación concreta
/// vive en `data`.
abstract class RegistroRepository {
  /// Crea la solicitud de alta y devuelve su identificador. La cuenta debe
  /// tener una sesión autenticada; el rol final lo fija el administrador.
  Future<String> solicitar({
    required String codigoEmpresa,
    required String nombreCompleto,
    required String puesto,
  });

  /// Última solicitud propia, o null si todavía no se ha solicitado el alta.
  Future<MiRegistro?> miRegistro();
}
