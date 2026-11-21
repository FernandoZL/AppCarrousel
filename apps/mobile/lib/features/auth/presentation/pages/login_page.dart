import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carrousel_app/core/theme/app_theme.dart';
import 'package:carrousel_app/core/theme/theme_provider.dart';
import 'package:carrousel_app/core/utils/correos.dart';
import 'package:carrousel_app/core/widgets/ecosistema.dart';
import 'package:carrousel_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:carrousel_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:carrousel_app/features/auth/presentation/pages/registro_cuenta_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _verContrasena = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .iniciarSesion(email: _email.text, password: _password.text);
  }

  Future<void> _google() async {
    FocusScope.of(context).unfocus();
    final abierto = await ref
        .read(authControllerProvider.notifier)
        .iniciarConGoogle();
    if (!mounted || abierto) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No se pudo abrir Google.')));
  }

  void _abrirRegistro() {
    ref.read(authControllerProvider.notifier).limpiarError();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const RegistroCuentaPage()));
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(authControllerProvider);
    final colores = Theme.of(context).colorScheme;
    final cargando = estado.isLoading;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: Marca.authFondo),
        child: Column(
          children: [
            const FranjaMarca(),
            Expanded(
              child: SafeArea(
                top: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final dosPaneles = constraints.maxWidth >= 900;
                    final tarjeta = _TarjetaAcceso(
                      child: _formulario(context, estado, colores, cargando),
                    );
                    return Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(dosPaneles ? 32 : 16),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: dosPaneles ? 1080 : 480,
                          ),
                          child: dosPaneles
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(26),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Expanded(
                                          child: _PanelMarcaAcceso(),
                                        ),
                                        Expanded(child: tarjeta),
                                      ],
                                    ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: tarjeta,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formulario(
    BuildContext context,
    AsyncValue<void> estado,
    ColorScheme colores,
    bool cargando,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _EncabezadoAcceso(),
          const SizedBox(height: 22),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (valor) {
              final texto = valor?.trim() ?? '';
              if (texto.isEmpty) return 'Escribe tu correo.';
              if (!correoValido(texto)) {
                return 'Escribe un correo válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _password,
            obscureText: !_verContrasena,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _entrar(),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _verContrasena
                    ? 'Ocultar contraseña'
                    : 'Mostrar contraseña',
                onPressed: () =>
                    setState(() => _verContrasena = !_verContrasena),
                icon: Icon(
                  _verContrasena
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
              ),
            ),
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'Escribe tu contraseña.';
              }
              return null;
            },
          ),
          if (estado.hasError) ...[
            const SizedBox(height: 16),
            _BannerError(mensaje: estado.error.toString()),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: cargando ? null : _entrar,
            child: cargando
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Text('Iniciar sesión'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: cargando ? null : _google,
            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
            label: const Text('Continuar con Google'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: cargando
                ? null
                : () {
                    ref.read(authControllerProvider.notifier).limpiarError();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
            child: const Text('¿Olvidaste tu contraseña?'),
          ),
          const SizedBox(height: 18),
          Text(
            'Crea tu cuenta con el código de empresa. Un administrador '
            'aprobará tu acceso como empleado.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colores.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '¿Aún no tienes cuenta?',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colores.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: cargando ? null : _abrirRegistro,
                child: const Text('Crear cuenta'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _NotaSeguridad(),
          const SizedBox(height: 10),
          const _AccionesAcceso(),
        ],
      ),
    );
  }
}

class _BannerError extends StatelessWidget {
  const _BannerError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colores.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: colores.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(color: colores.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Encabezado de la tarjeta de acceso (`.auth-eyebrow`, `h2`, `.auth-lead`).
class _EncabezadoAcceso extends StatelessWidget {
  const _EncabezadoAcceso();

  @override
  Widget build(BuildContext context) {
    final colores = ColoresCarrousel.of(context);
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCESO SEGURO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: oscuro ? Marca.authEyebrowOscuro : Marca.authEyebrow,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ingresa a Carrousel',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
            height: 1.2,
            color: colores.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Control de jornadas y horas extras',
          style: TextStyle(fontSize: 15, color: colores.muted),
        ),
      ],
    );
  }
}

/// Tarjeta derecha del acceso (`.auth-panel-v2 > .auth-card-v2`): campos de
/// 48 px y botón principal `#173d75`, propios de la pantalla de acceso.
class _TarjetaAcceso extends StatelessWidget {
  const _TarjetaAcceso({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final oscuro = tema.brightness == Brightness.dark;
    final principal = oscuro ? tema.colorScheme.primary : Marca.authPrimary;
    final radio = BorderRadius.circular(10);
    return Theme(
      data: tema.copyWith(
        inputDecorationTheme: tema.inputDecorationTheme.copyWith(
          constraints: const BoxConstraints(minHeight: 48),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: principal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: radio),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: tema.outlinedButtonTheme.style?.copyWith(
            minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: radio),
            ),
          ),
        ),
      ),
      child: ColoredBox(
        color: tema.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 22),
          child: child,
        ),
      ),
    );
  }
}

/// Panel izquierdo de marca (`.auth-brand-v2`) con círculos decorativos.
class _PanelMarcaAcceso extends StatelessWidget {
  const _PanelMarcaAcceso();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Marca.authPanel,
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: -70,
            child: _Circulo(diametro: 220, color: Marca.pink.withAlpha(70)),
          ),
          Positioned(
            left: -60,
            bottom: -80,
            child: _Circulo(diametro: 240, color: Marca.yellow.withAlpha(55)),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LogoCarrousel(tamano: 64),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  child: const Text(
                    'Carrousel $nombreApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Bienvenido a tu jornada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.6,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Marca tu entrada y salida desde el parque, registra tus '
                  'horas extras y sigue su aprobación en tiempo real.',
                  style: TextStyle(
                    color: Color(0xFFD5DEF0),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Etiqueta('Marcaje con GPS'),
                    _Etiqueta('Horas extras'),
                    _Etiqueta('Aprobación en línea'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circulo extends StatelessWidget {
  const _Circulo({required this.diametro, required this.color});

  final double diametro;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: diametro,
    height: diametro,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Etiquetas del panel de marca (`.auth-points-v2 > span`).
class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(22),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withAlpha(45)),
    ),
    child: Text(
      texto,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// Nota de seguridad (`.auth-security-v2`).
class _NotaSeguridad extends StatelessWidget {
  const _NotaSeguridad();

  @override
  Widget build(BuildContext context) {
    final colores = ColoresCarrousel.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colores.infoBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 18, color: colores.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tu contraseña es personal. No la compartas: el personal de '
              'Carrousel nunca te la pedirá.',
              style: TextStyle(fontSize: 12.5, color: colores.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Acciones al pie de la tarjeta (`.auth-actions-v2`): botón de tema.
class _AccionesAcceso extends ConsumerWidget {
  const _AccionesAcceso();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () => ref.read(temaProvider.notifier).state = oscuro
            ? ThemeMode.light
            : ThemeMode.dark,
        icon: Icon(
          oscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          size: 18,
        ),
        label: Text(oscuro ? 'Tema claro' : 'Tema oscuro'),
      ),
    );
  }
}
