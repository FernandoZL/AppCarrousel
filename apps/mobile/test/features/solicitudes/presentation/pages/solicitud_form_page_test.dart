import 'package:carrousel_app/features/auth/domain/entities/perfil.dart';
import 'package:carrousel_app/features/auth/domain/entities/rol_usuario.dart';
import 'package:carrousel_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/lugar_catalogo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque.dart';
import 'package:carrousel_app/features/catalogo/presentation/providers/catalogo_providers.dart';
import 'package:carrousel_app/features/solicitudes/domain/entities/solicitud_horas_extras.dart';
import 'package:carrousel_app/features/solicitudes/domain/repositories/solicitud_repository.dart';
import 'package:carrousel_app/features/solicitudes/domain/usecases/solicitud_usecases.dart';
import 'package:carrousel_app/features/solicitudes/presentation/pages/solicitud_form_page.dart';
import 'package:carrousel_app/features/solicitudes/presentation/providers/solicitud_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _empleado = Perfil(
  id: 'empleado-id',
  empresaId: 'empresa-id',
  centroCostoId: 'ceco-a',
  rol: RolUsuario.empleado,
  nombreCompleto: 'Ana Pérez',
);

const _cecoA = CentroCosto(id: 'ceco-a', codigo: 'A', nombre: 'CECO A');
const _cecoB = CentroCosto(id: 'ceco-b', codigo: 'B', nombre: 'CECO B');
const _cecoC = CentroCosto(id: 'ceco-c', codigo: 'C', nombre: 'CECO C');

final _lugares = <LugarCatalogo>[
  LugarCatalogo(
    parque: Parque(
      id: 'parque-1',
      empresaId: 'empresa-id',
      centroCostoId: 'ceco-b',
      codigo: 'P1',
      nombre: 'Parque Norte',
      latitud: 14.6,
      longitud: -90.5,
      radioMetros: 100,
      activo: true,
    ),
    centros: const [_cecoA, _cecoB],
    centroPrincipalId: 'ceco-b',
  ),
  LugarCatalogo(
    parque: Parque(
      id: 'parque-2',
      empresaId: 'empresa-id',
      centroCostoId: 'ceco-c',
      codigo: 'P2',
      nombre: 'Parque Sur',
      latitud: 14.5,
      longitud: -90.4,
      radioMetros: 120,
      activo: true,
    ),
    centros: const [_cecoC],
    centroPrincipalId: 'ceco-c',
  ),
];

class _RepoFalso implements SolicitudRepository {
  String? centroCostoId;
  String? parqueId;
  DateTime? inicio;
  DateTime? fin;
  String? justificacion;
  int creaciones = 0;

  @override
  Future<void> crear({
    required String centroCostoId,
    required String parqueId,
    required DateTime inicio,
    required DateTime fin,
    required String justificacion,
  }) async {
    this.centroCostoId = centroCostoId;
    this.parqueId = parqueId;
    this.inicio = inicio;
    this.fin = fin;
    this.justificacion = justificacion;
    creaciones++;
  }

  @override
  Future<void> revisar({
    required String solicitudId,
    required EstadoSolicitud decision,
    String? comentario,
  }) async => throw UnimplementedError();

  @override
  Future<void> cancelar({required String solicitudId}) async =>
      throw UnimplementedError();

  @override
  Stream<List<SolicitudHorasExtras>> observarSolicitudes() =>
      const Stream.empty();
}

Widget _app(_RepoFalso repo, {List<LugarCatalogo>? lugares}) {
  return ProviderScope(
    overrides: [
      perfilProvider.overrideWith((ref) async => _empleado),
      lugaresProvider.overrideWith((ref) async => lugares ?? _lugares),
      crearSolicitudProvider.overrideWithValue(CrearSolicitud(repo)),
    ],
    child: const MaterialApp(home: SolicitudFormPage()),
  );
}

Future<void> _pumpForm(WidgetTester tester, Widget app) async {
  await tester.binding.setSurfaceSize(const Size(800, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

Future<void> _tocarEnviar(WidgetTester tester) async {
  await tester.tap(find.text('Enviar solicitud'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('exige una justificación de al menos 10 caracteres', (
    tester,
  ) async {
    final repo = _RepoFalso();
    await _pumpForm(tester, _app(repo));

    await tester.enterText(find.byType(TextFormField), 'Muy corto');
    await _tocarEnviar(tester);

    expect(find.text('Escribe al menos 10 caracteres.'), findsOneWidget);
    expect(repo.creaciones, 0);
  });

  testWidgets('sin lugar no envía la solicitud', (tester) async {
    final repo = _RepoFalso();
    await _pumpForm(tester, _app(repo, lugares: const []));

    await tester.enterText(
      find.byType(TextFormField),
      'Apoyo en el evento del parque central',
    );
    await _tocarEnviar(tester);

    expect(
      find.text(
        'Tu empresa aún no tiene lugares con centros de costo '
        'habilitados. Pide al administrador que configure un lugar.',
      ),
      findsOneWidget,
    );
    expect(repo.creaciones, 0);
  });

  testWidgets('cambiar de lugar recalcula el centro sugerido', (tester) async {
    final repo = _RepoFalso();
    await _pumpForm(tester, _app(repo));

    final selectores = find.byType(DropdownButtonFormField<String>);
    expect(selectores, findsNWidgets(2));
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(selectores.at(1))
          .initialValue,
      'ceco-a',
    );

    tester.widget<DropdownButtonFormField<String>>(selectores.at(0)).onChanged!(
      'parque-2',
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>).at(1),
          )
          .initialValue,
      'ceco-c',
    );
  });

  testWidgets('envía el rango, lugar, CECO y justificación', (tester) async {
    final repo = _RepoFalso();
    await _pumpForm(tester, _app(repo));

    await tester.enterText(
      find.byType(TextFormField),
      'Apoyo en el evento del parque central',
    );
    await _tocarEnviar(tester);

    expect(repo.creaciones, 1);
    expect(repo.parqueId, 'parque-1');
    expect(repo.centroCostoId, 'ceco-a');
    expect(repo.fin!.difference(repo.inicio!), const Duration(hours: 2));
    expect(repo.justificacion, 'Apoyo en el evento del parque central');
  });
}
