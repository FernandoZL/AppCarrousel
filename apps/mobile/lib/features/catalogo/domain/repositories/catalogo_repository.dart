import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque_centro.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/lugar_catalogo.dart';

/// Catálogos visibles para el usuario según RLS.
abstract class CatalogoRepository {
  Future<List<CentroCosto>> centros();

  Future<List<Parque>> parques();

  Future<List<ParqueCentro>> parquesCentros();

  Future<List<LugarCatalogo>> lugares();

  Future<Map<String, String>> nombresDePerfiles();
}
