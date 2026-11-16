import 'package:carrousel_app/features/solicitudes/domain/entities/solicitud_horas_extras.dart';

/// Fila del reporte de horas extras con nombres ya resueltos por la vista.
class ReporteHorasExtras {
  const ReporteHorasExtras({
    required this.id,
    required this.empresaId,
    required this.empleadoId,
    required this.empleado,
    required this.centroCostoId,
    required this.centroNombre,
    required this.inicio,
    required this.fin,
    required this.horas,
    required this.estado,
    required this.creadoEn,
    this.parqueId,
    this.parqueNombre,
    this.comentarioAdmin,
    this.revisor,
    this.revisadoEn,
  });

  final String id;
  final String empresaId;
  final String empleadoId;
  final String empleado;
  final String centroCostoId;
  final String centroNombre;
  final DateTime inicio;
  final DateTime fin;
  final double horas;
  final EstadoSolicitud estado;
  final DateTime creadoEn;
  final String? parqueId;
  final String? parqueNombre;
  final String? comentarioAdmin;
  final String? revisor;
  final DateTime? revisadoEn;
}
