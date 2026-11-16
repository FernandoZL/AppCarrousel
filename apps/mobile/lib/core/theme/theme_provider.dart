import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Preferencia de apariencia de la sesión actual.
///
/// No se persiste en disco: la app arranca siempre con la preferencia del
/// sistema. El usuario puede cambiarla mientras dure la sesión.
final temaProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

extension EtiquetaTema on ThemeMode {
  String get etiqueta => switch (this) {
    ThemeMode.light => 'Claro',
    ThemeMode.dark => 'Oscuro',
    ThemeMode.system => 'Automático',
  };
}
