import 'package:carrousel_app/features/catalogo/data/mappers/catalogo_mapper.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque_centro.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/lugar_catalogo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/puesto.dart';
import 'package:carrousel_app/features/catalogo/domain/repositories/catalogo_repository.dart';
import 'package:carrousel_app/features/catalogo/domain/utils/lugares.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCatalogoRepository implements CatalogoRepository {
  SupabaseCatalogoRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<CentroCosto>> centros() async {
    final filas = await _client
        .from('centros_costo')
        .select('id, codigo, nombre, padre_id')
        .order('nombre');
    return filas.map(centroCostoDesdeMapa).toList(growable: false);
  }

  @override
  Future<List<Parque>> parques() async {
    final filas = await _client
        .from('parques')
        .select(
          'id, empresa_id, centro_costo_id, codigo, nombre, latitud, longitud, radio_metros, activo',
        )
        .order('nombre');
    return filas.map(parqueDesdeMapa).toList(growable: false);
  }

  @override
  Future<List<ParqueCentro>> parquesCentros() async {
    final filas = await _client
        .from('parques_centros')
        .select('id, empresa_id, parque_id, centro_costo_id, principal, activo')
        .order('principal', ascending: false);
    return filas.map(parqueCentroDesdeMapa).toList(growable: false);
  }

  @override
  Future<List<LugarCatalogo>> lugares() async {
    final listaParques = await parques();
    final listaCentros = await centros();
    final enlaces = await parquesCentros();
    return construirLugares(
      parques: listaParques,
      centros: listaCentros,
      enlaces: enlaces,
    );
  }

  @override
  Future<Map<String, String>> nombresDePerfiles() async {
    final filas = await _client.from('perfiles').select('id, nombre_completo');
    return {
      for (final fila in filas)
        fila['id'] as String: fila['nombre_completo'] as String,
    };
  }

  @override
  Future<List<Puesto>> puestos() async {
    final filas = await _client
        .from('puestos')
        .select('id, empresa_id, codigo, nombre, descripcion, activo')
        .order('activo', ascending: false)
        .order('nombre');
    return filas.map(puestoDesdeMapa).toList(growable: false);
  }

  @override
  Future<void> crearPuesto({
    required String empresaId,
    required String codigo,
    required String nombre,
    String? descripcion,
  }) async {
    await _client.from('puestos').insert({
      'empresa_id': empresaId,
      'codigo': codigo.trim(),
      'nombre': nombre.trim(),
      'descripcion': _textoOpcional(descripcion),
      'activo': true,
    });
  }

  @override
  Future<void> actualizarPuesto({
    required String id,
    required String codigo,
    required String nombre,
    String? descripcion,
    required bool activo,
  }) async {
    await _client
        .from('puestos')
        .update({
          'codigo': codigo.trim(),
          'nombre': nombre.trim(),
          'descripcion': _textoOpcional(descripcion),
          'activo': activo,
        })
        .eq('id', id);
  }

  @override
  Future<void> eliminarPuesto(String id) async {
    await _client.from('puestos').delete().eq('id', id);
  }

  static String? _textoOpcional(String? valor) {
    final texto = valor?.trim();
    return texto == null || texto.isEmpty ? null : texto;
  }
}
