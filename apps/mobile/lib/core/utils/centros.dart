import '../../data/models/centro_costo.dart';

/// Centros del subárbol cuya raíz es [raizId], incluida la propia raíz.
///
/// Se calcula con `padre_id` porque el catálogo visible por RLS abarca toda la
/// empresa. Así el selector del administrador coincide con la validación de la
/// Edge Function `invitar-usuario`.
List<CentroCosto> subarbolDe(List<CentroCosto> centros, String raizId) {
  final hijos = <String?, List<CentroCosto>>{};
  for (final centro in centros) {
    hijos.putIfAbsent(centro.padreId, () => []).add(centro);
  }

  final resultado = <CentroCosto>[];
  final pendientes = <String>[raizId];
  final vistos = <String>{};

  while (pendientes.isNotEmpty) {
    final actual = pendientes.removeLast();
    if (!vistos.add(actual)) continue;
    final propios = hijos[actual] ?? const <CentroCosto>[];
    for (final centro in propios) {
      if (vistos.contains(centro.id)) continue;
      resultado.add(centro);
      pendientes.add(centro.id);
    }
  }

  final raiz = centros.where((centro) => centro.id == raizId);
  final subarbol = <CentroCosto>[...raiz, ...resultado];
  subarbol.sort((a, b) => a.nombre.compareTo(b.nombre));
  return subarbol;
}

String _sinTildes(String texto) {
  const con = 'áéíóúüñÁÉÍÓÚÜÑ';
  const sin = 'aeiouunAEIOUUN';
  final buffer = StringBuffer();
  for (final letra in texto.split('')) {
    final i = con.indexOf(letra);
    buffer.write(i < 0 ? letra : sin[i]);
  }
  return buffer.toString().toLowerCase();
}

/// Busca por código o nombre, sin importar tildes ni mayúsculas. Con varias
/// palabras, todas deben aparecer ("andaria kid" encuentra 057.01).
/// Ordena por código para que cada parque quede junto a sus hijos.
List<CentroCosto> filtrarCentros(List<CentroCosto> centros, String consulta) {
  final palabras = _sinTildes(consulta.trim())
      .split(RegExp(r'\s+'))
      .where((palabra) => palabra.isNotEmpty)
      .toList(growable: false);
  final resultado = centros.where((centro) {
    final texto = _sinTildes('${centro.codigo} ${centro.nombre}');
    return palabras.every(texto.contains);
  }).toList();
  resultado.sort((a, b) {
    final porCodigo = a.codigo.compareTo(b.codigo);
    return porCodigo != 0 ? porCodigo : a.nombre.compareTo(b.nombre);
  });
  return resultado;
}
