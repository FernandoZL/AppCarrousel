import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carrousel_app/core/errors/error_messages.dart';
import 'package:carrousel_app/core/widgets/estado_widgets.dart';
import 'package:carrousel_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/puesto.dart';
import 'package:carrousel_app/features/catalogo/presentation/providers/catalogo_providers.dart';

/// Catálogo de puestos de la empresa. El administrador los crea, edita,
/// desactiva o elimina; el alta de un empleado puede referenciar uno.
class PuestosPage extends ConsumerStatefulWidget {
  const PuestosPage({super.key});

  @override
  ConsumerState<PuestosPage> createState() => _PuestosPageState();
}

class _PuestosPageState extends ConsumerState<PuestosPage> {
  bool _guardando = false;

  Future<void> _nuevo() async {
    final datos = await showDialog<_DatosPuesto>(
      context: context,
      builder: (_) => const _DialogoPuesto(),
    );
    if (datos == null || !mounted) return;

    final perfil = ref.read(perfilProvider).valueOrNull;
    if (perfil == null) return;

    setState(() => _guardando = true);
    try {
      await ref.read(crearPuestoProvider)(
        empresaId: perfil.empresaId,
        codigo: datos.codigo,
        nombre: datos.nombre,
        descripcion: datos.descripcion,
      );
      ref.invalidate(puestosProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Puesto creado.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _editar(Puesto puesto) async {
    final datos = await showDialog<_DatosPuesto>(
      context: context,
      builder: (_) => _DialogoPuesto(puesto: puesto),
    );
    if (datos == null || !mounted) return;

    setState(() => _guardando = true);
    try {
      await ref.read(actualizarPuestoProvider)(
        id: puesto.id,
        codigo: datos.codigo,
        nombre: datos.nombre,
        descripcion: datos.descripcion,
        activo: datos.activo,
      );
      ref.invalidate(puestosProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Puesto actualizado.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _cambiarActivo(Puesto puesto, bool activo) async {
    try {
      await ref.read(actualizarPuestoProvider)(
        id: puesto.id,
        codigo: puesto.codigo,
        nombre: puesto.nombre,
        descripcion: puesto.descripcion,
        activo: activo,
      );
      ref.invalidate(puestosProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
    }
  }

  Future<void> _eliminar(Puesto puesto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar puesto'),
        content: Text(
          '¿Eliminar "${puesto.nombre}"? Si tiene empleados o altas asociadas '
          'no se podrá eliminar; en ese caso desactívalo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    try {
      await ref.read(eliminarPuestoProvider)(puesto.id);
      ref.invalidate(puestosProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Puesto eliminado.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se observa el perfil para mantenerlo vivo: sin esta suscripción el
    // provider autoDispose se libera y el alta de puestos no conocería la
    // empresa.
    final perfil = ref.watch(perfilProvider).valueOrNull;
    if (perfil == null) {
      return const CargandoWidget(mensaje: 'Cargando puestos...');
    }

    final puestosAsync = ref.watch(puestosProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(puestosProvider);
        await ref.read(puestosProvider.future);
      },
      child: puestosAsync.when(
        loading: () => const CargandoWidget(mensaje: 'Cargando puestos...'),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: MensajeError(
                mensaje: 'No se pudo cargar el catálogo de puestos.',
                onReintentar: () => ref.invalidate(puestosProvider),
              ),
            ),
          ],
        ),
        data: (puestos) {
          final activos = puestos.where((puesto) => puesto.activo).length;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catálogo de puestos',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          puestos.isEmpty
                              ? 'Aún no hay puestos en tu empresa.'
                              : '${puestos.length} puestos · $activos activos.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _nuevo,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Nuevo'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (puestos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: EstadoVacio(
                    icono: Icons.badge_outlined,
                    titulo: 'Sin puestos',
                    mensaje:
                        'Crea el primer puesto para poder asignarlo al aprobar '
                        'una cuenta o al editar el equipo.',
                  ),
                )
              else
                for (final puesto in puestos)
                  _TarjetaPuesto(
                    puesto: puesto,
                    onEditar: () => _editar(puesto),
                    onEliminar: () => _eliminar(puesto),
                    onActivo: (activo) => _cambiarActivo(puesto, activo),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaPuesto extends StatelessWidget {
  const _TarjetaPuesto({
    required this.puesto,
    required this.onEditar,
    required this.onEliminar,
    required this.onActivo,
  });

  final Puesto puesto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final ValueChanged<bool> onActivo;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colores.outlineVariant, width: 0.7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: puesto.activo
                  ? colores.primaryContainer
                  : colores.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.badge_outlined,
              color: puesto.activo
                  ? colores.onPrimaryContainer
                  : colores.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  puesto.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  puesto.codigo,
                  style: TextStyle(
                    fontSize: 12,
                    color: colores.onSurfaceVariant,
                  ),
                ),
                if (puesto.descripcion != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      puesto.descripcion!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  puesto.activo ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: puesto.activo ? colores.primary : colores.error,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: puesto.activo, onChanged: onActivo),
          IconButton(
            tooltip: 'Editar puesto',
            onPressed: onEditar,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Eliminar puesto',
            onPressed: onEliminar,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _DatosPuesto {
  const _DatosPuesto({
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.activo,
  });

  final String codigo;
  final String nombre;
  final String? descripcion;
  final bool activo;
}

class _DialogoPuesto extends StatefulWidget {
  const _DialogoPuesto({this.puesto});

  final Puesto? puesto;

  @override
  State<_DialogoPuesto> createState() => _DialogoPuestoState();
}

class _DialogoPuestoState extends State<_DialogoPuesto> {
  final _formKey = GlobalKey<FormState>();
  final _codigo = TextEditingController();
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  late bool _activo;

  @override
  void initState() {
    super.initState();
    final puesto = widget.puesto;
    _codigo.text = puesto?.codigo ?? '';
    _nombre.text = puesto?.nombre ?? '';
    _descripcion.text = puesto?.descripcion ?? '';
    _activo = puesto?.activo ?? true;
  }

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _DatosPuesto(
        codigo: _codigo.text.trim(),
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim().isEmpty
            ? null
            : _descripcion.text.trim(),
        activo: _activo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.puesto != null;
    return AlertDialog(
      title: Text(editando ? 'Editar puesto' : 'Nuevo puesto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codigo,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  prefixIcon: Icon(Icons.tag_rounded),
                  helperText: 'Identificador único dentro de la empresa.',
                ),
                validator: (valor) {
                  final texto = valor?.trim() ?? '';
                  if (texto.isEmpty) return 'Escribe un código.';
                  if (texto.length > 40) return 'Usa máximo 40 caracteres.';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (valor) {
                  final texto = valor?.trim() ?? '';
                  if (texto.isEmpty) return 'Escribe el nombre del puesto.';
                  if (texto.length > 120) return 'Usa máximo 120 caracteres.';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descripcion,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo'),
                subtitle: const Text(
                  'Solo los puestos activos se ofrecen al aprobar altas.',
                ),
                value: _activo,
                onChanged: (valor) => setState(() => _activo = valor),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: Text(editando ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
