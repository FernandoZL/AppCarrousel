/// Sesión activa del usuario, sin exponer tipos de Supabase al dominio.
class SesionUsuario {
  const SesionUsuario({required this.id, required this.email, this.nombre});

  final String id;
  final String email;

  /// Nombre visible tomado de `user_metadata`. Solo se usa para precargar
  /// formularios; nunca para autorizar.
  final String? nombre;
}
