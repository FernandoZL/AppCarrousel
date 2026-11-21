import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carrousel_app/core/theme/app_theme.dart';
import 'package:carrousel_app/core/theme/theme_provider.dart';
import 'package:carrousel_app/core/widgets/ecosistema.dart';
import 'package:carrousel_app/features/auth/domain/entities/perfil.dart';
import 'package:carrousel_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:carrousel_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/equipo_page.dart';
import 'package:carrousel_app/features/horario/presentation/pages/mi_horario_page.dart';
import 'package:carrousel_app/features/perfil/presentation/pages/perfil_page.dart';
import 'package:carrousel_app/features/solicitudes/presentation/pages/solicitudes_page.dart';

/// Contenedor principal después del login, con el shell del Ecosistema
/// Carrousel v1.7.0: franja de marca, menú lateral azul marino, barra
/// superior con sección y página, y pie corporativo.
///
/// En web usa siempre `NavigationRail` lateral; en móvil, `NavigationBar`. En
/// pantallas anchas el rail se extiende desde 1100 px y el botón ☰ lo
/// colapsa a un riel de íconos. El empleado ve Inicio, Horario, Horas extras
/// y Perfil; el administrador suma Equipo. La barra superior permite alternar
/// entre tema claro y oscuro sin salir de la pantalla. El parámetro [esWeb]
/// solo se usa en pruebas para forzar la rama de navegación lateral sin
/// depender de un navegador real.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.perfil, this.esWeb});

  final Perfil perfil;

  /// Permite simular la rama web en pruebas de widget. En la app se deja nulo
  /// y se resuelve con `kIsWeb`; `true` fuerza el menú lateral.
  final bool? esWeb;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _indice = 0;

  /// Menú colapsado a riel de íconos en escritorio (solo esta sesión).
  bool _colapsado = false;

  Future<void> _salir() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres salir de Carrousel en este dispositivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      await ref.read(authControllerProvider.notifier).cerrarSesion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = widget.perfil.esAdmin;
    final modo = ref.watch(temaProvider);
    final esOscuro =
        modo == ThemeMode.dark ||
        (modo == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
    final colores = ColoresCarrousel.of(context);
    final paginas = <Widget>[
      const DashboardPage(),
      const MiHorarioPage(),
      const SolicitudesPage(),
      if (esAdmin) const EquipoPage(),
      PerfilPage(perfil: widget.perfil),
    ];
    final titulos = <String>[
      'Inicio',
      'Mi horario',
      'Horas extras',
      if (esAdmin) 'Equipo',
      'Mi perfil',
    ];
    final destinos = <_Destino>[
      const _Destino('Inicio', Icons.home_outlined, Icons.home_rounded),
      const _Destino(
        'Horario',
        Icons.schedule_outlined,
        Icons.schedule_rounded,
      ),
      const _Destino(
        'Horas extras',
        Icons.more_time_outlined,
        Icons.more_time_rounded,
      ),
      if (esAdmin)
        const _Destino('Equipo', Icons.groups_outlined, Icons.groups_rounded),
      const _Destino(
        'Perfil',
        Icons.person_outline_rounded,
        Icons.person_rounded,
      ),
    ];

    final indice = _indice.clamp(0, paginas.length - 1);
    final cuerpo = IndexedStack(index: indice, children: paginas);

    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final usarRail = (widget.esWeb ?? kIsWeb) || ancho >= 900;
        final puedeExtender = ancho >= 1100;
        final extendido = puedeExtender && !_colapsado;
        final barraCompleta = ancho >= 760;

        final botonTema = IconButton(
          icon: Icon(
            esOscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 20,
          ),
          tooltip: esOscuro ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro',
          style: _estiloBotonBarra(colores, soloIcono: true),
          onPressed: () => ref.read(temaProvider.notifier).state = esOscuro
              ? ThemeMode.light
              : ThemeMode.dark,
        );

        final scaffold = Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: usarRail && puedeExtender ? 8 : 20,
            leading: usarRail && puedeExtender
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.menu_rounded, size: 20),
                        tooltip: _colapsado ? 'Expandir menú' : 'Contraer menú',
                        style: _estiloBotonBarra(colores, soloIcono: true),
                        onPressed: () =>
                            setState(() => _colapsado = !_colapsado),
                      ),
                    ),
                  )
                : null,
            leadingWidth: usarRail && puedeExtender ? 60 : null,
            title: TituloBarraSuperior(
              seccion: 'Carrousel $nombreApp',
              pagina: titulos[indice],
            ),
            actions: [
              botonTema,
              if (barraCompleta) ...[
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    widget.perfil.nombreCompleto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colores.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: _estiloBotonBarra(colores),
                  onPressed: _salir,
                  child: const Text('Salir'),
                ),
              ],
              const SizedBox(width: 16),
            ],
          ),
          body: usarRail
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: indice,
                      extended: extendido,
                      labelType: extendido
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EncabezadoMenuLateral(extendido: extendido),
                          SeccionMenuLateral('Principal', extendido: extendido),
                        ],
                      ),
                      trailing: VersionMenuLateral(extendido: extendido),
                      trailingAtBottom: true,
                      onDestinationSelected: (valor) =>
                          setState(() => _indice = valor),
                      destinations: [
                        for (final destino in destinos)
                          NavigationRailDestination(
                            icon: Icon(destino.icono),
                            selectedIcon: Icon(destino.iconoActivo),
                            label: Text(destino.etiqueta),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: cuerpo),
                          const PieCorporativo(),
                        ],
                      ),
                    ),
                  ],
                )
              : cuerpo,
          bottomNavigationBar: usarRail
              ? null
              : NavigationBar(
                  selectedIndex: indice,
                  onDestinationSelected: (valor) =>
                      setState(() => _indice = valor),
                  destinations: [
                    for (final destino in destinos)
                      NavigationDestination(
                        icon: Icon(destino.icono),
                        selectedIcon: Icon(destino.iconoActivo),
                        label: destino.etiqueta,
                      ),
                  ],
                ),
        );

        return Column(
          children: [
            const FranjaMarca(),
            Expanded(child: scaffold),
          ],
        );
      },
    );
  }

  /// Botones de la barra superior: 36 px, borde fino, fondo transparente,
  /// radio 8 y 13 px peso 600; los de solo ícono miden 36 x 36.
  ButtonStyle _estiloBotonBarra(
    ColoresCarrousel colores, {
    bool soloIcono = false,
  }) {
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: colores.line),
    );
    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        soloIcono ? const Size(36, 36) : const Size(0, 36),
      ),
      fixedSize: soloIcono ? const WidgetStatePropertyAll(Size(36, 36)) : null,
      padding: WidgetStatePropertyAll(
        soloIcono
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 14),
      ),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: WidgetStatePropertyAll(colores.ink),
      overlayColor: WidgetStatePropertyAll(colores.hover),
      side: WidgetStatePropertyAll(BorderSide(color: colores.line)),
      shape: WidgetStatePropertyAll(forma),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Destino {
  const _Destino(this.etiqueta, this.icono, this.iconoActivo);

  final String etiqueta;
  final IconData icono;
  final IconData iconoActivo;
}
