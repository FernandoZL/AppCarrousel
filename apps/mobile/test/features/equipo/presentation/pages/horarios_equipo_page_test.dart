import 'package:carrousel_app/features/auth/domain/entities/perfil.dart';
import 'package:carrousel_app/features/auth/domain/entities/rol_usuario.dart';
import 'package:carrousel_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:carrousel_app/features/equipo/domain/entities/miembro_equipo.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/horarios_equipo_page.dart';
import 'package:carrousel_app/features/equipo/presentation/providers/equipo_providers.dart';
import 'package:carrousel_app/features/horario/domain/entities/horario.dart';
import 'package:carrousel_app/features/horario/domain/repositories/horario_repository.dart';
import 'package:carrousel_app/features/horario/domain/usecases/horario_usecases.dart';
import 'package:carrousel_app/features/horario/presentation/providers/horario_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _admin = Perfil(
  id: 'admin-id',
  empresaId: 'empresa-id',
  centroCostoId: 'centro-id',
  rol: RolUsuario.admin,
  nombreCompleto: 'Admin Carrousel',
);

const _miembro = MiembroEquipo(
  id: 'empleado-id',
  empresaId: 'empresa-id',
  centroCostoId: 'centro-id',
  nombreCompleto: 'Ana Pérez',
  rol: 'empleado',
  activo: true,
);

class _RepoFalso implements HorarioRepository {
  final guardados = <Map<String, Object?>>[];

  @override
  Future<List<Horario>> horariosDe(String empleadoId) async => const [];

  @override
  Future<void> guardar({
    required String empresaId,
    required String empleadoId,
    required int diaSemana,
    required String horaEntrada,
    required String horaSalida,
    required int toleranciaEntradaMin,
    required int toleranciaSalidaMin,
    String? horarioId,
  }) async {
    guardados.add({
      'toleranciaEntradaMin': toleranciaEntradaMin,
      'toleranciaSalidaMin': toleranciaSalidaMin,
    });
  }

  @override
  Future<void> eliminar(String horarioId) async {}
}

Widget _app(_RepoFalso repo) {
  return ProviderScope(
    overrides: [
      perfilProvider.overrideWith((ref) async => _admin),
      miembrosEquipoProvider.overrideWith((ref) async => [_miembro]),
      horariosEmpleadoProvider.overrideWith((ref, id) async => const []),
      guardarHorarioProvider.overrideWithValue(GuardarHorario(repo)),
    ],
    child: const MaterialApp(home: Scaffold(body: HorariosEquipoPage())),
  );
}

Future<void> _abrirDialogo(WidgetTester tester) async {
  final boton = find.byTooltip('Agregar horario').first;
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('acepta tolerancias de hasta 240 minutos como la base', (
    tester,
  ) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _abrirDialogo(tester);

    final campos = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campos.at(0), '200');
    await tester.enterText(campos.at(1), '240');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Guardar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.guardados, hasLength(1));
    expect(repo.guardados.single['toleranciaEntradaMin'], 200);
    expect(repo.guardados.single['toleranciaSalidaMin'], 240);
  });

  testWidgets('rechaza una tolerancia por encima de 240 minutos', (
    tester,
  ) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _abrirDialogo(tester);

    final campos = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campos.at(1), '241');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Guardar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('La tolerancia de salida debe estar entre 0 y 240.'),
      findsOneWidget,
    );
    expect(repo.guardados, isEmpty);
  });
}
