import 'package:carrousel_app/core/errors/error_messages.dart';
import 'package:carrousel_app/features/equipo/data/mappers/cumplimiento_mapper.dart';
import 'package:carrousel_app/features/equipo/data/mappers/miembro_mapper.dart';
import 'package:carrousel_app/features/equipo/data/mappers/registro_mapper.dart';
import 'package:carrousel_app/features/equipo/data/mappers/reporte_mapper.dart';
import 'package:carrousel_app/features/equipo/domain/entities/cumplimiento_jornada.dart';
import 'package:carrousel_app/features/equipo/domain/entities/miembro_equipo.dart';
import 'package:carrousel_app/features/equipo/domain/entities/registro_pendiente.dart';
import 'package:carrousel_app/features/equipo/domain/entities/reporte_horas_extras.dart';
import 'package:carrousel_app/features/equipo/domain/repositories/equipo_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEquipoRepository implements EquipoRepository {
  SupabaseEquipoRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<RegistroPendiente>> registrosPendientes() async {
    final filas = await _client
        .from('registros_pendientes')
        .select('*')
        .eq('estado', 'pendiente')
        .order('creado_en');
    return filas.map(registroPendienteDesdeMapa).toList(growable: false);
  }

  @override
  Future<void> aprobarRegistro({
    required String registroId,
    required String centroCostoId,
    String? puestoId,
  }) async {
    await _client.rpc(
      'aprobar_registro',
      params: {
        'p_registro_id': registroId,
        'p_centro_costo_id': centroCostoId,
        'p_puesto_id': puestoId,
      },
    );
  }

  @override
  Future<void> rechazarRegistro({
    required String registroId,
    required String motivo,
  }) async {
    await _client.rpc(
      'rechazar_registro',
      params: {'p_registro_id': registroId, 'p_motivo': motivo.trim()},
    );
  }

  @override
  Future<List<CumplimientoJornada>> cumplimiento() async {
    final filas = await _client
        .from('cumplimiento_jornadas')
        .select('*')
        .order('entrada_en', ascending: false)
        .limit(200);
    return filas.map(cumplimientoDesdeMapa).toList(growable: false);
  }

  @override
  Future<void> ajustarJornada({
    required String jornadaId,
    required DateTime entradaEn,
    required DateTime salidaEn,
    required String motivo,
  }) async {
    await _client.rpc(
      'ajustar_jornada',
      params: {
        'p_jornada_id': jornadaId,
        'p_entrada_en': entradaEn.toUtc().toIso8601String(),
        'p_salida_en': salidaEn.toUtc().toIso8601String(),
        'p_motivo': motivo.trim(),
      },
    );
  }

  @override
  Future<List<ReporteHorasExtras>> reporteHorasExtras() async {
    final filas = await _client
        .from('reporte_horas_extras')
        .select('*')
        .order('creado_en', ascending: false)
        .limit(500);
    return filas.map(reporteHorasExtrasDesdeMapa).toList(growable: false);
  }

  @override
  Future<List<MiembroEquipo>> miembros() async {
    final filas = await _client
        .from('perfiles')
        .select('id, empresa_id, centro_costo_id, rol, nombre_completo, activo')
        .order('nombre_completo');
    return filas.map(miembroDesdeMapa).toList(growable: false);
  }

  @override
  Future<void> agregarCentroLugar({
    required String empresaId,
    required String parqueId,
    required String centroCostoId,
  }) async {
    await _client.from('parques_centros').insert({
      'empresa_id': empresaId,
      'parque_id': parqueId,
      'centro_costo_id': centroCostoId,
      'principal': false,
      'activo': true,
    });
  }

  @override
  Future<void> cambiarActivoCentroLugar({
    required String enlaceId,
    required bool activo,
  }) async {
    final filas = await _client
        .from('parques_centros')
        .update({'activo': activo})
        .eq('id', enlaceId)
        .eq('principal', false)
        .select('id');
    if (filas.isEmpty) {
      throw const AppException(
        'El centro principal se cambia desde el centro del parque.',
      );
    }
  }
}
