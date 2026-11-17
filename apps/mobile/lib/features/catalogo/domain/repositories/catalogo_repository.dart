import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque_centro.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/lugar_catalogo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/puesto.dart';

/// Catálogos visibles para el usuario según RLS.
abstract class CatalogoRepository {
  Future<List<CentroCosto>> centros();

  Future<List<Parque>> parques();

  Future<List<ParqueCentro>> parquesCentros();

  Future<List<LugarCatalogo>> lugares();

  Future<Map<String, String>> nombresDePerfiles();

  Future<List<Puesto>> puestos();

  Future<void> crearPuesto({
    required String empresaId,
    required String codigo,
    required String nombre,
    String? descripcion,
  });

  Future<void> actualizarPuesto({
    required String id,
    required String codigo,
    required String nombre,
    String? descripcion,
    required bool activo,
  });

  Future<void> eliminarPuesto(String id);
}
