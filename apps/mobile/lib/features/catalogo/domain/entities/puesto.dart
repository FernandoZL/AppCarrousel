/// Puesto del catálogo de una empresa. Cada perfil referencia su puesto.
class Puesto {
  const Puesto({
    required this.id,
    required this.empresaId,
    required this.codigo,
    required this.nombre,
    required this.activo,
    this.descripcion,
  });

  final String id;
  final String empresaId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final bool activo;
}
