import 'package:carrousel_app/features/auth/domain/entities/perfil.dart';
import 'package:carrousel_app/features/auth/domain/entities/rol_usuario.dart';
import 'package:carrousel_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:carrousel_app/features/catalogo/presentation/providers/catalogo_providers.dart';
import 'package:carrousel_app/features/configuracion/domain/entities/configuracion_empresa.dart';
import 'package:carrousel_app/features/configuracion/presentation/providers/configuracion_providers.dart';
import 'package:carrousel_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:carrousel_app/features/jornada/domain/entities/jornada.dart';
import 'package:carrousel_app/features/jornada/presentation/providers/jornada_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _empleado = Perfil(
  id: 'empleado-id',
  empresaId: 'empresa-id',
  centroCostoId: 'centro-id',
  rol: RolUsuario.empleado,
  nombreCompleto: 'Ana Pérez',
);

final _configuracion = ConfiguracionEmpresa(
  id: 'empresa-id',
  nombre: 'Carrousel',
  zonaHoraria: 'America/Guatemala',
  gpsPrecisionMaximaMetros: 100,
);

// UTC 03:00 del 17-nov = 21:00 del 16-nov en Guatemala.
final _ahora = DateTime.utc(2026, 11, 17, 3);

// 23:00 UTC del 16-nov = 17:00 local. Cierra a las 00:00 UTC del 17-nov,
// dentro del "hoy" de la empresa pero no del "hoy" UTC.
final _jornada = Jornada(
  id: 'jornada-1',
  empresaId: 'empresa-id',
  empleadoId: 'empleado-id',
  parqueId: 'parque-id',
  entradaEn: DateTime.utc(2026, 11, 16, 23),
  salidaEn: DateTime.utc(2026, 11, 17, 0),
  entradaDentroGeocerca: true,
  salidaDentroGeocerca: true,
);

Widget _app() {
  return ProviderScope(
    overrides: [
      perfilProvider.overrideWith((ref) async => _empleado),
      configuracionEmpresaProvider.overrideWith(
        (ref, empresaId) async => _configuracion,
      ),
      parquesProvider.overrideWith((ref) async => const []),
      jornadasStreamProvider.overrideWith((ref) => Stream.value([_jornada])),
      relojDashboardProvider.overrideWithValue(() => _ahora),
    ],
    child: const MaterialApp(home: DashboardPage()),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('hoy, semana y mes usan la zona horaria de la empresa', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Hoy · horas'), 200);
    await tester.pumpAndSettle();

    // La jornada aporta 1 h a las tres métricas al calcularse en Guatemala.
    // Con la zona del dispositivo (UTC) aportaría 0 h a "hoy".
    expect(find.text('1.0'), findsNWidgets(3));
    expect(find.text('Hoy · horas'), findsOneWidget);
  });
}
