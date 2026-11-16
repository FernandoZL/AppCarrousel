import 'package:carrousel_app/features/horario/domain/entities/horario.dart';
import 'package:carrousel_app/features/horario/domain/utils/horarios.dart';

Horario horarioDesdeMapa(Map<String, dynamic> map) => Horario(
  id: map['id'] as String,
  empresaId: map['empresa_id'] as String,
  empleadoId: map['empleado_id'] as String,
  diaSemana: (map['dia_semana'] as num).toInt(),
  horaEntrada: normalizarHora(map['hora_entrada']?.toString()),
  horaSalida: normalizarHora(map['hora_salida']?.toString()),
  toleranciaEntradaMin: (map['tolerancia_entrada_min'] as num?)?.toInt() ?? 10,
  toleranciaSalidaMin: (map['tolerancia_salida_min'] as num?)?.toInt() ?? 10,
  activo: map['activo'] as bool? ?? true,
);
