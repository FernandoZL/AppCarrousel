import 'package:carrousel_app/features/equipo/domain/entities/cumplimiento_jornada.dart';
import 'package:carrousel_app/features/equipo/domain/entities/miembro_equipo.dart';
import 'package:carrousel_app/features/equipo/domain/entities/registro_pendiente.dart';
import 'package:carrousel_app/features/equipo/domain/entities/reporte_horas_extras.dart';

/// Operaciones administrativas del equipo.
abstract class EquipoRepository {
  Future<List<RegistroPendiente>> registrosPendientes();

  Future<void> aprobarRegistro({
    required String registroId,
    required String centroCostoId,
    String? puestoId,
  });

  Future<void> rechazarRegistro({
    required String registroId,
    required String motivo,
  });

  Future<List<CumplimientoJornada>> cumplimiento();

  Future<void> ajustarJornada({
    required String jornadaId,
    required DateTime entradaEn,
    required DateTime salidaEn,
    required String motivo,
  });

  Future<List<ReporteHorasExtras>> reporteHorasExtras();

  Future<List<MiembroEquipo>> miembros();

  Future<void> agregarCentroLugar({
    required String empresaId,
    required String parqueId,
    required String centroCostoId,
  });

  Future<void> cambiarActivoCentroLugar({
    required String enlaceId,
    required bool activo,
  });
}
