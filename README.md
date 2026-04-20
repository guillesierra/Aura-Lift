# Aura Lift

App de entrenamiento en Flutter para iOS y Android centrada en:

- perfil de usuario
- registro de entrenamientos, ejercicios y series
- progreso por ejercicio
- frecuencia cardiaca por sesion y por ejercicio
- coaching de audio basado en FC
- tema claro/oscuro e idioma ES/EN

## Estado actual

Base ya implementada:

- arquitectura modular en `lib/core` y `lib/features`
- onboarding con nombre, altura, peso y tipo de cuerpo
- persistencia local de perfil, ajustes, ejercicios y entrenamientos
- seed inicial de 100 ejercicios comunes
- creacion de ejercicios personalizados
- sesion activa con ejercicios, series, peso y repeticiones
- historial de entrenamientos con renombrado y borrado
- detalle de entrenamiento con volumen, tiempo, FC media, FC maxima y desglose
- progreso por ejercicio con historial y resumen
- seleccion explicita del ejercicio activo para asociar nuevas muestras de FC

Pendiente de producto:

- integracion real con Apple Watch / AirPods / HealthKit
- integracion real con musica en reproduccion
- social real y backend
- calculo avanzado de kcal y patrones

## Estructura

- `lib/app.dart`: arranque y dependencias
- `lib/core/`: modelos, repositorios, estado, tema, localizacion y widgets base
- `lib/features/`: onboarding, home, training, workout, profile y progress
- `assets/seed/exercises_seed.json`: catalogo inicial

## Requisitos

- Flutter estable
- Dart incluido con Flutter

## Comandos

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Plataformas

El proyecto esta orientado a `iOS` y `Android`, pero puede ejecutarse en desktop para desarrollo de interfaz. La capa de voz se desactiva automaticamente en plataformas donde el plugin no tenga implementacion nativa disponible.

## Notas de desarrollo

- Los datos se guardan localmente.
- La localizacion activa soporta espanol e ingles.
- La frecuencia cardiaca actual se puede registrar de forma manual desde la pantalla de sesion mientras no exista la integracion real con sensores.
