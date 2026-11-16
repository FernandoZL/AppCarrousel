import 'package:carrousel_app/features/equipo/domain/entities/reporte_horas_extras.dart';
import 'package:carrousel_app/features/equipo/domain/utils/reporte_csv.dart';
import 'package:carrousel_app/features/solicitudes/domain/entities/solicitud_horas_extras.dart';
import 'package:flutter_test/flutter_test.dart';

ReporteHorasExtras fila({
  String empleado = 'Ana Pérez',
  String centro = 'Operaciones',
  String? parque,
  double horas = 2.5,
  EstadoSolicitud estado = EstadoSolicitud.aprobada,
  String? revisor,
  String? comentario,
}) {
  return ReporteHorasExtras(
    id: 'r1',
    empresaId: 'e1',
    empleadoId: 'u1',
    empleado: empleado,
    centroCostoId: 'c1',
    centroNombre: centro,
    inicio: DateTime.utc(2026, 11, 10, 9),
    fin: DateTime.utc(2026, 11, 10, 11, 30),
    horas: horas,
    estado: estado,
    creadoEn: DateTime.utc(2026, 11, 10, 8),
    parqueNombre: parque,
    revisor: revisor,
    comentarioAdmin: comentario,
  );
}

void main() {
  test('genera encabezado y una fila con todos los campos', () {
    final csv = reporteHorasExtrasCsv([
      fila(
        parque: 'Parque Central',
        revisor: 'Luis Admin',
        comentario: 'Todo en orden',
      ),
    ]);
    final lineas = csv.trimRight().split('\n');

    expect(lineas, hasLength(2));
    expect(
      lineas.first,
      '"Empleado","Centro de costo","Lugar","Inicio","Fin","Horas","Estado","Revisor","Comentario"',
    );
    expect(lineas[1], contains('"Ana Pérez"'));
    expect(lineas[1], contains('"Parque Central"'));
    expect(lineas[1], contains('"2.50"'));
    expect(lineas[1], contains('"Aprobada"'));
    expect(lineas[1], contains('"Luis Admin"'));
    expect(lineas[1], contains('"Todo en orden"'));
  });

  test('escapa comillas y deja celdas vacías cuando falta el dato', () {
    final csv = reporteHorasExtrasCsv([
      fila(empleado: 'Ana "La Jefa" Pérez', estado: EstadoSolicitud.pendiente),
    ]);
    final filaCsv = csv.trimRight().split('\n')[1];

    expect(filaCsv, contains('"Ana ""La Jefa"" Pérez"'));
    expect(filaCsv, contains('"Pendiente"'));
    expect(filaCsv, contains(',"",'));
  });

  test('sin filas solo emite el encabezado', () {
    final csv = reporteHorasExtrasCsv(const []);
    expect(csv.trimRight().split('\n'), hasLength(1));
  });
}
