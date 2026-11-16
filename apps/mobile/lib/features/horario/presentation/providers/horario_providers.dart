import 'package:carrousel_app/core/supabase/supabase_provider.dart';
import 'package:carrousel_app/features/horario/data/repositories/supabase_horario_repository.dart';
import 'package:carrousel_app/features/horario/domain/entities/horario.dart';
import 'package:carrousel_app/features/horario/domain/repositories/horario_repository.dart';
import 'package:carrousel_app/features/horario/domain/usecases/horario_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final horarioRepositoryProvider = Provider<HorarioRepository>(
  (ref) => SupabaseHorarioRepository(ref.watch(supabaseProvider)),
);

final listarHorariosProvider = Provider<ListarHorarios>(
  (ref) => ListarHorarios(ref.watch(horarioRepositoryProvider)),
);

final guardarHorarioProvider = Provider<GuardarHorario>(
  (ref) => GuardarHorario(ref.watch(horarioRepositoryProvider)),
);

final eliminarHorarioProvider = Provider<EliminarHorario>(
  (ref) => EliminarHorario(ref.watch(horarioRepositoryProvider)),
);

final horariosEmpleadoProvider = FutureProvider.autoDispose
    .family<List<Horario>, String>(
      (ref, empleadoId) => ref.watch(listarHorariosProvider)(empleadoId),
    );
