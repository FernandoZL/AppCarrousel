/// Integrante del equipo visible para un administrador.
class MiembroEquipo {
  const MiembroEquipo({
    required this.id,
    required this.empresaId,
    required this.centroCostoId,
    required this.nombreCompleto,
    required this.rol,
    required this.activo,
  });

  final String id;
  final String empresaId;
  final String centroCostoId;
  final String nombreCompleto;
  final String rol;
  final bool activo;

  bool get esAdmin => rol == 'admin';

  String get rolEtiqueta => esAdmin ? 'Administrador' : 'Empleado';
}
