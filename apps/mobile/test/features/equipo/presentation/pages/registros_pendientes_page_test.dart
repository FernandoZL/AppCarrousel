import 'package:carrousel_app/features/auth/domain/entities/perfil.dart';
import 'package:carrousel_app/features/auth/domain/entities/rol_usuario.dart';
import 'package:carrousel_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/presentation/providers/catalogo_providers.dart';
import 'package:carrousel_app/features/equipo/domain/entities/ajuste_jornada.dart';
import 'package:carrousel_app/features/equipo/domain/entities/cumplimiento_jornada.dart';
import 'package:carrousel_app/features/equipo/domain/entities/miembro_equipo.dart';
import 'package:carrousel_app/features/equipo/domain/entities/registro_pendiente.dart';
import 'package:carrousel_app/features/equipo/domain/entities/reporte_horas_extras.dart';
import 'package:carrousel_app/features/equipo/domain/repositories/equipo_repository.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/registros_pendientes_page.dart';
import 'package:carrousel_app/features/equipo/presentation/providers/equipo_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _admin = Perfil(
  id: 'admin-id',
  empresaId: 'empresa-id',
  centroCostoId: 'centro-admin',
  rol: RolUsuario.admin,
  nombreCompleto: 'Admin Carrousel',
);

const _centros = [
  CentroCosto(id: 'centro-admin', codigo: 'CA', nombre: 'Centro Admin'),
  CentroCosto(
    id: 'centro-hijo',
    codigo: 'CH',
    nombre: 'Centro Hijo',
    padreId: 'centro-admin',
  ),
  CentroCosto(id: 'centro-otro', codigo: 'CO', nombre: 'Centro Otro'),
];

final _registro = RegistroPendiente(
  id: 'registro-1',
  empresaId: 'empresa-id',
  usuarioId: 'usuario-1',
  email: 'ana@carrousel.test',
  nombreCompleto: 'Ana Pérez',
  estado: EstadoRegistro.pendiente,
  creadoEn: DateTime(2026, 11, 17, 8),
);

class _RepoFalso implements EquipoRepository {
  final aprobaciones = <Map<String, Object?>>[];

  @override
  Future<List<RegistroPendiente>> registrosPendientes() async => [_registro];

  @override
  Future<void> aprobarRegistro({
    required String registroId,
    required String centroCostoId,
    String? puestoId,
  }) async {
    aprobaciones.add({
      'registroId': registroId,
      'centroCostoId': centroCostoId,
    });
  }

  @override
  Future<void> rechazarRegistro({
    required String registroId,
    required String motivo,
  }) async => throw UnimplementedError();

  @override
  Future<List<CumplimientoJornada>> cumplimiento() async => [];

  @override
  Future<void> ajustarJornada({
    required String jornadaId,
    required DateTime entradaEn,
    required DateTime salidaEn,
    required String motivo,
  }) async => throw UnimplementedError();

  @override
  Future<List<AjusteJornada>> ajustesJornada(String jornadaId) async => [];

  @override
  Future<List<ReporteHorasExtras>> reporteHorasExtras() async => [];

  @override
  Future<List<MiembroEquipo>> miembros() async => [];

  @override
  Future<void> agregarCentroLugar({
    required String empresaId,
    required String parqueId,
    required String centroCostoId,
  }) async => throw UnimplementedError();

  @override
  Future<void> cambiarActivoCentroLugar({
    required String enlaceId,
    required bool activo,
  }) async => throw UnimplementedError();
}

Widget _app(_RepoFalso repo) {
  return ProviderScope(
    overrides: [
      perfilProvider.overrideWith((ref) async => _admin),
      centrosProvider.overrideWith((ref) async => _centros),
      equipoRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(home: Scaffold(body: RegistrosPendientesPage())),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('el selector solo ofrece el subárbol del administrador', (
    tester,
  ) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    final boton = find.widgetWithText(FilledButton, 'Aprobar').first;
    await tester.ensureVisible(boton);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await tester.pumpAndSettle();

    final dropdown = tester
        .widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>))
        .single;
    final visibles = dropdown.items!.map((item) => item.value).toList();
    expect(visibles, containsAll(['centro-admin', 'centro-hijo']));
    expect(visibles, isNot(contains('centro-otro')));
  });

  testWidgets('aprueba con un centro del subárbol', (tester) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    final boton = find.widgetWithText(FilledButton, 'Aprobar').first;
    await tester.ensureVisible(boton);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Centro Hijo').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Aprobar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.aprobaciones, hasLength(1));
    expect(repo.aprobaciones.single['registroId'], 'registro-1');
    expect(repo.aprobaciones.single['centroCostoId'], 'centro-hijo');
  });
}
