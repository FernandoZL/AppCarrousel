import 'package:carrousel_app/core/errors/error_messages.dart';
import 'package:carrousel_app/features/horario/data/mappers/horario_mapper.dart';
import 'package:carrousel_app/features/horario/domain/entities/horario.dart';
import 'package:carrousel_app/features/horario/domain/repositories/horario_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHorarioRepository implements HorarioRepository {
  SupabaseHorarioRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Horario>> horariosDe(String empleadoId) async {
    final filas = await _client
        .from('horarios')
        .select('*')
        .eq('empleado_id', empleadoId)
        .order('dia_semana');
    return filas.map(horarioDesdeMapa).toList(growable: false);
  }

  @override
  Future<void> guardar({
    required String empresaId,
    required String empleadoId,
    required int diaSemana,
    required String horaEntrada,
    required String horaSalida,
    required int toleranciaEntradaMin,
    required int toleranciaSalidaMin,
    String? horarioId,
  }) async {
    final datos = {
      'hora_entrada': horaEntrada,
      'hora_salida': horaSalida,
      'tolerancia_entrada_min': toleranciaEntradaMin,
      'tolerancia_salida_min': toleranciaSalidaMin,
      'activo': true,
    };

    if (horarioId == null) {
      await _client.from('horarios').insert({
        'empresa_id': empresaId,
        'empleado_id': empleadoId,
        'dia_semana': diaSemana,
        ...datos,
      });
      return;
    }

    final filas = await _client
        .from('horarios')
        .update(datos)
        .eq('id', horarioId)
        .select('id');
    if (filas.isEmpty) {
      throw const AppException(
        'No se pudo guardar el horario. Inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<void> eliminar(String horarioId) async {
    final filas = await _client
        .from('horarios')
        .delete()
        .eq('id', horarioId)
        .select('id');
    if (filas.isEmpty) {
      throw const AppException('El horario ya no existe o no puedes borrarlo.');
    }
  }
}
