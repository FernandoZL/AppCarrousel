import 'package:carrousel_app/features/horario/domain/entities/horario.dart';
import 'package:carrousel_app/features/horario/domain/repositories/horario_repository.dart';

class ListarHorarios {
  const ListarHorarios(this._repo);

  final HorarioRepository _repo;

  Future<List<Horario>> call(String empleadoId) => _repo.horariosDe(empleadoId);
}

class GuardarHorario {
  const GuardarHorario(this._repo);

  final HorarioRepository _repo;

  Future<void> call({
    required String empresaId,
    required String empleadoId,
    required int diaSemana,
    required String horaEntrada,
    required String horaSalida,
    required int toleranciaEntradaMin,
    required int toleranciaSalidaMin,
    String? horarioId,
  }) => _repo.guardar(
    empresaId: empresaId,
    empleadoId: empleadoId,
    diaSemana: diaSemana,
    horaEntrada: horaEntrada,
    horaSalida: horaSalida,
    toleranciaEntradaMin: toleranciaEntradaMin,
    toleranciaSalidaMin: toleranciaSalidaMin,
    horarioId: horarioId,
  );
}

class EliminarHorario {
  const EliminarHorario(this._repo);

  final HorarioRepository _repo;

  Future<void> call(String horarioId) => _repo.eliminar(horarioId);
}
