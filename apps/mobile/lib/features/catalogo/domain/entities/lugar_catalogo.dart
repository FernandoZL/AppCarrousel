import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque.dart';

/// Lugar listo para el formulario: un parque activo con sus CECOs disponibles.
class LugarCatalogo {
  const LugarCatalogo({
    required this.parque,
    required this.centros,
    required this.centroPrincipalId,
  });

  final Parque parque;
  final List<CentroCosto> centros;
  final String centroPrincipalId;
}
