import 'package:carrousel_app/features/registro/data/mappers/mi_registro_mapper.dart';
import 'package:carrousel_app/features/registro/domain/entities/mi_registro.dart';
import 'package:carrousel_app/features/registro/domain/repositories/registro_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRegistroRepository implements RegistroRepository {
  SupabaseRegistroRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<String> solicitar({
    required String codigoEmpresa,
    required String nombreCompleto,
    required String puesto,
  }) async {
    final id = await _client.rpc(
      'solicitar_registro',
      params: {
        'p_codigo_empresa': codigoEmpresa.trim(),
        'p_nombre_completo': nombreCompleto.trim(),
        'p_puesto': puesto.trim(),
      },
    );
    return id as String;
  }

  @override
  Future<MiRegistro?> miRegistro() async {
    final usuario = _client.auth.currentUser;
    if (usuario == null) return null;

    final fila = await _client
        .from('registros_pendientes')
        .select('*')
        .eq('usuario_id', usuario.id)
        .order('creado_en', ascending: false)
        .limit(1)
        .maybeSingle();
    if (fila == null) return null;
    return miRegistroDesdeMapa(fila);
  }
}
