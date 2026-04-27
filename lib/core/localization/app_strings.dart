import 'package:flutter/material.dart';

class AppStrings {
  const AppStrings._(this.languageCode);

  final String languageCode;

  bool get isEnglish => languageCode == 'en';

  static AppStrings of(String languageCode) => AppStrings._(languageCode);

  String get appName => 'Aura Lift';
  String get onboardingTitle => isEnglish ? 'Set your base' : 'Configura tu base';
  String get back => isEnglish ? 'Back' : 'Atras';
  String get continueLabel => isEnglish ? 'Continue' : 'Continuar';
  String get begin => isEnglish ? 'Start' : 'Empezar';
  String get onboardingIntroCopy => isEnglish
      ? 'A sober, fast and precise training companion. We start with your profile.'
      : 'Un companion de entrenamiento sobrio, rapido y preciso. Empezamos por tu perfil.';
  String get nameHint => isEnglish
      ? 'How do you want me to call you'
      : 'Como quieres que te llame';
  String get yourMetrics => isEnglish ? 'Your metrics' : 'Tus metricas';
  String get metricsCopy => isEnglish
      ? 'These measurements will personalize estimates and progress.'
      : 'Estas medidas se usaran para personalizar estimaciones y progreso.';
  String get heightCm => isEnglish ? 'Height (cm)' : 'Altura (cm)';
  String get weightKg => isEnglish ? 'Weight (kg)' : 'Peso (kg)';
  String get bodyTypeCopy => isEnglish
      ? 'This is an initial reference. The app will adjust coaching with real use.'
      : 'Es una referencia inicial. La app ira ajustando el coaching con uso real.';
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
  String get homeInsights => isEnglish ? 'Training insights' : 'Resumen de entreno';
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
  String get personalStatsTitle => isEnglish
      ? 'Personal stats'
      : 'Estadisticas personales';
  String personalStatsCopy(int count) => isEnglish
      ? '$count finished workouts included in these numbers.'
      : '$count entrenos terminados incluidos en estos numeros.';
  String get personalStatsEmpty => isEnglish
      ? 'Finish workouts to unlock your training stats.'
      : 'Finaliza entrenos para desbloquear tus estadisticas.';
  String get activeDays => isEnglish ? 'Active days' : 'Dias activos';
  String get averageSession => isEnglish
      ? 'Average session'
      : 'Sesion media';
  String get totalSetsLabel => isEnglish ? 'Total sets' : 'Series totales';
  String get averageHeartRate => isEnglish ? 'Average HR' : 'FC media';
  String get estimatedCalories => isEnglish ? 'Estimated kcal' : 'Kcal estimadas';
  String get totalCalories => isEnglish ? 'Total kcal' : 'Kcal totales';
  String get caloriesUnit => 'kcal';
  String get topExercise => isEnglish ? 'Top exercise' : 'Ejercicio top';
  String get heaviestLift => isEnglish ? 'Heaviest lift' : 'Mayor carga';
  String get noExerciseData => isEnglish
      ? 'No exercise data yet.'
      : 'Aun no hay datos de ejercicios.';
  String get exercises => isEnglish ? 'Exercises' : 'Ejercicios';
  String get measurements => isEnglish ? 'Measurements' : 'Medidas';
  String get calendar => isEnglish ? 'Calendar' : 'Calendario';
  String get workoutCalendarTitle => isEnglish
      ? 'Workout calendar'
      : 'Calendario de entrenos';
  String workoutCalendarCopy(int count) => isEnglish
      ? '$count finished workouts grouped by day.'
      : '$count entrenos terminados agrupados por dia.';
  String get workoutCalendarEmpty => isEnglish
      ? 'Finish workouts to see them grouped by date here.'
      : 'Finaliza entrenos para verlos aqui agrupados por fecha.';
  String dayWorkoutCount(int count) => isEnglish
      ? '$count workouts'
      : '$count entrenos';
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
  String get time => isEnglish ? 'Time' : 'Tiempo';
  String get sets => isEnglish ? 'Sets' : 'Series';
  String get heartRateShort => isEnglish ? 'HR' : 'FC';
  String get heartRateUnit => isEnglish ? 'bpm' : 'lpm';
  String get rename => isEnglish ? 'Rename' : 'Renombrar';
  String get deleteWorkout => isEnglish
      ? 'Delete workout'
      : 'Eliminar entrenamiento';
  String get renameWorkout => isEnglish
      ? 'Rename workout'
      : 'Renombrar entrenamiento';
  String get title => isEnglish ? 'Title' : 'Titulo';
  String get cancel => isEnglish ? 'Cancel' : 'Cancelar';
  String get save => isEnglish ? 'Save' : 'Guardar';
  String deleteWorkoutMessage(String title) => isEnglish
      ? '"$title" will be removed from history. This action cannot be undone.'
      : 'Se eliminara "$title" del historial. Esta accion no se puede deshacer.';
  String get saveChanges => isEnglish ? 'Save changes' : 'Guardar cambios';
  String get workoutSessionEmptyTitle => isEnglish
      ? 'There is no active session'
      : 'No hay una sesion activa';
  String get workoutSessionEmptyCopy => isEnglish
      ? 'Go back home and create a new workout.'
      : 'Vuelve a inicio y crea un entreno nuevo.';
  String get startWithExercise => isEnglish
      ? 'Start with one exercise'
      : 'Empieza por un ejercicio';
  String get startWithExerciseCopy => isEnglish
      ? 'Add exercises from the catalog and log your sets with weight and reps.'
      : 'Anade ejercicios desde el catalogo y registra tus series con peso y repeticiones.';
  String get addExercise => isEnglish ? 'Add exercise' : 'Anadir ejercicio';
  String get heartRate => isEnglish ? 'Heart rate' : 'Frecuencia cardiaca';
  String get syncAppleHealth => isEnglish
      ? 'Sync Apple Health'
      : 'Sincronizar Apple Health';
  String get appleHealthHeartRateCopy => isEnglish
      ? 'Imports heart-rate samples written in Apple Health by Apple Watch or compatible Apple devices.'
      : 'Importa muestras de frecuencia cardiaca guardadas en Apple Health por Apple Watch o dispositivos Apple compatibles.';
  String get appleHealthSyncing => isEnglish
      ? 'Reading Apple Health...'
      : 'Leyendo Apple Health...';
  String get appleHealthUnsupported => isEnglish
      ? 'Apple Health sync is available on iPhone.'
      : 'La sincronizacion con Apple Health esta disponible en iPhone.';
  String get appleHealthDenied => isEnglish
      ? 'Heart-rate permission was not granted in Apple Health.'
      : 'No se concedio permiso de frecuencia cardiaca en Apple Health.';
  String appleHealthImported(int count) => isEnglish
      ? '$count heart-rate samples imported.'
      : '$count muestras de frecuencia cardiaca importadas.';
  String get appleHealthNoSamples => isEnglish
      ? 'No Apple Health heart-rate samples found for this workout.'
      : 'No se encontraron muestras de frecuencia cardiaca en Apple Health para este entreno.';
  String get appleHealthSyncFailed => isEnglish
      ? 'Apple Health sync failed.'
      : 'No se pudo sincronizar Apple Health.';
  String get noHeartRateSamplesYet => isEnglish
      ? 'No samples yet'
      : 'Sin muestras todavia';
  String selectedExerciseForHeartRate(String exerciseName) => isEnglish
      ? 'Samples linked to $exerciseName'
      : 'Muestras vinculadas a $exerciseName';
  String heartRateBaseline(int baseline, int threshold) => isEnglish
      ? 'Baseline $baseline bpm · back-to-work cue at $threshold bpm'
      : 'Base $baseline lpm · aviso de vuelta $threshold lpm';
  String get recentSamples => isEnglish ? 'Recent samples' : 'Muestras recientes';
  String get editName => isEnglish ? 'Edit name' : 'Editar nombre';
  String get finish => isEnglish ? 'Finish' : 'Finalizar';
  String workoutStartTime(String time) =>
      isEnglish ? 'Start $time' : 'Inicio $time';
  String get workoutName => isEnglish
      ? 'Workout name'
      : 'Nombre del entrenamiento';
  String get selectedExerciseForHeartRateBadge => isEnglish
      ? 'Selected exercise for HR'
      : 'Ejercicio seleccionado para FC';
  String get deleteExercise => isEnglish
      ? 'Delete exercise'
      : 'Eliminar ejercicio';
  String get set => isEnglish ? 'Set' : 'Serie';
  String get noSetsYet => isEnglish
      ? 'No sets logged yet.'
      : 'Sin series registradas todavia.';
  String get noHistoryForExercise => isEnglish
      ? 'No history'
      : 'Sin historial';
  String get lastTime => isEnglish ? 'Last time' : 'Ultima vez';
  String get noRecordsForExercise => isEnglish
      ? 'This exercise has no records yet.'
      : 'Este ejercicio aun no tiene registros.';
  String setLabel(int index) => isEnglish ? 'Set $index' : 'Serie $index';
  String repsLabel(int reps) => isEnglish ? '$reps reps' : '$reps reps';
  String get deleteSet => isEnglish ? 'Delete set' : 'Eliminar serie';
  String get delete => isEnglish ? 'Delete' : 'Eliminar';
  String get logSet => isEnglish ? 'Log set' : 'Registrar serie';
  String get reps => isEnglish ? 'Reps' : 'Repeticiones';
  String get weightKgLabel => isEnglish ? 'Weight (kg)' : 'Peso (kg)';
  String get pickExercise => isEnglish ? 'Add exercise' : 'Anadir ejercicio';
  String get pickExerciseCopy => isEnglish
      ? 'Pick one from the catalog or create a new one for this session.'
      : 'Selecciona del catalogo o crea uno nuevo para esta sesion.';
  String get searchExercise => isEnglish ? 'Search exercise' : 'Buscar ejercicio';
  String get noExerciseMatches => isEnglish
      ? 'No exercises match that name.'
      : 'No hay ejercicios con ese nombre.';
  String get customExercise => isEnglish
      ? 'Custom exercise'
      : 'Ejercicio personalizado';
  String get exerciseName => isEnglish
      ? 'Exercise name'
      : 'Nombre del ejercicio';
  String get muscleGroup => isEnglish ? 'Muscle group' : 'Grupo muscular';
  String get createExercise => isEnglish ? 'Create exercise' : 'Crear ejercicio';
  String get measurementsTitle => isEnglish ? 'Measurements' : 'Medidas';
  String get exerciseProgress => isEnglish
      ? 'Exercise progress'
      : 'Progreso por ejercicio';
  String exerciseHistoryCount(int count) => isEnglish
      ? '$count exercises with tracked history.'
      : '$count ejercicios con historico registrado.';
  String get notEnoughExerciseHistory => isEnglish
      ? 'There is not enough history yet.'
      : 'Todavia no hay historico suficiente.';
  String get progressEmptyCopy => isEnglish
      ? 'Finish workouts and save sets to see progress here.'
      : 'Finaliza entrenamientos y guarda series para ver progreso aqui.';
  String get summary => isEnglish ? 'Summary' : 'Resumen';
  String get sessions => isEnglish ? 'Sessions' : 'Sesiones';
  String get bestWeight => isEnglish ? 'Best weight' : 'Mejor peso';
  String get totalVolume => isEnglish ? 'Total volume' : 'Volumen total';
  String get latestVolume => isEnglish ? 'Latest volume' : 'Ultimo volumen';
  String get volumeEvolution => isEnglish
      ? 'Volume evolution'
      : 'Evolucion de volumen';
  String get latestSessions => isEnglish
      ? 'Latest sessions'
      : 'Ultimas sesiones';
  String get noDataForExercise => isEnglish
      ? 'No data for this exercise.'
      : 'Sin datos para este ejercicio.';
  String get exercisesLabelShort => isEnglish ? 'Exercises' : 'Ejercicios';
  String get average => isEnglish ? 'Average' : 'Media';
  String get maximum => isEnglish ? 'Maximum' : 'Maxima';
  String heartRateSampleCount(int count) => isEnglish
      ? '$count samples recorded during this session.'
      : '$count muestras registradas durante la sesion.';
  String get noHeartRateSamplesInWorkout => isEnglish
      ? 'There are no heart rate samples in this workout.'
      : 'No hay muestras de frecuencia cardiaca en este entrenamiento.';
  String get maxWeightShort => isEnglish ? 'Max weight' : 'Peso max.';
  String get averageHeartRateLabel => isEnglish ? 'Avg. HR' : 'FC media';
  String get maxHeartRateLabel => isEnglish ? 'Max. HR' : 'FC max.';
  String get samples => isEnglish ? 'Samples' : 'Muestras';
  String exerciseSetDetail(int index, int reps, String weight) => isEnglish
      ? 'Set $index · $reps reps · $weight kg'
      : 'Serie $index · $reps reps · $weight kg';
  String get name => isEnglish ? 'Name' : 'Nombre';
  String get deleteExerciseTitle => isEnglish
      ? 'Delete exercise'
      : 'Eliminar ejercicio';
  String deleteExerciseMessage(String name) => isEnglish
      ? '"$name" and all its logged sets in this session will be removed.'
      : 'Se borrara "$name" y todas sus series registradas en esta sesion.';
  String get deleteSetTitle => isEnglish ? 'Delete set' : 'Eliminar serie';
  String deleteSetMessage(String name) => isEnglish
      ? 'This set from "$name" will be removed.'
      : 'Se borrara esta serie del ejercicio "$name".';
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
