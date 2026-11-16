enum EstadoRegistro {
  pendiente('Pendiente'),
  aprobado('Aprobado'),
  rechazado('Rechazado');

  const EstadoRegistro(this.etiqueta);

  final String etiqueta;

  static EstadoRegistro parse(String? valor) {
    for (final estado in values) {
      if (estado.name == valor) return estado;
    }
    return EstadoRegistro.pendiente;
  }
}

/// Solicitud de alta creada con el código de empresa.
class RegistroPendiente {
  const RegistroPendiente({
    required this.id,
    required this.empresaId,
    required this.usuarioId,
    required this.email,
    required this.nombreCompleto,
    required this.estado,
    required this.creadoEn,
    this.centroCostoId,
    this.puestoId,
    this.motivoRechazo,
    this.revisadoPor,
    this.revisadoEn,
  });

  final String id;
  final String empresaId;
  final String usuarioId;
  final String email;
  final String nombreCompleto;
  final EstadoRegistro estado;
  final DateTime creadoEn;
  final String? centroCostoId;
  final String? puestoId;
  final String? motivoRechazo;
  final String? revisadoPor;
  final DateTime? revisadoEn;

  bool get pendiente => estado == EstadoRegistro.pendiente;
}
