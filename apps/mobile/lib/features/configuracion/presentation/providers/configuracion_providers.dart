import 'package:carrousel_app/core/supabase/supabase_provider.dart';
import 'package:carrousel_app/features/configuracion/data/repositories/supabase_configuracion_repository.dart';
import 'package:carrousel_app/features/configuracion/domain/entities/configuracion_empresa.dart';
import 'package:carrousel_app/features/configuracion/domain/repositories/configuracion_repository.dart';
import 'package:carrousel_app/features/configuracion/domain/usecases/configuracion_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final configuracionRepositoryProvider = Provider<ConfiguracionRepository>(
  (ref) => SupabaseConfiguracionRepository(ref.watch(supabaseProvider)),
);

final cargarConfiguracionProvider = Provider<CargarConfiguracion>(
  (ref) => CargarConfiguracion(ref.watch(configuracionRepositoryProvider)),
);

final guardarConfiguracionProvider = Provider<GuardarConfiguracion>(
  (ref) => GuardarConfiguracion(ref.watch(configuracionRepositoryProvider)),
);

final configuracionEmpresaProvider = FutureProvider.autoDispose
    .family<ConfiguracionEmpresa, String>(
      (ref, empresaId) => ref.watch(cargarConfiguracionProvider)(empresaId),
    );
