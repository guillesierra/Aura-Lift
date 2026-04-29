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

## Limitaciones actuales

- No hay backend social real (funciona en modo local/demo)
- No hay streaming nativo en tiempo real directo de wearable (se usa importacion)
- El calculo de calorias y recomendaciones es heuristico
