import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/errors/error_messages.dart';
import '../../core/widgets/estado_widgets.dart';
import '../../data/models/parque.dart';
import '../../providers/app_providers.dart';

/// Parques del alcance del admin con su geocerca, para revisarla y ajustarla.
class GeocercasPage extends ConsumerWidget {
  const GeocercasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parquesAsync = ref.watch(parquesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Geocercas de parques')),
      body: parquesAsync.when(
        loading: () => const CargandoWidget(mensaje: 'Cargando parques...'),
        error: (_, _) => MensajeError(
          mensaje: 'No se pudieron cargar los parques.',
          onReintentar: () => ref.invalidate(parquesProvider),
        ),
        data: (parques) => parques.isEmpty
            ? const EstadoVacio(
                icono: Icons.location_off_outlined,
                titulo: 'Sin parques',
                mensaje: 'No hay parques activos en tu alcance.',
              )
            : ListView.separated(
                itemCount: parques.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final parque = parques[i];
                  return ListTile(
                    leading: const Icon(Icons.radar_rounded),
                    title: Text(parque.nombre),
                    subtitle: Text(
                      'Radio ${parque.radioMetros.round()} m · '
                      '${parque.latitud.toStringAsFixed(5)}, '
                      '${parque.longitud.toStringAsFixed(5)}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GeocercaEditorPage(parque: parque),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Toca el mapa para mover el centro y usa el control para el radio.
class GeocercaEditorPage extends ConsumerStatefulWidget {
  const GeocercaEditorPage({super.key, required this.parque});

  final Parque parque;

  @override
  ConsumerState<GeocercaEditorPage> createState() => _GeocercaEditorPageState();
}

class _GeocercaEditorPageState extends ConsumerState<GeocercaEditorPage> {
  final _mapa = MapController();
  late LatLng _centro;
  late double _radio;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _centro = LatLng(widget.parque.latitud, widget.parque.longitud);
    _radio = widget.parque.radioMetros.clamp(30, 1000).toDouble();
  }

  Future<void> _usarMiUbicacion() async {
    try {
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        throw const AppException(
            'Necesitamos tu ubicación para centrar la geocerca.');
      }
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      setState(() => _centro = LatLng(posicion.latitude, posicion.longitude));
      _mapa.move(_centro, _mapa.camera.zoom);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeDeError(error))),
      );
    }
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      await ref.read(horarioRepositoryProvider).guardarGeocerca(
            parqueId: widget.parque.id,
            latitud: _centro.latitude,
            longitud: _centro.longitude,
            radioMetros: _radio,
          );
      ref.invalidate(parquesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Geocerca de ${widget.parque.nombre} guardada.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeDeError(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.parque.nombre)),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapa,
              options: MapOptions(
                initialCenter: _centro,
                initialZoom: 17,
                onTap: (_, punto) => setState(() => _centro = punto),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.empresacarrousel.carrousel_app',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _centro,
                      radius: _radio,
                      useRadiusInMeter: true,
                      color: colores.primary.withAlpha(50),
                      borderColor: colores.primary,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _centro,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: colores.primary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                const RichAttributionWidget(
                  attributions: [TextSourceAttribution('OpenStreetMap')],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toca el mapa para mover el centro del parque.',
                    style: TextStyle(color: colores.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Radio: ${_radio.round()} m',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Slider(
                    value: _radio,
                    min: 30,
                    max: 1000,
                    divisions: 97,
                    label: '${_radio.round()} m',
                    onChanged: (valor) => setState(() => _radio = valor),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _usarMiUbicacion,
                          icon: const Icon(Icons.my_location_rounded),
                          label: const Text('Mi ubicación'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _guardando ? null : _guardar,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
