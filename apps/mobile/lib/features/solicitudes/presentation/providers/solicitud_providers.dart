import 'package:carrousel_app/core/supabase/supabase_provider.dart';
import 'package:carrousel_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:carrousel_app/features/catalogo/presentation/providers/catalogo_providers.dart';
import 'package:carrousel_app/features/solicitudes/data/repositories/supabase_solicitud_repository.dart';
import 'package:carrousel_app/features/solicitudes/domain/entities/solicitud_horas_extras.dart';
import 'package:carrousel_app/features/solicitudes/domain/repositories/solicitud_repository.dart';
import 'package:carrousel_app/features/solicitudes/domain/usecases/solicitud_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final solicitudRepositoryProvider = Provider<SolicitudRepository>(
  (ref) => SupabaseSolicitudRepository(ref.watch(supabaseProvider)),
);

final crearSolicitudProvider = Provider<CrearSolicitud>(
  (ref) => CrearSolicitud(ref.watch(solicitudRepositoryProvider)),
);

final revisarSolicitudProvider = Provider<RevisarSolicitud>(
  (ref) => RevisarSolicitud(ref.watch(solicitudRepositoryProvider)),
);

final cancelarSolicitudProvider = Provider<CancelarSolicitud>(
  (ref) => CancelarSolicitud(ref.watch(solicitudRepositoryProvider)),
);

final solicitudesStreamProvider =
    StreamProvider.autoDispose<List<SolicitudHorasExtras>>((ref) {
      final sesion = ref.watch(sesionActualProvider);
      if (sesion == null) return const Stream.empty();
      return ObservarSolicitudes(ref.watch(solicitudRepositoryProvider))();
    });

/// Une el stream de Realtime con los nombres de especialistas y centros.
/// Las RLS ya limitan ambos catálogos al ámbito del usuario.
final solicitudesDetalladasProvider =
    Provider.autoDispose<AsyncValue<List<SolicitudDetalle>>>((ref) {
      final solicitudes = ref.watch(solicitudesStreamProvider);
      final nombres = ref.watch(nombresPerfilesProvider);
      final centros = ref.watch(centrosProvider);
      final parques = ref.watch(parquesProvider);

      return solicitudes.when(
        loading: () => const AsyncLoading(),
        error: (error, stack) => AsyncError(error, stack),
        data: (filas) {
          final mapaNombres = nombres.valueOrNull;
          final listaCentros = centros.valueOrNull;
          final listaParques = parques.valueOrNull;
          if (mapaNombres == null ||
              listaCentros == null ||
              listaParques == null) {
            return const AsyncLoading();
          }
          final mapaCentros = {
            for (final centro in listaCentros) centro.id: centro.nombre,
          };
          final mapaParques = {
            for (final parque in listaParques) parque.id: parque.nombre,
          };
          final detalles = filas
              .map((solicitud) {
                return SolicitudDetalle(
                  solicitud: solicitud,
                  empleadoNombre:
                      mapaNombres[solicitud.empleadoId] ?? 'Especialista',
                  centroNombre:
                      mapaCentros[solicitud.centroCostoId] ?? 'Centro de costo',
                  parqueNombre: solicitud.parqueId == null
                      ? null
                      : mapaParques[solicitud.parqueId] ?? 'Lugar',
                );
              })
              .toList(growable: false);
          return AsyncData(detalles);
        },
      );
    });
