import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carrousel_app/core/config/env.dart';
import 'package:carrousel_app/core/widgets/estado_widgets.dart';
import 'package:carrousel_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:carrousel_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:carrousel_app/features/auth/presentation/pages/login_page.dart';
import 'package:carrousel_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:carrousel_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:carrousel_app/features/registro/presentation/pages/solicitud_alta_page.dart';
import 'package:carrousel_app/features/shell/presentation/pages/home_shell.dart';

class RootGate extends ConsumerStatefulWidget {
  const RootGate({super.key, this.initError});

  final Object? initError;

  @override
  ConsumerState<RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<RootGate> {
  bool _recuperacion = false;

  @override
  Widget build(BuildContext context) {
    if (!Env.isConfigured) {
      return const _ConfiguracionPendiente();
    }
    if (widget.initError != null) {
      return _ErrorConfiguracion(error: widget.initError!);
    }

    ref.listen<AsyncValue<EventoSesion>>(eventosSesionProvider, (anterior, siguiente) {
      final evento = siguiente.valueOrNull;
      if (evento == EventoSesion.recuperacionContrasena) {
        setState(() => _recuperacion = true);
      } else if (evento == EventoSesion.cerrada) {
        setState(() => _recuperacion = false);
      }
    });

    final eventos = ref.watch(eventosSesionProvider);
    final sesion = ref.watch(sesionActualProvider);

    if (eventos.isLoading && eventos.valueOrNull == null && sesion == null) {
      return const _PantallaCarga();
    }
    if (sesion == null) {
      return const LoginPage();
    }
    if (_recuperacion) {
      return ResetPasswordPage(
        obligatorio: true,
        onCompletado: () => setState(() => _recuperacion = false),
      );
    }

    final perfil = ref.watch(perfilProvider);
    return perfil.when(
      loading: () => const _PantallaCarga(mensaje: 'Cargando tu perfil...'),
      error: (error, _) => Scaffold(
        body: MensajeError(
          mensaje:
              'No se pudo cargar tu perfil. Revisa tu conexión o vuelve a iniciar sesión.',
          icono: Icons.person_off_outlined,
          onReintentar: () {
            ref.invalidate(perfilProvider);
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).cerrarSesion(),
              child: const Text('Cerrar sesión'),
            ),
          ),
        ),
      ),
      data: (perfil) {
        if (perfil == null) {
          final nombre = sesion.nombre?.trim();
          return SolicitudAltaPage(
            email: sesion.email,
            nombreInicial: nombre == null || nombre.isEmpty
                ? sesion.email.split('@').first
                : nombre,
          );
        }
        return HomeShell(perfil: perfil);
      },
    );
  }
}

class _PantallaCarga extends StatelessWidget {
  const _PantallaCarga({this.mensaje});

  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colores.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.attractions_rounded,
                size: 40,
                color: colores.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 22),
            const CircularProgressIndicator(),
            if (mensaje != null) ...[
              const SizedBox(height: 14),
              Text(mensaje!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConfiguracionPendiente extends StatelessWidget {
  const _ConfiguracionPendiente();

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Icon(Icons.settings_suggest_outlined,
                  size: 64, color: colores.primary),
              const SizedBox(height: 18),
              Text(
                'Configura Carrousel',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'La app necesita la URL y la clave pública de Supabase. '
                'No se incluyen credenciales en el repositorio.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colores.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const SelectableText(
                  'flutter run \\\n'
                  '  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \\\n'
                  '  --dart-define=SUPABASE_ANON_KEY=tu-clave-anon',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'El redirect ${Env.oauthRedirect} debe estar autorizado en Supabase Auth.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorConfiguracion extends StatelessWidget {
  const _ErrorConfiguracion({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MensajeError(
        mensaje: 'No se pudo conectar con Supabase.\n\n$error',
        icono: Icons.cloud_off_rounded,
      ),
    );
  }
}
