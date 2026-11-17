/// Configuración operativa de la empresa: zona horaria y umbral de GPS.
class ConfiguracionEmpresa {
  const ConfiguracionEmpresa({
    required this.id,
    required this.nombre,
    required this.zonaHoraria,
    required this.gpsPrecisionMaximaMetros,
  });

  final String id;
  final String nombre;
  final String zonaHoraria;
  final int gpsPrecisionMaximaMetros;
}
