import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carrousel_app/core/widgets/estado_widgets.dart';
import 'package:carrousel_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:carrousel_app/features/horario/domain/entities/horario.dart';
import 'package:carrousel_app/features/horario/domain/utils/horarios.dart';
import 'package:carrousel_app/features/horario/presentation/providers/horario_providers.dart';

/// Horario semanal del usuario autenticado.
class MiHorarioPage extends ConsumerWidget {
  const MiHorarioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilProvider).valueOrNull;

    if (perfil == null) {
      return const CargandoWidget(mensaje: 'Cargando tu horario...');
    }

    final horariosAsync = ref.watch(horariosEmpleadoProvider(perfil.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(horariosEmpleadoProvider(perfil.id));
        await ref.read(horariosEmpleadoProvider(perfil.id).future);
      },
      child: horariosAsync.when(
        loading: () => const CargandoWidget(mensaje: 'Cargando tu horario...'),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.6,
              child: MensajeError(
                mensaje: 'No se pudo cargar tu horario.',
                onReintentar: () =>
                    ref.invalidate(horariosEmpleadoProvider(perfil.id)),
              ),
            ),
          ],
        ),
        data: (horarios) {
          final porDia = {
            for (final horario in horarios) horario.diaSemana: horario,
          };
          final activos = horarios.where((horario) => horario.activo).length;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                'Mi horario',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                activos == 0
                    ? 'Tu administrador aún no ha definido tu horario semanal.'
                    : 'Tu horario vigente tiene $activos ${activos == 1 ? 'día laboral' : 'días laborales'}.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              for (var dia = 1; dia <= 7; dia++)
                _DiaHorario(dia: dia, horario: porDia[dia]),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Las horas se interpretan en la zona horaria de tu empresa. '
                        'Si un turno termina antes de empezar, se considera nocturno '
                        'y cierra al día siguiente.',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DiaHorario extends StatelessWidget {
  const _DiaHorario({required this.dia, required this.horario});

  final int dia;
  final Horario? horario;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final horarioActual = horario;
    final activo = horarioActual?.activo ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colores.outlineVariant, width: 0.7),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: activo
                  ? colores.primaryContainer
                  : colores.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              activo ? Icons.schedule_rounded : Icons.bedtime_outlined,
              size: 20,
              color: activo
                  ? colores.onPrimaryContainer
                  : colores.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      nombreDia(dia),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (horarioActual?.nocturno ?? false) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colores.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Nocturno',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: colores.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  horarioActual == null
                      ? 'Descanso'
                      : activo
                      ? '${describirTurno(horarioActual)} · ${duracionTurno(horarioActual)}'
                      : 'Horario inactivo',
                  style: TextStyle(
                    fontSize: 13,
                    color: colores.onSurfaceVariant,
                  ),
                ),
                if (horarioActual != null && activo) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tolerancia ${horarioActual.toleranciaEntradaMin} min al entrar y '
                    '${horarioActual.toleranciaSalidaMin} min al salir',
                    style: TextStyle(
                      fontSize: 11,
                      color: colores.onSurfaceVariant.withAlpha(210),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
