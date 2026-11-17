import 'package:carrousel_app/features/equipo/domain/entities/ajuste_jornada.dart';
import 'package:carrousel_app/features/equipo/domain/entities/cumplimiento_jornada.dart';
import 'package:carrousel_app/features/equipo/presentation/widgets/historial_ajustes_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _jornada = CumplimientoJornada(
  id: 'j1',
  empresaId: 'empresa-id',
  empleadoId: 'empleado-id',
  empleado: 'Especialista Carrousel',
  entradaEn: DateTime(2026, 11, 17, 8),
  salidaEn: DateTime(2026, 11, 17, 16),
  abierta: false,
  horas: 8,
  incidencias: const [],
);

Widget _app(List<AjusteJornada> ajustes) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) =>
                HistorialAjustesDialog(jornada: _jornada, ajustes: ajustes),
          ),
          child: const Text('Ver historial'),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('muestra el motivo y los valores anterior y nuevo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app([
        AjusteJornada(
          id: 'a1',
          jornadaId: 'j1',
          empleadoId: 'empleado-id',
          ajustadoPor: 'admin-id',
          motivo: 'Se corrigió la entrada reportada por el lector.',
          entradaEnAnterior: DateTime(2026, 11, 17, 8),
          salidaEnAnterior: DateTime(2026, 11, 17, 16),
          entradaEnNueva: DateTime(2026, 11, 17, 8, 15),
          salidaEnNueva: DateTime(2026, 11, 17, 16, 10),
          creadoEn: DateTime(2026, 11, 17, 18),
        ),
      ]),
    );

    await tester.tap(find.text('Ver historial'));
    await tester.pumpAndSettle();

    expect(find.text('Historial de ajustes'), findsOneWidget);
    expect(find.text('Especialista Carrousel'), findsOneWidget);
    expect(
      find.text('Se corrigió la entrada reportada por el lector.'),
      findsOneWidget,
    );
    expect(find.text('Registrado por un administrador'), findsOneWidget);
  });

  testWidgets('muestra el estado vacío cuando la jornada no tiene ajustes', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const []));

    await tester.tap(find.text('Ver historial'));
    await tester.pumpAndSettle();

    expect(find.text('Sin ajustes'), findsOneWidget);
    expect(find.text('Esta jornada no ha sido corregida.'), findsOneWidget);
  });
}
