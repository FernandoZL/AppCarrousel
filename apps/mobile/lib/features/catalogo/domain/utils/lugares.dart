import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/lugar_catalogo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque_centro.dart';

/// Combina parques, centros y sus enlaces activos en lugares para elegir
/// primero el lugar y luego el CECO.
///
/// Solo se muestran parques activos con al menos un CECO activo. El CECO
/// principal va primero; si el empleado ya tiene un centro preferido y está
/// habilitado para el lugar, se usa ese al cambiar de lugar.
List<LugarCatalogo> construirLugares({
  required List<Parque> parques,
  required List<CentroCosto> centros,
  required List<ParqueCentro> enlaces,
}) {
  final centrosPorId = {for (final centro in centros) centro.id: centro};
  final enlacesPorParque = <String, List<ParqueCentro>>{};
  for (final enlace in enlaces) {
    if (!enlace.activo) continue;
    enlacesPorParque.putIfAbsent(enlace.parqueId, () => []).add(enlace);
  }

  final lugares = <LugarCatalogo>[];
  for (final parque in parques) {
    if (!parque.activo) continue;
    final enlacesDelParque = enlacesPorParque[parque.id];
    if (enlacesDelParque == null || enlacesDelParque.isEmpty) continue;

    String? principalId;
    final centrosDelLugar = <CentroCosto>[];
    for (final enlace in enlacesDelParque) {
      final centro = centrosPorId[enlace.centroCostoId];
      if (centro == null) continue;
      centrosDelLugar.add(centro);
      if (enlace.principal) principalId = enlace.centroCostoId;
    }
    if (centrosDelLugar.isEmpty) continue;

    principalId ??=
        centrosDelLugar.any((centro) => centro.id == parque.centroCostoId)
        ? parque.centroCostoId
        : centrosDelLugar.first.id;

    final principal = principalId;
    centrosDelLugar.sort((a, b) {
      if (a.id == principal) return -1;
      if (b.id == principal) return 1;
      return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });

    lugares.add(
      LugarCatalogo(
        parque: parque,
        centros: List.unmodifiable(centrosDelLugar),
        centroPrincipalId: principal,
      ),
    );
  }

  lugares.sort(
    (a, b) =>
        a.parque.nombre.toLowerCase().compareTo(b.parque.nombre.toLowerCase()),
  );
  return List.unmodifiable(lugares);
}

/// CECO que debe quedar seleccionado al elegir un lugar.
String centroSugerido(LugarCatalogo lugar, String? centroPreferidoId) {
  if (centroPreferidoId != null &&
      lugar.centros.any((centro) => centro.id == centroPreferidoId)) {
    return centroPreferidoId;
  }
  return lugar.centroPrincipalId;
}

/// Lugar que contiene el centro preferido; si no existe, el primero.
LugarCatalogo? lugarSugerido(
  List<LugarCatalogo> lugares,
  String? centroPreferidoId,
) {
  if (lugares.isEmpty) return null;
  if (centroPreferidoId != null) {
    for (final lugar in lugares) {
      if (lugar.centroPrincipalId == centroPreferidoId ||
          lugar.centros.any((centro) => centro.id == centroPreferidoId)) {
        return lugar;
      }
    }
  }
  return lugares.first;
}
