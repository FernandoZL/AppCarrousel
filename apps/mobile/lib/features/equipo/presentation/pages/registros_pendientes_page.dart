import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carrousel_app/core/errors/error_messages.dart';
import 'package:carrousel_app/core/utils/duraciones.dart';
import 'package:carrousel_app/core/widgets/estado_widgets.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/puesto.dart';
import 'package:carrousel_app/features/catalogo/presentation/providers/catalogo_providers.dart';
import 'package:carrousel_app/features/equipo/domain/entities/registro_pendiente.dart';
import 'package:carrousel_app/features/equipo/presentation/providers/equipo_providers.dart';

/// Altas solicitadas con el código de empresa, pendientes de aprobación.
class RegistrosPendientesPage extends ConsumerWidget {
  const RegistrosPendientesPage({super.key});

  Future<void> _aprobar(
    BuildContext context,
    WidgetRef ref,
    RegistroPendiente registro,
  ) async {
    final centros =
        ref.read(centrosProvider).valueOrNull ?? const <CentroCosto>[];
    if (centros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay centros de costo disponibles para asignar.'),
        ),
      );
      return;
    }

    final puestos = (ref.read(puestosProvider).valueOrNull ?? const <Puesto>[])
        .where((puesto) => puesto.activo)
        .toList(growable: false);

    final resultado = await showDialog<_Aprobacion>(
      context: context,
      builder: (_) => _DialogoAprobar(
        registro: registro,
        centros: centros,
        puestos: puestos,
      ),
    );
    if (resultado == null || !context.mounted) return;

    try {
      await ref.read(aprobarRegistroProvider)(
        registroId: registro.id,
        centroCostoId: resultado.centroCostoId,
        puestoId: resultado.puestoId,
      );
      ref.invalidate(registrosPendientesProvider);
      ref.invalidate(nombresPerfilesProvider);
      ref.invalidate(miembrosEquipoProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${registro.nombreCompleto} ya tiene acceso como empleado.',
            ),
          ),
        );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
    }
  }

  Future<void> _rechazar(
    BuildContext context,
    WidgetRef ref,
    RegistroPendiente registro,
  ) async {
    final motivo = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoRechazo(registro: registro),
    );
    if (motivo == null || !context.mounted) return;

    try {
      await ref.read(rechazarRegistroProvider)(
        registroId: registro.id,
        motivo: motivo,
      );
      ref.invalidate(registrosPendientesProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Registro rechazado.')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrosAsync = ref.watch(registrosPendientesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(registrosPendientesProvider);
        await ref.read(registrosPendientesProvider.future);
      },
      child: registrosAsync.when(
        loading: () =>
            const CargandoWidget(mensaje: 'Cargando registros pendientes...'),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: MensajeError(
                mensaje: 'No se pudieron cargar los registros pendientes.',
                onReintentar: () => ref.invalidate(registrosPendientesProvider),
              ),
            ),
          ],
        ),
        data: (registros) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(
                'Altas por código',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                registros.isEmpty
                    ? 'No hay cuentas esperando aprobación.'
                    : '${registros.length} ${registros.length == 1 ? 'cuenta espera' : 'cuentas esperan'} aprobación.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (registros.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: EstadoVacio(
                    icono: Icons.how_to_reg_rounded,
                    titulo: 'Sin altas pendientes',
                    mensaje: 'Cuando alguien solicite acceso con el código de empresa aparecerá aquí.',
                  ),
                )
              else
                for (final registro in registros)
                  _TarjetaRegistro(
                    registro: registro,
                    onAprobar: () => _aprobar(context, ref, registro),
                    onRechazar: () => _rechazar(context, ref, registro),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaRegistro extends StatelessWidget {
  const _TarjetaRegistro({
    required this.registro,
    required this.onAprobar,
    required this.onRechazar,
  });

  final RegistroPendiente registro;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
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
              Container(
                height: 42,
                width: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colores.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: colores.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      registro.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      registro.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Solicitado ${formatearFechaHora(registro.creadoEn)}',
            style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRechazar,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: colores.error,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAprobar,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Aprobar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Aprobacion {
  const _Aprobacion({required this.centroCostoId, this.puestoId});

  final String centroCostoId;
  final String? puestoId;
}

class _DialogoAprobar extends StatefulWidget {
  const _DialogoAprobar({
    required this.registro,
    required this.centros,
    required this.puestos,
  });

  final RegistroPendiente registro;
  final List<CentroCosto> centros;
  final List<Puesto> puestos;

  @override
  State<_DialogoAprobar> createState() => _DialogoAprobarState();
}

class _DialogoAprobarState extends State<_DialogoAprobar> {
  String? _centroId;
  String _puestoId = '';

  @override
  void initState() {
    super.initState();
    if (widget.centros.length == 1) {
      _centroId = widget.centros.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aprobar alta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.registro.nombreCompleto,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(widget.registro.email, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _centroId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Centro de costo',
                prefixIcon: Icon(Icons.account_tree_outlined),
              ),
              items: [
                for (final centro in widget.centros)
                  DropdownMenuItem(
                    value: centro.id,
                    child: Text(centro.nombre),
                  ),
              ],
              onChanged: (valor) => setState(() => _centroId = valor),
            ),
            if (widget.puestos.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _puestoId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Puesto (opcional)',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Sin puesto')),
                  for (final puesto in widget.puestos)
                    DropdownMenuItem(
                      value: puesto.id,
                      child: Text('${puesto.nombre} · ${puesto.codigo}'),
                    ),
                ],
                onChanged: (valor) => setState(() => _puestoId = valor ?? ''),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'La cuenta se aprobará siempre con rol Empleado. Después podrás '
              'asignarle horario y permisos desde el equipo.',
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
          onPressed: _centroId == null
              ? null
              : () => Navigator.of(context).pop(
                  _Aprobacion(
                    centroCostoId: _centroId!,
                    puestoId: _puestoId.isEmpty ? null : _puestoId,
                  ),
                ),
          child: const Text('Aprobar'),
        ),
      ],
    );
  }
}

class _DialogoRechazo extends StatefulWidget {
  const _DialogoRechazo({required this.registro});

  final RegistroPendiente registro;

  @override
  State<_DialogoRechazo> createState() => _DialogoRechazoState();
}

class _DialogoRechazoState extends State<_DialogoRechazo> {
  final _motivo = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  void _confirmar() {
    final texto = _motivo.text.trim();
    if (texto.length < 5) {
      setState(() => _error = 'Escribe al menos 5 caracteres.');
      return;
    }
    if (texto.length > 1000) {
      setState(() => _error = 'El motivo no puede superar 1000 caracteres.');
      return;
    }
    Navigator.of(context).pop(texto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rechazar alta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.registro.nombreCompleto} · ${widget.registro.email}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _motivo,
              autofocus: true,
              minLines: 3,
              maxLines: 5,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Motivo del rechazo',
                errorText: _error,
              ),
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
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Rechazar'),
        ),
      ],
    );
  }
}
