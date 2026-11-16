import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/lugar_catalogo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque_centro.dart';
import 'package:carrousel_app/features/catalogo/domain/repositories/catalogo_repository.dart';

class ListarCentros {
  const ListarCentros(this._repo);

  final CatalogoRepository _repo;

  Future<List<CentroCosto>> call() => _repo.centros();
}

class ListarParques {
  const ListarParques(this._repo);

  final CatalogoRepository _repo;

  Future<List<Parque>> call() => _repo.parques();
}

class ListarNombresDePerfiles {
  const ListarNombresDePerfiles(this._repo);

  final CatalogoRepository _repo;

  Future<Map<String, String>> call() => _repo.nombresDePerfiles();
}

class ListarParquesCentros {
  const ListarParquesCentros(this._repo);

  final CatalogoRepository _repo;

  Future<List<ParqueCentro>> call() => _repo.parquesCentros();
}

class ListarLugares {
  const ListarLugares(this._repo);

  final CatalogoRepository _repo;

  Future<List<LugarCatalogo>> call() => _repo.lugares();
}
