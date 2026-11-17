import 'package:flutter/material.dart';

import 'package:carrousel_app/features/admin/presentation/pages/aprobaciones_page.dart';
import 'package:carrousel_app/features/configuracion/presentation/pages/configuracion_empresa_page.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/cumplimiento_page.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/horarios_equipo_page.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/lugares_page.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/puestos_page.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/registros_pendientes_page.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/reportes_page.dart';

/// Sección de administración del equipo, agrupada en pestañas.
class EquipoPage extends StatelessWidget {
  const EquipoPage({super.key});

  static const _pestanas = <String>[
    'Aprobaciones',
    'Altas',
    'Jornadas',
    'Horarios',
    'Lugares',
    'Puestos',
    'Reportes',
    'Configuración',
  ];

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: _pestanas.length,
      child: Column(
        children: [
          Material(
            color: colores.surface,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [for (final pestana in _pestanas) Tab(text: pestana)],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                AprobacionesPage(),
                RegistrosPendientesPage(),
                CumplimientoPage(),
                HorariosEquipoPage(),
                LugaresPage(),
                PuestosPage(),
                ReportesPage(),
                ConfiguracionEmpresaPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
