import 'package:carrousel_app/features/auth/domain/entities/perfil.dart';
import 'package:carrousel_app/features/auth/domain/entities/sesion_usuario.dart';

/// Eventos de sesión que la capa de presentación puede observar sin depender
/// de los tipos de Supabase.
enum EventoSesion { iniciada, cerrada, recuperacionContrasena, actualizada }

/// Resultado de crear una cuenta: si Supabase ya abrió sesión o si el proyecto
/// exige confirmar el correo antes de iniciarla.
enum ResultadoRegistroCuenta { sesionIniciada, confirmarCorreo }

/// Contrato de autenticación. La implementación concreta vive en `data`.
abstract class AuthRepository {
  Stream<EventoSesion> get eventosDeSesion;

  SesionUsuario? get sesionActual;

  Future<void> iniciarSesion({required String email, required String password});

  /// Crea la cuenta en Supabase Auth con el nombre en `user_metadata`. El
  /// perfil de negocio no se crea aquí: lo aprueba un administrador.
  Future<ResultadoRegistroCuenta> registrarCuenta({
    required String email,
    required String password,
    required String nombreCompleto,
  });

  /// Devuelve true si se abrió el navegador. El resultado real llega por
  /// [eventosDeSesion] cuando Supabase procesa el deep link.
  Future<bool> iniciarConGoogle();

  Future<void> enviarRecuperacion(String email);

  Future<void> actualizarContrasena(String password);

  Future<void> cerrarSesion();

  /// Renueva el token para recoger cambios de `app_metadata` sin cerrar
  /// sesión (por ejemplo, un alta recién aprobada).
  Future<void> refrescarSesion();

  Future<Perfil?> obtenerPerfil(String userId);
}
