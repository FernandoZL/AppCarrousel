import 'package:carrousel_app/core/utils/duraciones.dart';

/// Jornada de trabajo de un empleado.
class Jornada {
  const Jornada({
    required this.id,
    required this.empresaId,
    required this.empleadoId,
    required this.parqueId,
    required this.entradaEn,
    required this.entradaDentroGeocerca,
    this.salidaEn,
    this.salidaDentroGeocerca,
    this.entradaParqueLat,
    this.entradaParqueLon,
    this.entradaParqueRadioMetros,
  });

  final String id;
  final String empresaId;
  final String empleadoId;
  final String parqueId;
  final DateTime entradaEn;
  final DateTime? salidaEn;
  final bool entradaDentroGeocerca;
  final bool? salidaDentroGeocerca;

  /// Foto de la geocerca tomada al entrar. La base la usa para validar la
  /// salida aunque el parque se haya movido o redimensionado durante el turno.
  final double? entradaParqueLat;
  final double? entradaParqueLon;
  final double? entradaParqueRadioMetros;

  bool get abierta => salidaEn == null;

  Duration duracionHasta(DateTime ahora) =>
      (salidaEn ?? ahora).difference(entradaEn);

  String get rangoTexto {
    final inicio = formatearHora(entradaEn);
    final fin = salidaEn == null ? 'en curso' : formatearHora(salidaEn!);
    return '$inicio - $fin';
  }
}
