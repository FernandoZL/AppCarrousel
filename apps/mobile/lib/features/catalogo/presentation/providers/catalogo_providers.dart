import 'package:carrousel_app/core/supabase/supabase_provider.dart';
import 'package:carrousel_app/features/catalogo/data/repositories/supabase_catalogo_repository.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/lugar_catalogo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque_centro.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/puesto.dart';
import 'package:carrousel_app/features/catalogo/domain/repositories/catalogo_repository.dart';
import 'package:carrousel_app/features/catalogo/domain/usecases/catalogo_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogoRepositoryProvider = Provider<CatalogoRepository>(
  (ref) => SupabaseCatalogoRepository(ref.watch(supabaseProvider)),
);

final centrosProvider = FutureProvider.autoDispose<List<CentroCosto>>((
  ref,
) async {
  return ListarCentros(ref.watch(catalogoRepositoryProvider))();
});

final parquesProvider = FutureProvider.autoDispose<List<Parque>>((ref) async {
  return ListarParques(ref.watch(catalogoRepositoryProvider))();
});

final nombresPerfilesProvider = FutureProvider.autoDispose<Map<String, String>>(
  (ref) async {
    return ListarNombresDePerfiles(ref.watch(catalogoRepositoryProvider))();
  },
);

final parquesCentrosProvider = FutureProvider.autoDispose<List<ParqueCentro>>((
  ref,
) async {
  return ListarParquesCentros(ref.watch(catalogoRepositoryProvider))();
});

final lugaresProvider = FutureProvider.autoDispose<List<LugarCatalogo>>((
  ref,
) async {
  return ListarLugares(ref.watch(catalogoRepositoryProvider))();
});

final puestosProvider = FutureProvider.autoDispose<List<Puesto>>((ref) async {
  return ListarPuestos(ref.watch(catalogoRepositoryProvider))();
});

final crearPuestoProvider = Provider<CrearPuesto>(
  (ref) => CrearPuesto(ref.watch(catalogoRepositoryProvider)),
);

final actualizarPuestoProvider = Provider<ActualizarPuesto>(
  (ref) => ActualizarPuesto(ref.watch(catalogoRepositoryProvider)),
);

final eliminarPuestoProvider = Provider<EliminarPuesto>(
  (ref) => EliminarPuesto(ref.watch(catalogoRepositoryProvider)),
);
