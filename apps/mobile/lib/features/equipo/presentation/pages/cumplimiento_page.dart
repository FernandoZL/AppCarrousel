import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carrousel_app/core/errors/error_messages.dart';
import 'package:carrousel_app/core/utils/duraciones.dart';
import 'package:carrousel_app/core/utils/selectores_fecha.dart';
import 'package:carrousel_app/core/widgets/estado_widgets.dart';
import 'package:carrousel_app/features/equipo/domain/entities/cumplimiento_jornada.dart';
import 'package:carrousel_app/features/equipo/presentation/providers/equipo_providers.dart';
import 'package:carrousel_app/features/equipo/presentation/widgets/historial_ajustes_dialog.dart';

/// Cumplimiento de las jornadas del equipo: horario programado, minutos de
/// diferencia, incidencias automáticas y corrección administrativa.
class CumplimientoPage extends ConsumerStatefulWidget {
  const CumplimientoPage({super.key});

  @override
  ConsumerState<CumplimientoPage> createState() => _CumplimientoPageState();
}

class _CumplimientoPageState extends ConsumerState<CumplimientoPage> {
  TipoIncidencia? _filtro;

  Future<void> _ajustar(CumplimientoJornada jornada) async {
    final resultado = await showDialog<_AjusteJornada>(
      context: context,
      builder: (_) => _DialogoAjuste(jornada: jornada),
    );
    if (resultado == null || !mounted) return;

    try {
      await ref.read(ajustarJornadaProvider)(
        jornadaId: jornada.id,
        entradaEn: resultado.entrada,
        salidaEn: resultado.salida,
        motivo: resultado.motivo,
      );
      ref.invalidate(cumplimientoProvider);
      ref.invalidate(ajustesJornadaProvider(jornada.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Jornada ajustada. El historial quedó registrado.'),
          ),
        );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
    }
  }

  Future<void> _verHistorial(CumplimientoJornada jornada) async {
    try {
      final ajustes = await ref.read(ajustesJornadaProvider(jornada.id).future);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) =>
            HistorialAjustesDialog(jornada: jornada, ajustes: ajustes),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cumplimientoAsync = ref.watch(cumplimientoProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(cumplimientoProvider);
        await ref.read(cumplimientoProvider.future);
      },
      child: cumplimientoAsync.when(
        loading: () =>
            const CargandoWidget(mensaje: 'Cargando jornadas del equipo...'),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: MensajeError(
                mensaje: 'No se pudo cargar el cumplimiento de jornadas.',
                onReintentar: () => ref.invalidate(cumplimientoProvider),
              ),
            ),
          ],
        ),
        data: (jornadas) {
          final filtradas = _filtro == null
              ? jornadas
              : jornadas
                    .where((jornada) => jornada.incidencias.contains(_filtro))
                    .toList(growable: false);
          final conIncidencia = jornadas
              .where((jornada) => jornada.tieneIncidencias)
              .length;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(
                'Jornadas del equipo',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                jornadas.isEmpty
                    ? 'Aún no hay jornadas registradas en tu subárbol.'
                    : '${jornadas.length} jornadas · $conIncidencia con incidencias.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FiltroChip(
                      etiqueta: 'Todas',
                      seleccionado: _filtro == null,
                      onTap: () => setState(() => _filtro = null),
                    ),
                    for (final tipo in TipoIncidencia.values)
                      _FiltroChip(
                        etiqueta: tipo.etiqueta,
                        seleccionado: _filtro == tipo,
                        onTap: () => setState(
                          () => _filtro = _filtro == tipo ? null : tipo,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (filtradas.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: EstadoVacio(
                    icono: Icons.fact_check_outlined,
                    titulo: 'Sin jornadas para mostrar',
                    mensaje: 'Prueba con otro filtro o espera a que el equipo marque su jornada.',
                  ),
                )
              else
                for (final jornada in filtradas)
                  _TarjetaCumplimiento(
                    jornada: jornada,
                    onAjustar: () => _ajustar(jornada),
                    onVerHistorial: () => _verHistorial(jornada),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.etiqueta,
    required this.seleccionado,
    required this.onTap,
  });

  final String etiqueta;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(etiqueta),
        selected: seleccionado,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _TarjetaCumplimiento extends StatelessWidget {
  const _TarjetaCumplimiento({
    required this.jornada,
    required this.onAjustar,
    required this.onVerHistorial,
  });

  final CumplimientoJornada jornada;
  final VoidCallback onAjustar;
  final VoidCallback onVerHistorial;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final rango = jornada.salidaEn == null
        ? '${formatearHora(jornada.entradaEn)} - en curso'
        : '${formatearHora(jornada.entradaEn)} - '
              '${formatearHora(jornada.salidaEn!)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colores.outlineVariant, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jornada.empleado,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatearFecha(jornada.entradaEn)}'
                      '${jornada.parqueNombre == null ? '' : ' · ${jornada.parqueNombre}'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: jornada.abierta
                      ? colores.secondaryContainer
                      : colores.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  jornada.abierta
                      ? 'Abierta'
                      : '${jornada.horas.toStringAsFixed(2)} h',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: jornada.abierta
                        ? colores.onSecondaryContainer
                        : colores.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: colores.primary),
              const SizedBox(width: 6),
              Text(rango, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (jornada.horaEntradaProgramada != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Programado ${jornada.horaEntradaProgramada} - '
                    '${jornada.horaSalidaProgramada ?? '--:--'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colores.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (jornada.minutosTarde != null && jornada.minutosTarde! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Llegó ${jornada.minutosTarde} min tarde.',
                style: TextStyle(fontSize: 12, color: colores.error),
              ),
            ),
          if (jornada.minutosTemprano != null && jornada.minutosTemprano! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Salió ${jornada.minutosTemprano} min antes.',
                style: TextStyle(fontSize: 12, color: colores.error),
              ),
            ),
          if (jornada.tieneIncidencias) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final incidencia in jornada.incidencias)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colores.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      incidencia.etiqueta,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colores.onErrorContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onVerHistorial,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42)),
                icon: const Icon(Icons.history_rounded, size: 18),
                label: const Text('Historial'),
              ),
              if (jornada.puedeAjustar) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onAjustar,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                  ),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Ajustar jornada'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AjusteJornada {
  const _AjusteJornada({
    required this.entrada,
    required this.salida,
    required this.motivo,
  });

  final DateTime entrada;
  final DateTime salida;
  final String motivo;
}

