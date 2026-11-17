import 'package:supabase_flutter/supabase_flutter.dart';

/// Error de negocio con un mensaje ya listo para mostrar al usuario.
class AppException implements Exception {
  const AppException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

String mensajeDeError(Object error) {
  if (error is AppException) return error.mensaje;

  if (error is AuthException) {
    final texto = error.message.toLowerCase();
    if (texto.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (texto.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión.';
    }
    if (texto.contains('user already registered')) {
      return 'Ese correo ya tiene una cuenta.';
    }
    if (texto.contains('password should be at least') ||
        texto.contains('password is too short')) {
      return 'La contraseña es demasiado corta. Usa al menos 8 caracteres.';
    }
    if (texto.contains('different from the old password')) {
      return 'La nueva contraseña debe ser diferente a la anterior.';
    }
    if (texto.contains('auth session missing') ||
        texto.contains('token has expired') ||
        texto.contains('invalid token')) {
      return 'El enlace expiró o no es válido. Solicita uno nuevo.';
    }
    if (texto.contains('rate limit') || texto.contains('too many')) {
      return 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';
    }
    return 'No se pudo completar la operación de acceso. Inténtalo de nuevo.';
  }

  if (error is PostgrestException) {
    switch (error.code) {
      case '23514':
        final texto = error.message.toLowerCase();
        if (texto.contains('geocerca')) {
          return 'Estás fuera del área permitida del parque. Acércate y vuelve a intentarlo.';
        }
        if (texto.contains('justificaci')) {
          return 'La justificación debe tener entre 10 y 2000 caracteres.';
        }
        if (texto.contains('perfil aprovisionado')) {
          return 'Tu cuenta ya tiene acceso a Carrousel. Actualiza o vuelve a iniciar sesión.';
        }
        if (texto.contains('nombre completo')) {
          return 'El nombre completo debe tener entre 1 y 160 caracteres.';
        }
        if (texto.contains('puesto')) {
          return 'El puesto debe tener entre 1 y 120 caracteres.';
        }
        if (texto.contains('zona horaria')) {
          return 'La zona horaria no es válida. Usa un nombre IANA, por ejemplo America/Guatemala.';
        }
        if (texto.contains('gps_precision')) {
          return 'La precisión GPS debe estar entre 10 y 1000 metros.';
        }
        return 'Los datos no cumplen las reglas de la solicitud.';
      case '23505':
        final texto = error.message.toLowerCase();
        if (texto.contains('jornadas')) {
          return 'Ya tienes una jornada abierta. Cierra la actual antes de abrir otra.';
        }
        if (texto.contains('solicitud de alta')) {
          return 'Ya tienes una solicitud de alta pendiente.';
        }
        return 'Ese registro ya existe.';
      case '23503':
        final texto = error.message.toLowerCase();
        if (texto.contains('código de empresa') ||
            texto.contains('codigo de empresa')) {
          return 'El código de empresa no existe o la empresa está suspendida.';
        }
        if (texto.contains('puesto')) {
          return 'El puesto declarado no es válido para esta empresa.';
        }
        return 'El centro o parque seleccionado ya no está disponible.';
      case '42501':
        return 'No tienes permiso para realizar esta acción.';
      case 'PGRST116':
        return 'No se encontró el registro o no tienes acceso a él.';
      default:
        return 'La operación no se pudo completar. Inténtalo de nuevo.';
    }
  }

  final texto = error.toString().toLowerCase();
  if (texto.contains('socketexception') ||
      texto.contains('failed host lookup') ||
      texto.contains('connection')) {
    return 'Sin conexión. Revisa tu red e inténtalo de nuevo.';
  }

  return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
}
