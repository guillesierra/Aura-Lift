import 'package:flutter/material.dart';

class AppStrings {
  const AppStrings._(this.languageCode);

  final String languageCode;

  bool get isEnglish => languageCode == 'en';

  static AppStrings of(String languageCode) => AppStrings._(languageCode);

  String get appName => 'Aura Lift';
  String get home => isEnglish ? 'Home' : 'Inicio';
  String get training => isEnglish ? 'Training' : 'Entrenamiento';
  String get profile => isEnglish ? 'Profile' : 'Perfil';
  String hello(String name) => isEnglish ? 'Hi, $name' : 'Hola, $name';
  String get homeOverview => isEnglish
      ? 'Quick overview of your activity and direct access to training.'
      : 'Resumen rapido de tu actividad y acceso directo al entreno.';
  String get homeOverviewActive => isEnglish
      ? 'You have an active session and your recent history just below.'
      : 'Tienes una sesion activa y tu historial reciente justo debajo.';
  String get readyToTrain => isEnglish ? 'Ready to train' : 'Listo para entrenar';
  String get activeSession => isEnglish ? 'Active session' : 'Sesion activa';
  String get quickStartCopy => isEnglish
      ? 'Start fast and log everything from one focused screen.'
      : 'Empieza rapido y registra todo desde una sola pantalla.';
  String sessionSummary(int exercises, int sets) => isEnglish
      ? '$exercises exercises · $sets sets'
      : '$exercises ejercicios · $sets series';
  String get startWorkout => isEnglish ? 'Start workout' : 'Empezar entrenamiento';
  String get resumeWorkout => isEnglish ? 'Resume workout' : 'Reanudar entrenamiento';
  String get quickMetrics => isEnglish ? 'Quick metrics' : 'Metricas rapidas';
  String get height => isEnglish ? 'Height' : 'Altura';
  String get weight => isEnglish ? 'Weight' : 'Peso';
  String get bodyType => isEnglish ? 'Body type' : 'Tipo de cuerpo';
  String get recentHistory => isEnglish ? 'Recent history' : 'Historial reciente';
  String get noClosedSessions => isEnglish
      ? 'There are no finished sessions yet.'
      : 'Todavia no hay sesiones cerradas.';
  String exercisesCount(int value) =>
      isEnglish ? '$value exercises' : '$value ejercicios';
  String setsCount(int value) => isEnglish ? '$value sets' : '$value series';
  String get directSessionAccess => isEnglish
      ? 'Direct access to your session. Fewer steps, more focus.'
      : 'Acceso directo a tu sesion. Menos pasos, mas foco.';
  String get activePanelCopy => isEnglish
      ? 'Your operating panel is active. Resume and keep logging.'
      : 'Tu panel operativo ya esta activo. Reanuda y sigue registrando.';
  String get startEmptyWorkout =>
      isEnglish ? 'Start empty workout' : 'Empezar entrenamiento vacio';
  String get exercisesLabel => isEnglish ? 'Exercises' : 'Ejercicios';
  String get setsLabel => isEnglish ? 'Sets' : 'Series';
  String get volume => isEnglish ? 'Volume' : 'Volumen';
  String get resume => isEnglish ? 'Resume' : 'Reanudar';
  String get start => isEnglish ? 'Start' : 'Empezar';
  String get quickAccess => isEnglish ? 'Quick access' : 'Accesos rapidos';
  String get lastSession => isEnglish ? 'Last session' : 'Ultima sesion';
  String get noHistory => isEnglish ? 'No history' : 'Sin historial';
  String loadedExercises(int count) =>
      isEnglish ? '$count loaded' : '$count cargados';
  String get workouts => isEnglish ? 'Workouts' : 'Entrenos';
  String get duration => isEnglish ? 'Duration' : 'Duracion';
  String get stats => isEnglish ? 'Stats' : 'Estadisticas';
  String get exercises => isEnglish ? 'Exercises' : 'Ejercicios';
  String get measurements => isEnglish ? 'Measurements' : 'Medidas';
  String get calendar => isEnglish ? 'Calendar' : 'Calendario';
  String get info => isEnglish ? 'Information' : 'Informacion';
  String get settings => isEnglish ? 'Settings' : 'Configuracion';
  String get appearance => isEnglish ? 'Appearance' : 'Apariencia';
  String get language => isEnglish ? 'Language' : 'Idioma';
  String get followSystem => isEnglish ? 'System' : 'Sistema';
  String get light => isEnglish ? 'Light' : 'Claro';
  String get dark => isEnglish ? 'Dark' : 'Oscuro';
  String get spanish => isEnglish ? 'Spanish' : 'Espanol';
  String get english => isEnglish ? 'English' : 'Ingles';
  String get close => isEnglish ? 'Close' : 'Cerrar';
}

extension ThemeModeLabel on ThemeMode {
  String localizedLabel(AppStrings strings) {
    switch (this) {
      case ThemeMode.system:
        return strings.followSystem;
      case ThemeMode.light:
        return strings.light;
      case ThemeMode.dark:
        return strings.dark;
    }
  }
}
