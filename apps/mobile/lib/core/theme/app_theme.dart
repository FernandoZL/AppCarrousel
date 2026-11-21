import 'package:flutter/material.dart';

/// Paleta del Ecosistema Carrousel v1.7.0, la misma de helpdesk-carrousel y
/// el resto de las aplicaciones del ecosistema (`docs/ECOSISTEMA.md` de
/// Helpdesk manda si algo no coincide), llevada a Material 3.
class Marca {
  const Marca._();

  static const versionEcosistema = '1.7.0';

  static const brand = Color(0xFF213A8F);
  static const brandDark = Color(0xFF15255D);
  static const brand2 = Color(0xFF2D4DB1);
  static const blue = Color(0xFF0D6EFD);
  static const violet = Color(0xFF6B46C1);
  static const pink = Color(0xFFE62E7C);
  static const orange = Color(0xFFF28B24);
  static const yellow = Color(0xFFF4C430);

  /// Menú lateral (`.sidebar`): azul marino en claro y más profundo en oscuro.
  static const sidebar = Color(0xFF15255D);
  static const sidebarOscuro = Color(0xFF0F1C48);
  static const sidebarTexto = Colors.white;
  static const sidebarTextoSuave = Color(0xFFAEBBE9);

  /// Fondo del activo/hover del menú (`#ffffff1f`).
  static const sidebarActivo = Color(0x1FFFFFFF);

  /// Pantalla de acceso (`.auth-body-v2`, `.auth-brand-v2`).
  static const authPanel = Color(0xFF123563);
  static const authPrimary = Color(0xFF173D75);
  static const authEyebrow = Color(0xFFC42A74);
  static const authEyebrowOscuro = Color(0xFFF472B6);
  static const authFondo = RadialGradient(
    center: Alignment(-.7, -.7),
    radius: 1.4,
    colors: [Color(0xFF315F9B), Color(0xFF173D75), Color(0xFF0C294F)],
    stops: [0, .34, .74],
  );

  /// Degradado corporativo de la franja superior (`--gradient`).
  static const gradiente = LinearGradient(
    colors: [brand, violet, pink, orange, yellow],
    stops: [0, .28, .52, .76, 1],
  );

  /// Tipografía del diseño profesional (`--eco-font`). En web con CanvasKit,
  /// si la fuente no está disponible, Flutter usa su respaldo.
  static const fuente = 'Segoe UI Variable Text';
  static const fuenteRespaldo = [
    'Segoe UI',
    'Inter',
    'system-ui',
    'Roboto',
    'Arial',
    'sans-serif',
  ];

  /// Alto de campos, selects y botones (`--eco-ctrl`).
  static const alturaControl = 38.0;
}

/// Colores de estado y superficies que Material no trae con este nombre.
@immutable
class ColoresCarrousel extends ThemeExtension<ColoresCarrousel> {
  const ColoresCarrousel({
    required this.ink,
    required this.muted,
    required this.border,
    required this.line,
    required this.head,
    required this.hover,
    required this.accent,
    required this.danger,
    required this.dangerBg,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.info,
    required this.infoBg,
  });

  final Color ink;
  final Color muted;
  final Color border;

  /// Borde fino (`--eco-line`): el borde al 75 %.
  final Color line;

  /// Encabezado de tablas (`--eco-head`).
  final Color head;

  /// Hover de filas y botones (`--eco-hover`).
  final Color hover;

  /// Azul de botones primarios, foco y enlaces (`--eco-accent`).
  final Color accent;
  final Color danger;
  final Color dangerBg;
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color info;
  final Color infoBg;

  static const claro = ColoresCarrousel(
    ink: Color(0xFF1F2937),
    muted: Color(0xFF667085),
    border: Color(0xFFD0D5DD),
    line: Color(0xBFD0D5DD),
    head: Color(0xFFFEFEFF),
    hover: Color(0xFFF6F7FA),
    accent: Color(0xFF2453C7),
    danger: Color(0xFFB42318),
    dangerBg: Color(0xFFFEF3F2),
    success: Color(0xFF067647),
    successBg: Color(0xFFECFDF3),
    warning: Color(0xFF9A6700),
    warningBg: Color(0xFFFFFAEB),
    info: Color(0xFF175CD3),
    infoBg: Color(0xFFEFF8FF),
  );

  static const oscuro = ColoresCarrousel(
    ink: Color(0xFFF5F7FB),
    muted: Color(0xFFAEB8CA),
    border: Color(0xFF2C3850),
    line: Color(0xBF2C3850),
    head: Color(0xFF171F32),
    hover: Color(0xFF172036),
    accent: Color(0xFF3B6FE0),
    // El ecosistema no redefine estos tonos en oscuro; se aclaran solo lo
    // necesario para mantener contraste AA sobre las superficies oscuras.
    danger: Color(0xFFF97066),
    dangerBg: Color(0xFF351B20),
    success: Color(0xFF47CD89),
    successBg: Color(0xFF113226),
    warning: Color(0xFFFDB022),
    warningBg: Color(0xFF332B17),
    info: Color(0xFF84CAFF),
    infoBg: Color(0xFF142743),
  );

