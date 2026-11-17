/// Registro inmutable de una corrección administrativa de jornada.
class AjusteJornada {
  const AjusteJornada({
    required this.id,
    required this.jornadaId,
    required this.empleadoId,
    required this.ajustadoPor,
    required this.motivo,
    required this.entradaEnAnterior,
    required this.salidaEnAnterior,
    required this.entradaEnNueva,
    required this.salidaEnNueva,
    required this.creadoEn,
  });

  final String id;
  final String jornadaId;
  final String empleadoId;
  final String ajustadoPor;
  final String motivo;
  final DateTime entradaEnAnterior;
  final DateTime salidaEnAnterior;
  final DateTime entradaEnNueva;
  final DateTime salidaEnNueva;
  final DateTime creadoEn;
}
