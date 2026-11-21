import 'package:flutter/material.dart';

import 'package:carrousel_app/core/theme/app_theme.dart';

/// Nombre y versión de la app tal como se muestran en el pie del menú
/// (`.sidebar-version`). Mantener la versión alineada con `pubspec.yaml`.
const nombreApp = 'Jornadas';
const versionApp = '0.2.0';

/// Franja de marca de 4 px con el degradado corporativo (`.brand-strip`).
class FranjaMarca extends StatelessWidget {
  const FranjaMarca({super.key});

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(gradient: Marca.gradiente),
    child: SizedBox(height: 4, width: double.infinity),
  );
}

/// Logo en recuadro blanco de 44 x 44 px (`.sidebar-brand img`).
class LogoCarrousel extends StatelessWidget {
  const LogoCarrousel({super.key, this.tamano = 44});

  final double tamano;

  @override
  Widget build(BuildContext context) => Container(
    width: tamano,
    height: tamano,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(tamano * .18),
    ),
    child: Icon(
      Icons.attractions_rounded,
      size: tamano * .62,
      color: Marca.brand,
    ),
  );
}

/// Encabezado del menú lateral (`.sidebar-brand`): logo, nombre de la app y
/// subtítulo. Con el menú colapsado solo muestra el logo.
class EncabezadoMenuLateral extends StatelessWidget {
  const EncabezadoMenuLateral({super.key, required this.extendido});

  final bool extendido;

  @override
  Widget build(BuildContext context) {
    const logo = LogoCarrousel();
    if (!extendido) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(0, 18, 0, 14),
        child: logo,
      );
    }
    return const SizedBox(
      width: 255,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Row(
          children: [
            logo,
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carrousel $nombreApp',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Marca.sidebarTexto,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Jornadas y horas extras',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Marca.sidebarTextoSuave,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Título de sección del menú (`.nav-section`).
class SeccionMenuLateral extends StatelessWidget {
  const SeccionMenuLateral(this.texto, {super.key, required this.extendido});

  final String texto;
  final bool extendido;

  @override
  Widget build(BuildContext context) {
    if (!extendido) return const SizedBox(height: 4);
    return SizedBox(
      width: 255,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 6, 18, 6),
        child: Opacity(
          opacity: .8,
          child: Text(
            texto.toUpperCase(),
            style: const TextStyle(
              color: Marca.sidebarTextoSuave,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: .77,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pie fijo del menú con la versión (`.sidebar-version`).
class VersionMenuLateral extends StatelessWidget {
  const VersionMenuLateral({super.key, required this.extendido});

  final bool extendido;

  @override
  Widget build(BuildContext context) {
    final texto = extendido
        ? '$nombreApp v$versionApp · Ecosistema v${Marca.versionEcosistema}'
        : 'v$versionApp';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: SizedBox(
        width: extendido ? 231 : 64,
        child: Text(
          texto,
          textAlign: extendido ? TextAlign.left : TextAlign.center,
          style: const TextStyle(
            color: Marca.sidebarTextoSuave,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }
}

/// Título de la barra superior (`.topbar-left`): sección en mayúsculas y
/// página en 15 px peso 600.
class TituloBarraSuperior extends StatelessWidget {
  const TituloBarraSuperior({
    super.key,
    required this.seccion,
    required this.pagina,
  });

  final String seccion;
  final String pagina;

  @override
  Widget build(BuildContext context) {
    final colores = ColoresCarrousel.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          seccion.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: .77,
            color: colores.muted,
          ),
        ),
        Text(
          pagina,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colores.ink,
          ),
        ),
      ],
    );
  }
}

/// Pie corporativo (`.app-corporate-footer`).
class PieCorporativo extends StatelessWidget {
  const PieCorporativo({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = ColoresCarrousel.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colores.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          'Desarrollado por Luis Fernándo Zuñiga',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: colores.muted),
        ),
      ),
    );
  }
}
