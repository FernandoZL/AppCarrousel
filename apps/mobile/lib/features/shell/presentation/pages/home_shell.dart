import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carrousel_app/features/auth/domain/entities/perfil.dart';
import 'package:carrousel_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/equipo_page.dart';
import 'package:carrousel_app/features/horario/presentation/pages/mi_horario_page.dart';
import 'package:carrousel_app/features/perfil/presentation/pages/perfil_page.dart';
import 'package:carrousel_app/features/solicitudes/presentation/pages/solicitudes_page.dart';

/// Contenedor principal después del login.
///
/// En pantallas anchas usa `NavigationRail` (extendido desde 1100 px); en
/// móvil usa `NavigationBar`. El empleado ve Inicio, Horario, Horas extras y
/// Perfil; el administrador suma la sección Equipo con sus pestañas.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.perfil});

  final Perfil perfil;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    final esAdmin = widget.perfil.esAdmin;
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
        final usarRail = ancho >= 900;
        final extendido = ancho >= 1100;

        return Scaffold(
          appBar: AppBar(title: Text(titulos[indice])),
          body: usarRail
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: indice,
                      extended: extendido,
                      labelType: extendido
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
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
                    const VerticalDivider(width: 1),
                    Expanded(child: cuerpo),
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
      },
    );
  }
}

class _Destino {
  const _Destino(this.etiqueta, this.icono, this.iconoActivo);

  final String etiqueta;
  final IconData icono;
  final IconData iconoActivo;
}
