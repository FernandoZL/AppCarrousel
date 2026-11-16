import 'package:flutter/material.dart';

/// Pide una fecha y luego una hora. Devuelve `null` si el usuario cancela
/// cualquiera de los dos pasos.
Future<DateTime?> elegirFechaHora(
  BuildContext context,
  DateTime actual, {
  String ayudaFecha = 'Fecha',
  String ayudaHora = 'Hora',
}) async {
  final ahora = DateTime.now();
  final fecha = await showDatePicker(
    context: context,
    initialDate: actual,
    firstDate: DateTime(ahora.year - 2),
    lastDate: DateTime(ahora.year + 2, 12, 31),
    helpText: ayudaFecha,
  );
  if (fecha == null || !context.mounted) return null;

  final hora = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(actual),
    helpText: ayudaHora,
  );
  if (hora == null) return null;

  return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
}

/// Pide solo una hora del día y la devuelve como texto `HH:mm`.
Future<String?> elegirHoraTexto(
  BuildContext context,
  String actual, {
  String ayuda = 'Hora',
}) async {
  final partes = actual.split(':');
  final inicial = TimeOfDay(
    hour: int.tryParse(partes.isNotEmpty ? partes[0] : '') ?? 8,
    minute: int.tryParse(partes.length > 1 ? partes[1] : '') ?? 0,
  );
  final hora = await showTimePicker(
    context: context,
    initialTime: inicial,
    helpText: ayuda,
  );
  if (hora == null) return null;
  return '${hora.hour.toString().padLeft(2, '0')}:'
      '${hora.minute.toString().padLeft(2, '0')}';
}
