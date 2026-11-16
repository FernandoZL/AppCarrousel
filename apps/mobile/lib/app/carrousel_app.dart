import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carrousel_app/core/theme/app_theme.dart';
import 'package:carrousel_app/core/theme/theme_provider.dart';
import 'package:carrousel_app/features/shell/presentation/pages/root_gate.dart';

/// Raíz de la aplicación. Solo compone tema, localización y la puerta de
/// sesión; la lógica de autenticación vive en las capas de `auth`.
class CarrouselApp extends ConsumerWidget {
  const CarrouselApp({super.key, this.initError});

  final Object? initError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(temaProvider);

    return MaterialApp(
      title: 'Carrousel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: modo,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: RootGate(initError: initError),
    );
  }
}
