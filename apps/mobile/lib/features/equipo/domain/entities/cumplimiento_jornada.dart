enum TipoIncidencia {
  llegadaTarde('llegada_tarde', 'Llegada tarde'),
  salidaTemprana('salida_temprana', 'Salida temprana'),
  parqueDistinto('parque_distinto', 'Parque distinto'),
  gpsImpreciso('gps_impreciso', 'GPS impreciso');

  const TipoIncidencia(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  static TipoIncidencia? parse(String? valor) {
    for (final tipo in values) {
      if (tipo.valor == valor) return tipo;
    }
    return null;
  }
}

/// Jornada con su horario programado y las incidencias calculadas.
class CumplimientoJornada {
  const CumplimientoJornada({
    required this.id,
    required this.empresaId,
    required this.empleadoId,
    required this.empleado,
    required this.entradaEn,
    required this.abierta,
    required this.horas,
    required this.incidencias,
    this.parqueId,
    this.parqueNombre,
    this.salidaEn,
    this.horaEntradaProgramada,
    this.horaSalidaProgramada,
    this.toleranciaEntradaMin,
    this.toleranciaSalidaMin,
    this.minutosTarde,
    this.minutosTemprano,
  });

  final String id;
  final String empresaId;
  final String empleadoId;
  final String empleado;
  final DateTime entradaEn;
  final bool abierta;
  final double horas;
  final List<TipoIncidencia> incidencias;
  final String? parqueId;
  final String? parqueNombre;
  final DateTime? salidaEn;
  final String? horaEntradaProgramada;
  final String? horaSalidaProgramada;
  final int? toleranciaEntradaMin;
  final int? toleranciaSalidaMin;
  final int? minutosTarde;
  final int? minutosTemprano;

  bool get tieneIncidencias => incidencias.isNotEmpty;

  bool get puedeAjustar => !abierta && salidaEn != null;
}
