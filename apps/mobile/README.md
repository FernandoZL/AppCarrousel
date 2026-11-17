# carrousel_app

Cliente Flutter de **Carrousel** para jornadas con GPS, horas extras,
aprobaciones y administración por empresa.

La app arranca siempre en login: no hay usuarios ni datos de ejemplo. El rol y
el alcance los decide Supabase desde `app_metadata`; el cliente nunca escribe
claims ni eleva roles.

## Módulos

```text
lib/
├── app/            tema, localización y puerta de sesión
├── core/           configuración, tema, errores, utilidades y Supabase
└── features/
    ├── auth/       sesión, perfil y recuperación
    ├── registro/   alta propia con código de empresa y puesto declarado
    ├── catalogo/   centros de costo, parques y CECOs por lugar
    ├── jornada/    marcaje, geocerca congelada e historial de jornadas
    ├── solicitudes/ horas extras del especialista
    ├── horario/    horario semanal propio
    ├── equipo/     altas, jornadas, horarios, reportes y ajustes (admin)
    ├── configuracion/ zona horaria IANA y umbral GPS de la empresa (admin)
    ├── admin/      aprobaciones, invitaciones y controladores
    ├── dashboard/  resumen en la zona horaria de la empresa
    ├── perfil/     cuenta y sesión
    └── shell/      navegación responsive (web y móvil)
```

Cada módulo sigue `presentation → domain ← data`. El dominio no importa
Supabase ni Flutter.

## Comandos

```bash
flutter pub get
flutter analyze
flutter test

# Con credenciales reales (nunca versionadas)
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-clave-publica

# Web
flutter build web --release
```

Si faltan los `--dart-define`, la app muestra una pantalla de configuración y
no intenta conectarse.

## Pruebas

Las pruebas usan Providers de Riverpod con dobles, sin Supabase ni red. El
reloj del dashboard es inyectable para comprobar el corte de día, semana y mes
en la zona horaria de la empresa (`America/Guatemala` por defecto). El mapa
descarga teselas de OpenStreetMap durante las pruebas de widget; si no hay red,
los avisos `ClientException` son inertes.

La validación continua del repo (GitHub Actions) ejecuta `flutter analyze`,
`flutter test`, el arnés de migraciones, el importador de CECOs y las pruebas
de la Edge Function.
