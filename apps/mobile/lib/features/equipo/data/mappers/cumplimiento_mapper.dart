import 'package:carrousel_app/features/equipo/domain/entities/cumplimiento_jornada.dart';
import 'package:carrousel_app/features/horario/domain/utils/horarios.dart';

CumplimientoJornada cumplimientoDesdeMapa(Map<String, dynamic> map) {
  final incidencias = <TipoIncidencia>[];
  final crudas = map['incidencias'];
  if (crudas is List) {
    for (final cruda in crudas) {
      final tipo = TipoIncidencia.parse(cruda?.toString());
      if (tipo != null) incidencias.add(tipo);
    }
  }

  final entradaProgramada = map['hora_entrada']?.toString();
  final salidaProgramada = map['hora_salida']?.toString();

  return CumplimientoJornada(
    id: map['id'] as String,
    empresaId: map['empresa_id'] as String,
    empleadoId: map['empleado_id'] as String,
    empleado: map['empleado'] as String? ?? 'Empleado',
    entradaEn: DateTime.parse(map['entrada_en'] as String).toLocal(),
    abierta: map['abierta'] as bool? ?? false,
    horas: (map['horas'] as num?)?.toDouble() ?? 0,
    incidencias: List.unmodifiable(incidencias),
    parqueId: map['parque_id'] as String?,
    parqueNombre: map['parque_nombre'] as String?,
    salidaEn: map['salida_en'] == null
        ? null
        : DateTime.parse(map['salida_en'] as String).toLocal(),
    horaEntradaProgramada: entradaProgramada == null
        ? null
        : normalizarHora(entradaProgramada),
    horaSalidaProgramada: salidaProgramada == null
        ? null
        : normalizarHora(salidaProgramada),
    toleranciaEntradaMin: (map['tolerancia_entrada_min'] as num?)?.toInt(),
    toleranciaSalidaMin: (map['tolerancia_salida_min'] as num?)?.toInt(),
    minutosTarde: (map['minutos_tarde'] as num?)?.toInt(),
    minutosTemprano: (map['minutos_temprano'] as num?)?.toInt(),
  );
}
