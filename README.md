# Aura Lift

Aura Lift es una app de entrenamiento en Flutter enfocada en registro de sesiones,
progreso, frecuencia cardiaca y una experiencia visual compacta para movil.

## Que incluye hoy

- Onboarding de perfil (nombre, altura, peso, tipo de cuerpo)
- Registro de entrenamientos, ejercicios y series
- Historial, detalle de sesion y progreso por ejercicio
- Perfil con metricas, liga anual y calendario de entrenamientos
- Capa social local con perfiles de amigos y comparativa de rendimiento
- Importacion de frecuencia cardiaca desde proveedores de salud en iOS y Android
- Coaching de audio basado en datos de entrenamiento y FC
- Tema claro/oscuro, idioma ES/EN y soporte de emojis
- Layout global compacto con ancho maximo tipo iPhone para UI consistente

## Arquitectura

- `lib/app.dart`: arranque, inyeccion de dependencias y frame global de app
- `lib/core/`: estado, modelos, repositorios, tema, localizacion y utilidades
- `lib/features/`: onboarding, home, training, workout, profile, progress, social
- `assets/seed/exercises_seed.json`: seed de ejercicios base

## Requisitos

- Flutter estable
- Dart (incluido con Flutter)

## Comandos de desarrollo

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Pruebas responsive (recomendado)

Para validar overflows y accesibilidad basica en anchos de movil y text scale alto:

```bash
flutter test test/responsive_layout_test.dart
```

La bateria cubre escenarios de 320/360/390 px y textScale 1.3/1.4/1.5.

## Pruebas de flujos criticos

Para validar los flujos de integracion de estado en health, social y workout:

```bash
flutter test test/app_state_critical_flows_integration_test.dart
```

Esta suite cubre arranque/cierre de entrenamiento, importacion deduplicada de
frecuencia cardiaca y conexiones sociales (request received/friends/request sent).

## Modo demo

Para arrancar con datos de ejemplo (sin persistencia real en disco):

```bash
flutter run -d linux --dart-define=AURA_LIFT_DEMO_DATA=true
```

El modo demo incluye perfil, sesiones, volumen, progreso y muestras de FC para
probar pantallas sin cargar datos manualmente.

## Plataformas

- Objetivo principal: iOS y Android
- Desktop: soportado para desarrollo y validacion de interfaz
- Web: desplegable en GitHub Pages para pruebas rapidas desde navegador

## Probar en navegador del movil (GitHub Pages)

Este repo incluye workflow automatico en `.github/workflows/deploy-web-pages.yml`.

1. Sube cambios a `main` o `master`.
2. Ve a GitHub > Settings > Pages y confirma que la fuente sea `GitHub Actions`.
3. Espera a que termine el workflow `Deploy Flutter Web to Pages`.
4. Abre la URL publicada (`https://<usuario>.github.io/<repo>/`) desde tu movil.

Notas:

- Para repos tipo `<usuario>.github.io`, la app se publica en la raiz.
- En web puedes validar UI/UX y logica general, pero integraciones nativas de salud
  (HealthKit/Health Connect) no estan disponibles en navegador.

## Limitaciones actuales

- No hay backend social real (funciona en modo local/demo)
- El stream nativo depende de permisos de HealthKit/Health Connect y disponibilidad del proveedor en el dispositivo
- El calculo de calorias y recomendaciones es heuristico
