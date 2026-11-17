import 'package:carrousel_app/features/admin/presentation/pages/aprobaciones_page.dart';
import 'package:carrousel_app/features/auth/domain/entities/perfil.dart';
import 'package:carrousel_app/features/auth/domain/entities/rol_usuario.dart';
import 'package:carrousel_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:carrousel_app/features/solicitudes/domain/entities/solicitud_horas_extras.dart';
import 'package:carrousel_app/features/solicitudes/domain/repositories/solicitud_repository.dart';
import 'package:carrousel_app/features/solicitudes/domain/usecases/solicitud_usecases.dart';
import 'package:carrousel_app/features/solicitudes/presentation/providers/solicitud_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _admin = Perfil(
  id: 'admin-id',
  empresaId: 'empresa-id',
  centroCostoId: 'centro-id',
  rol: RolUsuario.admin,
  nombreCompleto: 'Admin Carrousel',
);

final _detalle = SolicitudDetalle(
  solicitud: SolicitudHorasExtras(
    id: 'solicitud-1',
    empresaId: 'empresa-id',
    empleadoId: 'empleado-id',
    centroCostoId: 'centro-id',
    inicio: DateTime(2026, 11, 17, 9),
    fin: DateTime(2026, 11, 17, 11),
    justificacion: 'Apoyo en el parque central durante el evento',
    estado: EstadoSolicitud.pendiente,
    creadoEn: DateTime(2026, 11, 16, 8),
  ),
  empleadoNombre: 'Ana Pérez',
  centroNombre: 'Parque Central',
);

class _RepoFalso implements SolicitudRepository {
  String? solicitudId;
  EstadoSolicitud? decision;
  String? comentario;
  int revisiones = 0;

  @override
  Future<void> crear({
    required String centroCostoId,
    required String parqueId,
    required DateTime inicio,
    required DateTime fin,
    required String justificacion,
  }) async => throw UnimplementedError();

  @override
  Future<void> revisar({
    required String solicitudId,
    required EstadoSolicitud decision,
    String? comentario,
  }) async {
    this.solicitudId = solicitudId;
    this.decision = decision;
    this.comentario = comentario;
    revisiones++;
  }

  @override
  Future<void> cancelar({required String solicitudId}) async =>
      throw UnimplementedError();

  @override
  Stream<List<SolicitudHorasExtras>> observarSolicitudes() =>
      const Stream.empty();
}

Widget _app(_RepoFalso repo) {
  return ProviderScope(
    overrides: [
      perfilProvider.overrideWith((ref) async => _admin),
      solicitudesDetalladasProvider.overrideWith(
        (ref) => AsyncData([_detalle]),
      ),
      revisarSolicitudProvider.overrideWithValue(RevisarSolicitud(repo)),
    ],
    child: const MaterialApp(home: Scaffold(body: AprobacionesPage())),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('aprueba reenviando el comentario literal', (tester) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Aprobar').first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Procede, quedas cubierto.',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Aprobar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.revisiones, 1);
    expect(repo.solicitudId, 'solicitud-1');
    expect(repo.decision, EstadoSolicitud.aprobada);
    expect(repo.comentario, 'Procede, quedas cubierto.');
  });

  testWidgets('rechaza reenviando el motivo', (tester) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Rechazar').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'El rango no coincide con el marcaje.',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Rechazar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.revisiones, 1);
    expect(repo.decision, EstadoSolicitud.rechazada);
    expect(repo.comentario, 'El rango no coincide con el marcaje.');
  });

  testWidgets('cancelar el diálogo no revisa la solicitud', (tester) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Aprobar').first);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancelar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.revisiones, 0);
    expect(repo.decision, isNull);
  });

  testWidgets('el comentario admite hasta 2000 caracteres', (tester) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Aprobar').first);
    await tester.pumpAndSettle();

    final campo = tester.widget<TextField>(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
    );
    expect(campo.maxLength, 2000);
  });
}
