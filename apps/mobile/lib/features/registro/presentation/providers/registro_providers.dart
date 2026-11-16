import 'package:carrousel_app/core/supabase/supabase_provider.dart';
import 'package:carrousel_app/features/registro/data/repositories/supabase_registro_repository.dart';
import 'package:carrousel_app/features/registro/domain/entities/mi_registro.dart';
import 'package:carrousel_app/features/registro/domain/repositories/registro_repository.dart';
import 'package:carrousel_app/features/registro/domain/usecases/registro_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registroRepositoryProvider = Provider<RegistroRepository>(
  (ref) => SupabaseRegistroRepository(ref.watch(supabaseProvider)),
);

final solicitarRegistroProvider = Provider<SolicitarRegistro>(
  (ref) => SolicitarRegistro(ref.watch(registroRepositoryProvider)),
);

final consultarMiRegistroProvider = Provider<ConsultarMiRegistro>(
  (ref) => ConsultarMiRegistro(ref.watch(registroRepositoryProvider)),
);

final miRegistroProvider = FutureProvider.autoDispose<MiRegistro?>(
  (ref) => ref.watch(consultarMiRegistroProvider)(),
);
