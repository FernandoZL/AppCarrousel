import 'package:carrousel_app/features/horario/domain/entities/horario.dart';

const diasSemanaEtiquetas = <String>[
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

/// Día ISO (1 = lunes … 7 = domingo) a etiqueta en español.
String nombreDia(int diaSemana) {
  if (diaSemana < 1 || diaSemana > 7) return 'Día $diaSemana';
  return diasSemanaEtiquetas[diaSemana - 1];
}

/// Convierte `HH:mm` o `HH:mm:ss` a `HH:mm`. Devuelve `--:--` si no es válido.
String normalizarHora(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return '--:--';
  final partes = texto.split(':');
  if (partes.length < 2) return '--:--';
  final hora = int.tryParse(partes[0]);
  final minuto = int.tryParse(partes[1]);
  if (hora == null || minuto == null) return '--:--';
  if (hora < 0 || hora > 23 || minuto < 0 || minuto > 59) return '--:--';
  return '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
}

/// `HH:mm` a la hora del día en minutos desde medianoche.
int minutosDeHora(String? valor) {
  final normalizada = normalizarHora(valor);
  if (normalizada == '--:--') return 0;
  final partes = normalizada.split(':');
  return int.parse(partes[0]) * 60 + int.parse(partes[1]);
}

/// Minutos desde medianoche a `HH:mm`.
String horaDeMinutos(int minutos) {
  final normalizado = minutos % 1440;
  final hora = normalizado ~/ 60;
  final minuto = normalizado % 60;
  return '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
}

/// Texto compacto del turno, con aviso de que cruza medianoche.
String describirTurno(Horario horario) {
  final turno = '${horario.horaEntrada} - ${horario.horaSalida}';
  return horario.nocturno ? '$turno (+1 día)' : turno;
}

/// Horas y minutos legibles para la duración del turno.
String duracionTurno(Horario horario) {
  final horas = horario.duracionMinutos ~/ 60;
  final minutos = horario.duracionMinutos % 60;
  if (minutos == 0) return '$horas h';
  return '$horas h ${minutos.toString().padLeft(2, '0')} min';
}
