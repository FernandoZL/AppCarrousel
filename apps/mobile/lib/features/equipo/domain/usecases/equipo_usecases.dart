import 'package:carrousel_app/features/equipo/domain/entities/cumplimiento_jornada.dart';
import 'package:carrousel_app/features/equipo/domain/entities/miembro_equipo.dart';
import 'package:carrousel_app/features/equipo/domain/entities/registro_pendiente.dart';
import 'package:carrousel_app/features/equipo/domain/entities/reporte_horas_extras.dart';
import 'package:carrousel_app/features/equipo/domain/repositories/equipo_repository.dart';

class ListarRegistrosPendientes {
  const ListarRegistrosPendientes(this._repo);

  final EquipoRepository _repo;

  Future<List<RegistroPendiente>> call() => _repo.registrosPendientes();
}

class AprobarRegistro {
  const AprobarRegistro(this._repo);

  final EquipoRepository _repo;

  Future<void> call({
    required String registroId,
    required String centroCostoId,
    String? puestoId,
  }) => _repo.aprobarRegistro(
    registroId: registroId,
    centroCostoId: centroCostoId,
    puestoId: puestoId,
  );
}

class RechazarRegistro {
  const RechazarRegistro(this._repo);

  final EquipoRepository _repo;

  Future<void> call({required String registroId, required String motivo}) =>
      _repo.rechazarRegistro(registroId: registroId, motivo: motivo);
}

class ListarCumplimiento {
  const ListarCumplimiento(this._repo);

  final EquipoRepository _repo;

  Future<List<CumplimientoJornada>> call() => _repo.cumplimiento();
}

class AjustarJornada {
  const AjustarJornada(this._repo);

  final EquipoRepository _repo;

  Future<void> call({
    required String jornadaId,
    required DateTime entradaEn,
    required DateTime salidaEn,
    required String motivo,
  }) => _repo.ajustarJornada(
    jornadaId: jornadaId,
    entradaEn: entradaEn,
    salidaEn: salidaEn,
    motivo: motivo,
  );
}

class ListarReporteHorasExtras {
  const ListarReporteHorasExtras(this._repo);

  final EquipoRepository _repo;

  Future<List<ReporteHorasExtras>> call() => _repo.reporteHorasExtras();
}

class ListarMiembros {
  const ListarMiembros(this._repo);

  final EquipoRepository _repo;

  Future<List<MiembroEquipo>> call() => _repo.miembros();
}

class AgregarCentroLugar {
  const AgregarCentroLugar(this._repo);

  final EquipoRepository _repo;

  Future<void> call({
    required String empresaId,
    required String parqueId,
    required String centroCostoId,
  }) => _repo.agregarCentroLugar(
    empresaId: empresaId,
    parqueId: parqueId,
    centroCostoId: centroCostoId,
  );
}

class CambiarActivoCentroLugar {
  const CambiarActivoCentroLugar(this._repo);

  final EquipoRepository _repo;

  Future<void> call({required String enlaceId, required bool activo}) =>
      _repo.cambiarActivoCentroLugar(enlaceId: enlaceId, activo: activo);
}
