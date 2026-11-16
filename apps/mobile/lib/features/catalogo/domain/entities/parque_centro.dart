/// CECO habilitado para un parque/lugar.
class ParqueCentro {
  const ParqueCentro({
    required this.id,
    required this.empresaId,
    required this.parqueId,
    required this.centroCostoId,
    required this.principal,
    required this.activo,
  });

  final String id;
  final String empresaId;
  final String parqueId;
  final String centroCostoId;

  /// CECO base del parque. No se edita a mano: se deriva de `parques`.
  final bool principal;
  final bool activo;
}
