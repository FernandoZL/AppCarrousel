import 'package:carrousel_app/features/horario/domain/entities/horario.dart';

/// Contrato de horarios semanales por empleado.
abstract class HorarioRepository {
  Future<List<Horario>> horariosDe(String empleadoId);

  /// Crea el horario cuando `horarioId` es nulo; si existe, lo actualiza.
  Future<void> guardar({
    required String empresaId,
    required String empleadoId,
    required int diaSemana,
    required String horaEntrada,
    required String horaSalida,
    required int toleranciaEntradaMin,
    required int toleranciaSalidaMin,
    String? horarioId,
  });

  Future<void> eliminar(String horarioId);
}
