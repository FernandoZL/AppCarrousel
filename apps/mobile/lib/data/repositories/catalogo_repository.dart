import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/centro_costo.dart';
import '../models/parque.dart';

typedef PersonaResumen = ({String nombre, String? puesto});

class CatalogoRepository {
  CatalogoRepository(this._client);

  final SupabaseClient _client;

  Future<List<CentroCosto>> centros() async {
    final filas = await _client
        .from('centros_costo')
        .select('id, codigo, nombre, padre_id')
        .order('nombre');
    return filas.map(CentroCosto.fromMap).toList(growable: false);
  }

  Future<List<Parque>> parques() async {
    final filas = await _client
        .from('parques')
        .select(
          'id, empresa_id, centro_costo_id, codigo, nombre, latitud, longitud, radio_metros, activo',
        )
        .eq('activo', true)
        .order('nombre');
    return filas.map(Parque.fromMap).toList(growable: false);
  }

  /// Nombre y puesto de los perfiles visibles por RLS (el propio o el equipo).
  Future<Map<String, PersonaResumen>> personas() async {
    final filas = await _client
        .from('perfiles')
        .select('id, nombre_completo, puestos!perfiles_puesto_fk(nombre)');
    return {
      for (final fila in filas)
        fila['id'] as String: (
          nombre: fila['nombre_completo'] as String,
          puesto:
              (fila['puestos'] as Map<String, dynamic>?)?['nombre'] as String?,
        ),
    };
  }
}