  static ColoresCarrousel of(BuildContext context) =>
      Theme.of(context).extension<ColoresCarrousel>() ?? claro;

  @override
  ColoresCarrousel copyWith() => this;

  @override
  ColoresCarrousel lerp(ColoresCarrousel? other, double t) =>
      t < .5 ? this : (other ?? this);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _construir(
    brillo: Brightness.light,
    fondo: const Color(0xFFEEF2F7),
    tarjeta: Colors.white,
    colores: ColoresCarrousel.claro,
  );

  static ThemeData get dark => _construir(
    brillo: Brightness.dark,
    fondo: const Color(0xFF0E1526),
    tarjeta: const Color(0xFF172033),
    colores: ColoresCarrousel.oscuro,
  );

  static ThemeData _construir({
    required Brightness brillo,
    required Color fondo,
    required Color tarjeta,
    required ColoresCarrousel colores,
  }) {
    final oscuro = brillo == Brightness.dark;
    final acento = colores.accent;
    final esquema =
        ColorScheme.fromSeed(
          seedColor: Marca.brand,
          brightness: brillo,
        ).copyWith(
          primary: acento,
          onPrimary: Colors.white,
          primaryContainer: oscuro
              ? const Color(0xFF1E2C55)
              : const Color(0xFFE3E9FB),
          onPrimaryContainer: oscuro
              ? const Color(0xFFDCE4FF)
              : Marca.brandDark,
          secondary: Marca.violet,
          tertiary: Marca.pink,
          secondaryContainer: colores.infoBg,
          onSecondaryContainer: colores.info,
          error: colores.danger,
          errorContainer: colores.dangerBg,
          onErrorContainer: colores.danger,
          surface: tarjeta,
          onSurface: colores.ink,
          onSurfaceVariant: colores.muted,
          surfaceContainerLowest: tarjeta,
          surfaceContainerLow: tarjeta,
          surfaceContainer: tarjeta,
          surfaceContainerHigh: oscuro
              ? const Color(0xFF1B263B)
              : const Color(0xFFF6F7FA),
          surfaceContainerHighest: oscuro
              ? const Color(0xFF1D283E)
              : const Color(0xFFF2F4F7),
          outline: colores.border,
          outlineVariant: colores.line,
        );

    final radio8 = BorderRadius.circular(8);
    final borde = OutlineInputBorder(
      borderRadius: radio8,
      borderSide: BorderSide(color: colores.border),
    );
    const controlMinimo = Size(64, Marca.alturaControl);
    const textoBoton = TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600);
    const rellenoBoton = EdgeInsets.symmetric(horizontal: 16);

