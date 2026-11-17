import 'package:flutter/material.dart';

import 'package:carrousel_app/core/utils/duraciones.dart';
import 'package:carrousel_app/core/widgets/estado_widgets.dart';
import 'package:carrousel_app/features/equipo/domain/entities/ajuste_jornada.dart';
import 'package:carrousel_app/features/equipo/domain/entities/cumplimiento_jornada.dart';

/// Historial inmutable de correcciones de una jornada.
///
/// Los ajustes se entregan desde la capa de presentación para que el diálogo
/// sea puro y pueda probarse sin Supabase ni Riverpod.
class HistorialAjustesDialog extends StatelessWidget {
  const HistorialAjustesDialog({
    super.key,
    required this.jornada,
    required this.ajustes,
  });

  final CumplimientoJornada jornada;
  final List<AjusteJornada> ajustes;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Historial de ajustes'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              jornada.empleado,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Jornada del ${formatearFecha(jornada.entradaEn)}',
              style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (ajustes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: EstadoVacio(
                  icono: Icons.history_rounded,
                  titulo: 'Sin ajustes',
                  mensaje: 'Esta jornada no ha sido corregida.',
                ),
              )
            else
              for (final ajuste in ajustes)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colores.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 16,
                            color: colores.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              formatearFechaHora(ajuste.creadoEn),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(ajuste.motivo, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 8),
                      _Cambio(
                        etiqueta: 'Entrada',
                        anterior: ajuste.entradaEnAnterior,
                        nueva: ajuste.entradaEnNueva,
                      ),
                      const SizedBox(height: 4),
                      _Cambio(
                        etiqueta: 'Salida',
                        anterior: ajuste.salidaEnAnterior,
                        nueva: ajuste.salidaEnNueva,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registrado por un administrador',
                        style: TextStyle(
                          fontSize: 11,
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _Cambio extends StatelessWidget {
  const _Cambio({
    required this.etiqueta,
    required this.anterior,
    required this.nueva,
  });

  final String etiqueta;
  final DateTime anterior;
  final DateTime nueva;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: '$etiqueta: '),
          TextSpan(
            text: '${formatearFechaHora(anterior)} ',
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const TextSpan(text: '→ '),
          TextSpan(
            text: formatearFechaHora(nueva),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
