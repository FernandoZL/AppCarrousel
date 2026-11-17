enum EstadoMiRegistro {
  pendiente('Pendiente de aprobación'),
  aprobado('Aprobado'),
  rechazado('Rechazado');

  const EstadoMiRegistro(this.etiqueta);

  final String etiqueta;

  static EstadoMiRegistro parse(String? valor) {
    for (final estado in values) {
      if (estado.name == valor) return estado;
    }
    return EstadoMiRegistro.pendiente;
  }
}

/// Última solicitud de alta del usuario autenticado.
///
/// Es una entidad pura: no conoce Supabase ni el formato de las filas. El
/// mapeo desde la base vive en la capa `data`.
class MiRegistro {
  const MiRegistro({
    required this.id,
    required this.empresaId,
    required this.email,
    required this.nombreCompleto,
    required this.estado,
    this.puesto,
    required this.creadoEn,
    this.motivoRechazo,
    this.revisadoEn,
  });

  final String id;
  final String empresaId;
  final String email;
  final String nombreCompleto;
  final String? puesto;
  final EstadoMiRegistro estado;
  final DateTime creadoEn;
  final String? motivoRechazo;
  final DateTime? revisadoEn;

  bool get pendiente => estado == EstadoMiRegistro.pendiente;

  bool get aprobado => estado == EstadoMiRegistro.aprobado;

  bool get rechazado => estado == EstadoMiRegistro.rechazado;
}
