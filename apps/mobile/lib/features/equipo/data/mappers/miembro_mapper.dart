import 'package:carrousel_app/features/equipo/domain/entities/miembro_equipo.dart';

MiembroEquipo miembroDesdeMapa(Map<String, dynamic> map) => MiembroEquipo(
  id: map['id'] as String,
  empresaId: map['empresa_id'] as String,
  centroCostoId: map['centro_costo_id'] as String,
  nombreCompleto: map['nombre_completo'] as String,
  rol: map['rol'] as String? ?? 'empleado',
  activo: map['activo'] as bool? ?? true,
);
