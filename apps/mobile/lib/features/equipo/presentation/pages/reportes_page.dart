import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carrousel_app/core/utils/duraciones.dart';
import 'package:carrousel_app/core/widgets/estado_widgets.dart';
import 'package:carrousel_app/features/equipo/domain/entities/reporte_horas_extras.dart';
import 'package:carrousel_app/features/equipo/domain/utils/reporte_csv.dart';
import 'package:carrousel_app/features/equipo/presentation/providers/equipo_providers.dart';
import 'package:carrousel_app/features/solicitudes/domain/entities/solicitud_horas_extras.dart';
import 'package:carrousel_app/features/solicitudes/presentation/widgets/solicitud_card.dart';

/// Reporte de horas extras con filtro por estado y exportación a CSV.
class ReportesPage extends ConsumerStatefulWidget {
  const ReportesPage({super.key});

  @override
  ConsumerState<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends ConsumerState<ReportesPage> {
  EstadoSolicitud? _filtro;

  Future<void> _exportar(List<ReporteHorasExtras> filas) async {
    if (filas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay filas para exportar.')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: reporteHorasExtrasCsv(filas)));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'CSV de ${filas.length} ${filas.length == 1 ? 'fila' : 'filas'} '
            'copiado al portapapeles.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final reporteAsync = ref.watch(reporteHorasExtrasProvider);

    return reporteAsync.when(
      loading: () => const CargandoWidget(mensaje: 'Cargando reporte...'),
      error: (error, _) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: MensajeError(
              mensaje: 'No se pudo cargar el reporte de horas extras.',
              onReintentar: () => ref.invalidate(reporteHorasExtrasProvider),
            ),
          ),
        ],
      ),
      data: (filas) {
        final filtradas = _filtro == null
            ? filas
            : filas
                  .where((fila) => fila.estado == _filtro)
                  .toList(growable: false);
        final horasAprobadas = filtradas
            .where((fila) => fila.estado == EstadoSolicitud.aprobada)
            .fold<double>(0, (total, fila) => total + fila.horas);
        final horasPendientes = filtradas
            .where((fila) => fila.estado == EstadoSolicitud.pendiente)
            .fold<double>(0, (total, fila) => total + fila.horas);

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              'Reporte de horas extras',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Incluye las solicitudes visibles para tu subárbol. La exportación '
              'copia un CSV listo para pegar en una hoja de cálculo.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todas'),
                    selected: _filtro == null,
                    onSelected: (_) => setState(() => _filtro = null),
                  ),
                  for (final estado in EstadoSolicitud.values) ...[
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(estado.etiqueta),
                      selected: _filtro == estado,
                      onSelected: (_) => setState(
                        () => _filtro = _filtro == estado ? null : estado,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _TotalTarjeta(
                    etiqueta: 'Filas',
                    valor: '${filtradas.length}',
                    icono: Icons.list_alt_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TotalTarjeta(
                    etiqueta: 'Aprobadas',
                    valor: '${horasAprobadas.toStringAsFixed(2)} h',
                    icono: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TotalTarjeta(
                    etiqueta: 'Pendientes',
                    valor: '${horasPendientes.toStringAsFixed(2)} h',
                    icono: Icons.hourglass_top_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _exportar(filtradas),
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Copiar CSV'),
            ),
            const SizedBox(height: 16),
            if (filtradas.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: EstadoVacio(
                  icono: Icons.table_chart_outlined,
                  titulo: 'Sin resultados',
                  mensaje: 'No hay solicitudes para el filtro seleccionado.',
                ),
              )
            else
              for (final fila in filtradas) _TarjetaReporte(fila: fila),
          ],
        );
      },
    );
  }
}

class _TotalTarjeta extends StatelessWidget {
  const _TotalTarjeta({
    required this.etiqueta,
    required this.valor,
    required this.icono,
  });

  final String etiqueta;
  final String valor;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: colores.primary),
          const SizedBox(height: 6),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          Text(
            etiqueta,
            style: TextStyle(fontSize: 11, color: colores.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _TarjetaReporte extends StatelessWidget {
  const _TarjetaReporte({required this.fila});

  final ReporteHorasExtras fila;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                child: Text(
                  fila.empleado,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              EstadoChip(estado: fila.estado),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            fila.parqueNombre == null
                ? fila.centroNombre
                : '${fila.parqueNombre} · ${fila.centroNombre}',
            style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: colores.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${formatearFecha(fila.inicio)} · '
                  '${formatearHora(fila.inicio)} - ${formatearHora(fila.fin)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Text(
                '${fila.horas.toStringAsFixed(2)} h',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (fila.revisor != null) ...[
            const SizedBox(height: 6),
            Text(
              'Revisado por ${fila.revisor}',
              style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
            ),
          ],
          if (fila.comentarioAdmin != null &&
              fila.comentarioAdmin!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colores.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                fila.comentarioAdmin!,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