class _DialogoAjuste extends StatefulWidget {
  const _DialogoAjuste({required this.jornada});

  final CumplimientoJornada jornada;

  @override
  State<_DialogoAjuste> createState() => _DialogoAjusteState();
}

class _DialogoAjusteState extends State<_DialogoAjuste> {
  final _motivo = TextEditingController();
  late DateTime _entrada;
  late DateTime _salida;
  String? _error;

  @override
  void initState() {
    super.initState();
    _entrada = widget.jornada.entradaEn;
    _salida = widget.jornada.salidaEn ?? _entrada;
  }

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _editar({required bool entrada}) async {
    final valor = await elegirFechaHora(
      context,
      entrada ? _entrada : _salida,
      ayudaFecha: entrada ? 'Entrada corregida' : 'Salida corregida',
    );
    if (valor == null || !mounted) return;
    setState(() {
      if (entrada) {
        _entrada = valor;
      } else {
        _salida = valor;
      }
    });
  }

  void _confirmar() {
    final texto = _motivo.text.trim();
    if (!_salida.isAfter(_entrada)) {
      setState(() => _error = 'La salida debe ser posterior a la entrada.');
      return;
    }
    if (texto.length < 10) {
      setState(() => _error = 'Explica el ajuste en al menos 10 caracteres.');
      return;
    }
    if (texto.length > 2000) {
      setState(() => _error = 'El motivo no puede superar 2000 caracteres.');
      return;
    }
    Navigator.of(context)
        .pop(_AjusteJornada(entrada: _entrada, salida: _salida, motivo: texto));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajustar jornada'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.jornada.empleado,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _BotonFecha(
              etiqueta: 'Entrada',
              fecha: _entrada,
              onTap: () => _editar(entrada: true),
            ),
            const SizedBox(height: 8),
            _BotonFecha(
              etiqueta: 'Salida',
              fecha: _salida,
              onTap: () => _editar(entrada: false),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _motivo,
              minLines: 3,
              maxLines: 6,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Motivo del ajuste',
                alignLabelWithHint: true,
                errorText: _error,
              ),
            ),
            const Text(
              'El ajuste no valida la geocerca y deja historial inmutable.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Guardar ajuste'),
        ),
      ],
    );
  }
}

class _BotonFecha extends StatelessWidget {
  const _BotonFecha({
    required this.etiqueta,
    required this.fecha,
    required this.onTap,
  });

  final String etiqueta;
  final DateTime fecha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colores.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded, size: 18, color: colores.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$etiqueta: ${formatearFecha(fecha)} · ${formatearHora(fecha)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const Icon(Icons.edit_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
