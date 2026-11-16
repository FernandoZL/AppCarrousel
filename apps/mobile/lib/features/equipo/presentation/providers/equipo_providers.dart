import 'package:carrousel_app/core/supabase/supabase_provider.dart';
import 'package:carrousel_app/features/equipo/data/repositories/supabase_equipo_repository.dart';
import 'package:carrousel_app/features/equipo/domain/entities/cumplimiento_jornada.dart';
import 'package:carrousel_app/features/equipo/domain/entities/miembro_equipo.dart';
import 'package:carrousel_app/features/equipo/domain/entities/registro_pendiente.dart';
import 'package:carrousel_app/features/equipo/domain/entities/reporte_horas_extras.dart';
import 'package:carrousel_app/features/equipo/domain/repositories/equipo_repository.dart';
import 'package:carrousel_app/features/equipo/domain/usecases/equipo_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final equipoRepositoryProvider = Provider<EquipoRepository>(
  (ref) => SupabaseEquipoRepository(ref.watch(supabaseProvider)),
);

final listarRegistrosPendientesProvider = Provider<ListarRegistrosPendientes>(
  (ref) => ListarRegistrosPendientes(ref.watch(equipoRepositoryProvider)),
);

final aprobarRegistroProvider = Provider<AprobarRegistro>(
  (ref) => AprobarRegistro(ref.watch(equipoRepositoryProvider)),
);

final rechazarRegistroProvider = Provider<RechazarRegistro>(
  (ref) => RechazarRegistro(ref.watch(equipoRepositoryProvider)),
);

final listarCumplimientoProvider = Provider<ListarCumplimiento>(
  (ref) => ListarCumplimiento(ref.watch(equipoRepositoryProvider)),
);

final ajustarJornadaProvider = Provider<AjustarJornada>(
  (ref) => AjustarJornada(ref.watch(equipoRepositoryProvider)),
);

final listarReporteProvider = Provider<ListarReporteHorasExtras>(
  (ref) => ListarReporteHorasExtras(ref.watch(equipoRepositoryProvider)),
);

final listarMiembrosProvider = Provider<ListarMiembros>(
  (ref) => ListarMiembros(ref.watch(equipoRepositoryProvider)),
);

final agregarCentroLugarProvider = Provider<AgregarCentroLugar>(
  (ref) => AgregarCentroLugar(ref.watch(equipoRepositoryProvider)),
);

final cambiarCentroLugarProvider = Provider<CambiarActivoCentroLugar>(
  (ref) => CambiarActivoCentroLugar(ref.watch(equipoRepositoryProvider)),
);

final registrosPendientesProvider =
    FutureProvider.autoDispose<List<RegistroPendiente>>((ref) async {
      return ref.watch(listarRegistrosPendientesProvider)();
    });

final cumplimientoProvider =
    FutureProvider.autoDispose<List<CumplimientoJornada>>((ref) async {
      return ref.watch(listarCumplimientoProvider)();
    });

final reporteHorasExtrasProvider =
    FutureProvider.autoDispose<List<ReporteHorasExtras>>((ref) async {
      return ref.watch(listarReporteProvider)();
    });

final miembrosEquipoProvider = FutureProvider.autoDispose<List<MiembroEquipo>>((
  ref,
) async {
  return ref.watch(listarMiembrosProvider)();
});
