import 'package:carrousel_app/features/equipo/domain/entities/reporte_horas_extras.dart';
import 'package:carrousel_app/features/solicitudes/domain/entities/solicitud_horas_extras.dart';

ReporteHorasExtras reporteHorasExtrasDesdeMapa(Map<String, dynamic> map) =>
    ReporteHorasExtras(
      id: map['id'] as String,
      empresaId: map['empresa_id'] as String,
      empleadoId: map['empleado_id'] as String,
      empleado: map['empleado'] as String? ?? 'Empleado',
      centroCostoId: map['centro_costo_id'] as String,
      centroNombre: map['centro_nombre'] as String? ?? 'Centro de costo',
      inicio: DateTime.parse(map['inicio'] as String).toLocal(),
      fin: DateTime.parse(map['fin'] as String).toLocal(),
      horas: (map['horas'] as num?)?.toDouble() ?? 0,
      estado: EstadoSolicitud.parse(map['estado'] as String?),
      creadoEn: DateTime.parse(map['creado_en'] as String).toLocal(),
      parqueId: map['parque_id'] as String?,
      parqueNombre: map['parque_nombre'] as String?,
      comentarioAdmin: map['comentario_admin'] as String?,
      revisor: map['revisor'] as String?,
      revisadoEn: map['revisado_en'] == null
          ? null
          : DateTime.parse(map['revisado_en'] as String).toLocal(),
    );