    // Una sola escala de letra (v1.7.0): base de 14 px, negritas a 600 y
    // textos pequeños de 12.5 px.
    final base = ThemeData(brightness: brillo).textTheme;
    final texto = base
        .copyWith(
          bodyLarge: base.bodyLarge?.copyWith(fontSize: 14, height: 1.5),
          bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
          bodySmall: base.bodySmall?.copyWith(fontSize: 12.5, height: 1.45),
          titleLarge: base.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: base.titleSmall?.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: base.labelMedium?.copyWith(fontSize: 12.5),
          labelSmall: base.labelSmall?.copyWith(fontSize: 11.5),
          headlineSmall: base.headlineSmall?.copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -.4,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
            height: 1.2,
          ),
        )
        .apply(
          fontFamily: Marca.fuente,
          fontFamilyFallback: Marca.fuenteRespaldo,
          bodyColor: colores.ink,
          displayColor: colores.ink,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brillo,
      colorScheme: esquema,
      fontFamily: Marca.fuente,
      fontFamilyFallback: Marca.fuenteRespaldo,
      textTheme: texto,
      scaffoldBackgroundColor: fondo,
      canvasColor: fondo,
      extensions: [colores],
      visualDensity: VisualDensity.standard,
      // `.topbar`: fondo de tarjeta, sin sombra y borde inferior fino.
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 68,
        backgroundColor: tarjeta,
        foregroundColor: colores.ink,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: colores.line)),
        titleTextStyle: TextStyle(
          color: colores.ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: Marca.fuente,
          fontFamilyFallback: Marca.fuenteRespaldo,
        ),
      ),
      // `.card`: borde fino, radio de 12 px y sombra suave (`--eco-shadow`).
      cardTheme: CardThemeData(
        color: tarjeta,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withAlpha(oscuro ? 77 : 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colores.line),
        ),
      ),
      dividerTheme: DividerThemeData(color: colores.line, space: 1),
      // `.sidebar` con `.side-link`: azul marino, texto blanco y activo con
      // fondo translúcido.
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: oscuro ? Marca.sidebarOscuro : Marca.sidebar,
        indicatorColor: Marca.sidebarActivo,
        indicatorShape: RoundedRectangleBorder(borderRadius: radio8),
        minWidth: 76,
        minExtendedWidth: 255,
        selectedIconTheme: const IconThemeData(
          color: Marca.sidebarTexto,
          size: 20,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Marca.sidebarTextoSuave,
          size: 20,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: Marca.sidebarTexto,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: Marca.fuente,
          fontFamilyFallback: Marca.fuenteRespaldo,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: Marca.sidebarTextoSuave,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: Marca.fuente,
          fontFamilyFallback: Marca.fuenteRespaldo,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tarjeta,
        surfaceTintColor: Colors.transparent,
        indicatorColor: esquema.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colores.ink,
          ),
        ),
      ),
      // `.form-control`: 38 px, radio 8, foco con borde y anillo del acento.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tarjeta,
        isDense: true,
        border: borde,
        enabledBorder: borde,
        disabledBorder: OutlineInputBorder(
          borderRadius: radio8,
          borderSide: BorderSide(color: colores.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radio8,
          borderSide: BorderSide(color: acento, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radio8,
          borderSide: BorderSide(color: colores.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radio8,
          borderSide: BorderSide(color: colores.danger, width: 1.6),
        ),
        labelStyle: TextStyle(color: colores.muted, fontSize: 14),
        floatingLabelStyle: TextStyle(
          color: acento,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: colores.muted, fontSize: 14),
        prefixIconColor: colores.muted,
        suffixIconColor: colores.muted,
        constraints: const BoxConstraints(minHeight: Marca.alturaControl),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
      ),
      // `.btn-primary`: acento, 38 px, radio 8, 13.5 px peso 600.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: controlMinimo,
          backgroundColor: acento,
          foregroundColor: Colors.white,
          disabledBackgroundColor: acento.withAlpha(110),
          disabledForegroundColor: Colors.white.withAlpha(200),
          shape: RoundedRectangleBorder(borderRadius: radio8),
          padding: rellenoBoton,
          textStyle: textoBoton,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: controlMinimo,
          backgroundColor: acento,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: radio8),
          padding: rellenoBoton,
          textStyle: textoBoton,
          elevation: 0,
        ),
      ),
      // `.btn-secondary` / `.btn-light`: fondo de tarjeta y borde gris.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: controlMinimo,
          backgroundColor: tarjeta,
          foregroundColor: colores.ink,
          side: BorderSide(color: colores.border),
          shape: RoundedRectangleBorder(borderRadius: radio8),
          padding: rellenoBoton,
          textStyle: textoBoton,
        ).copyWith(overlayColor: WidgetStatePropertyAll(colores.hover)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: acento,
          minimumSize: const Size(48, 34),
          shape: RoundedRectangleBorder(borderRadius: radio8),
          textStyle: textoBoton,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radio8),
        ),
      ),
      // `.badge`: 12 px peso 600.
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: radio8),
        side: BorderSide(color: colores.border),
        labelStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: colores.ink,
        ),
        selectedColor: esquema.primaryContainer,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: controlMinimo,
          textStyle: textoBoton,
          shape: RoundedRectangleBorder(borderRadius: radio8),
        ),
      ),
      // `.eco-switch`: activo en marca (#213a8f / #7fa7ff en oscuro).
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected)
              ? (oscuro ? const Color(0xFF7FA7FF) : Marca.brand)
              : null,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected) ? acento : null,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: acento,
        unselectedLabelColor: colores.muted,
        indicatorColor: acento,
        dividerColor: colores.line,
        labelStyle: textoBoton,
        unselectedLabelStyle: textoBoton.copyWith(fontWeight: FontWeight.w500),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colores.muted,
        titleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colores.ink,
        ),
        subtitleTextStyle: TextStyle(fontSize: 12.5, color: colores.muted),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(colores.head),
        headingTextStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: .6,
          color: colores.muted,
        ),
        dataTextStyle: TextStyle(fontSize: 13.5, color: colores.ink),
        dividerThickness: 1,
      ),
      // Avisos flotantes con el estilo de `.app-toast`.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: oscuro ? const Color(0xFF1D283E) : Marca.brandDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor: Marca.yellow,
        shape: RoundedRectangleBorder(borderRadius: radio8),
        width: 420,
      ),
      // `.eco-dialog`.
      dialogTheme: DialogThemeData(
        backgroundColor: tarjeta,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colores.ink,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tarjeta,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: tarjeta,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radio8,
          side: BorderSide(color: colores.line),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(tarjeta),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: radio8,
              side: BorderSide(color: colores.line),
            ),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Marca.brand,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: acento),
    );
  }
}
