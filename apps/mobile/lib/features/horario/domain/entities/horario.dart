/// Horario semanal de un empleado para un día ISO.
///
/// `horaEntrada` y `horaSalida` usan el formato `HH:mm`. Una salida menor o
/// igual a la entrada representa un turno nocturno que cruza medianoche.
class Horario {
  const Horario({
    required this.id,
    required this.empresaId,
    required this.empleadoId,
    required this.diaSemana,
    required this.horaEntrada,
    required this.horaSalida,
    required this.toleranciaEntradaMin,
    required this.toleranciaSalidaMin,
    required this.activo,
  });

  final String id;
  final String empresaId;
  final String empleadoId;

  /// Día ISO: 1 = lunes … 7 = domingo.
  final int diaSemana;
  final String horaEntrada;
  final String horaSalida;
  final int toleranciaEntradaMin;
  final int toleranciaSalidaMin;
  final bool activo;

  int get minutosEntrada => _minutosDeHora(horaEntrada);

  int get minutosSalida => _minutosDeHora(horaSalida);

  bool get nocturno => minutosSalida <= minutosEntrada;

  int get duracionMinutos => nocturno
      ? 1440 - minutosEntrada + minutosSalida
      : minutosSalida - minutosEntrada;

  Duration get duracion => Duration(minutes: duracionMinutos);
}

int _minutosDeHora(String hora) {
  final partes = hora.split(':');
  if (partes.length < 2) return 0;
  final horas = int.tryParse(partes[0]) ?? 0;
  final minutos = int.tryParse(partes[1]) ?? 0;
  return (horas * 60 + minutos).clamp(0, 1439);
}
