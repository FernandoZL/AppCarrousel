import 'package:carrousel_app/features/configuracion/data/mappers/configuracion_mapper.dart';
import 'package:carrousel_app/features/configuracion/domain/entities/configuracion_empresa.dart';
import 'package:carrousel_app/features/configuracion/domain/repositories/configuracion_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfiguracionRepository implements ConfiguracionRepository {
  SupabaseConfiguracionRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<ConfiguracionEmpresa> cargar(String empresaId) async {
    final fila = await _client
        .from('empresas')
        .select('id, nombre, zona_horaria, gps_precision_maxima_metros')
        .eq('id', empresaId)
        .single();
    return configuracionDesdeMapa(fila);
  }

  @override
  Future<void> guardar({
    required String empresaId,
    required String zonaHoraria,
    required int gpsPrecisionMaximaMetros,
  }) async {
    await _client
        .from('empresas')
        .update({
          'zona_horaria': zonaHoraria.trim(),
          'gps_precision_maxima_metros': gpsPrecisionMaximaMetros,
        })
        .eq('id', empresaId);
  }
}
