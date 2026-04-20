# Semana 1 Flutter

## Base implementada

- arquitectura modular en `lib/core` y `lib/features`
- tema claro y oscuro
- onboarding de perfil con nombre, altura, peso y tipo de cuerpo
- persistencia local de perfil, ejercicios, entrenamientos y ajustes
- catalogo seed de ejercicios

## Evolucion posterior ya integrada

El proyecto ya no esta en una base de Semana 1 pura. Sobre esta estructura se han implementado ademas:

- sesiones de entrenamiento y series
- historial de entrenamientos
- renombrado y borrado de entrenamientos
- progreso por ejercicio
- detalle de entrenamiento
- frecuencia cardiaca por sesion y por ejercicio
- seleccion explicita de ejercicio para asociar nuevas muestras de FC
- coaching por audio basado en FC

## Validacion recomendada

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
