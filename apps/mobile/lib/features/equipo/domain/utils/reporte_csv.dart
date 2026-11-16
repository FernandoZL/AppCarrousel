import 'package:carrousel_app/features/equipo/domain/entities/reporte_horas_extras.dart';

/// CSV del reporte de horas extras listo para pegar en una hoja de cálculo.
String reporteHorasExtrasCsv(List<ReporteHorasExtras> filas) {
  final buffer = StringBuffer();
  buffer.writeln(
    [
      'Empleado',
      'Centro de costo',
      'Lugar',
      'Inicio',
      'Fin',
      'Horas',
      'Estado',
      'Revisor',
      'Comentario',
    ].map(_campo).join(','),
  );

  for (final fila in filas) {
    buffer.writeln(
      [
        fila.empleado,
        fila.centroNombre,
        fila.parqueNombre ?? '',
        fila.inicio.toIso8601String(),
        fila.fin.toIso8601String(),
        fila.horas.toStringAsFixed(2),
        fila.estado.etiqueta,
        fila.revisor ?? '',
        fila.comentarioAdmin ?? '',
      ].map(_campo).join(','),
    );
  }

  return buffer.toString();
}

String _campo(String valor) {
  final escapado = valor.replaceAll('"', '""');
  return '"$escapado"';
}
