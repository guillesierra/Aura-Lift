import 'package:flutter/material.dart';

import '../models/app_settings.dart';

class AppStrings {
  const AppStrings._(this.languageCode);

  final String languageCode;

  bool get isEnglish => languageCode == 'en';

  static AppStrings of(String languageCode) => AppStrings._(languageCode);

  String get appName => 'Aura Lift';
  String get onboardingTitle =>
      isEnglish ? 'Set your base' : 'Configura tu base';
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
  String get readyToTrain =>
      isEnglish ? 'Ready to train' : 'Listo para entrenar';
  String get activeSession => isEnglish ? 'Active session' : 'Sesion activa';
  String get quickStartCopy => isEnglish
      ? 'Start fast and log everything from one focused screen.'
      : 'Empieza rapido y registra todo desde una sola pantalla.';
  String sessionSummary(int exercises, int sets) => isEnglish
      ? '$exercises exercises · $sets sets'
      : '$exercises ejercicios · $sets series';
  String get startWorkout =>
      isEnglish ? 'Start workout' : 'Empezar entrenamiento';
  String get resumeWorkout =>
      isEnglish ? 'Resume workout' : 'Reanudar entrenamiento';
  String get quickMetrics => isEnglish ? 'Quick metrics' : 'Metricas rapidas';
  String get height => isEnglish ? 'Height' : 'Altura';
  String get weight => isEnglish ? 'Weight' : 'Peso';
  String get bodyType => isEnglish ? 'Body type' : 'Tipo de cuerpo';
  String get recentHistory =>
      isEnglish ? 'Recent history' : 'Historial reciente';
  String get homeInsights =>
      isEnglish ? 'Training insights' : 'Resumen de entreno';
  String get searchProfiles =>
      isEnglish ? 'Search profiles' : 'Buscar perfiles';
  String get socialHub => isEnglish ? 'Social' : 'Social';
  String get followProfile => isEnglish ? 'Follow' : 'Seguir';
  String get unfollowProfile => isEnglish ? 'Unfollow' : 'Dejar de seguir';
  String get viewProfile => isEnglish ? 'View profile' : 'Ver perfil';
  String get friendsStatus => isEnglish ? 'Friends' : 'Amigos';
  String get requestSentStatus =>
      isEnglish ? 'Request sent' : 'Solicitud enviada';
  String get requestReceivedStatus =>
      isEnglish ? 'Wants to connect' : 'Quiere conectar';
  String get acceptRequest =>
      isEnglish ? 'Accept request' : 'Aceptar solicitud';
  String get decline => isEnglish ? 'Decline' : 'Rechazar';
  String get incomingRequests =>
      isEnglish ? 'Incoming requests' : 'Solicitudes recibidas';
  String get outgoingRequests =>
      isEnglish ? 'Outgoing requests' : 'Solicitudes enviadas';
  String get noIncomingRequests =>
      isEnglish ? 'No incoming requests.' : 'No hay solicitudes recibidas.';
  String get noOutgoingRequests =>
      isEnglish ? 'No outgoing requests.' : 'No hay solicitudes enviadas.';
  String get cancelRequest =>
      isEnglish ? 'Cancel request' : 'Cancelar solicitud';
  String get removeFriend => isEnglish ? 'Remove friend' : 'Eliminar amigo';
  String get changeFriendPhoto =>
      isEnglish ? 'Change friend photo' : 'Cambiar foto del amigo';
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
  String get personalStatsTitle =>
      isEnglish ? 'Personal stats' : 'Estadisticas personales';
  String personalStatsCopy(int count) => isEnglish
      ? '$count finished workouts included in these numbers.'
      : '$count entrenos terminados incluidos en estos numeros.';
  String get personalStatsEmpty => isEnglish
      ? 'Finish workouts to unlock your training stats.'
      : 'Finaliza entrenos para desbloquear tus estadisticas.';
  String get activeDays => isEnglish ? 'Active days' : 'Dias activos';
  String get averageSession => isEnglish ? 'Average session' : 'Sesion media';
  String get totalSetsLabel => isEnglish ? 'Total sets' : 'Series totales';
  String get averageHeartRate => isEnglish ? 'Average HR' : 'FC media';
  String get estimatedCalories =>
      isEnglish ? 'Estimated kcal' : 'Kcal estimadas';
  String get totalCalories => isEnglish ? 'Total kcal' : 'Kcal totales';
  String get caloriesUnit => 'kcal';
  String get topExercise => isEnglish ? 'Top exercise' : 'Ejercicio top';
  String get heaviestLift => isEnglish ? 'Heaviest lift' : 'Mayor carga';
  String get noExerciseData =>
      isEnglish ? 'No exercise data yet.' : 'Aun no hay datos de ejercicios.';
  String get exercises => isEnglish ? 'Exercises' : 'Ejercicios';
  String get measurements => isEnglish ? 'Measurements' : 'Medidas';
  String get calendar => isEnglish ? 'Calendar' : 'Calendario';
  String get workoutCalendarTitle =>
      isEnglish ? 'Workout calendar' : 'Calendario de entrenos';
  String workoutCalendarCopy(int count) => isEnglish
      ? '$count finished workouts grouped by day.'
      : '$count entrenos terminados agrupados por dia.';
  String get workoutCalendarEmpty => isEnglish
      ? 'Finish workouts to see them grouped by date here.'
      : 'Finaliza entrenos para verlos aqui agrupados por fecha.';
  String dayWorkoutCount(int count) =>
      isEnglish ? '$count workouts' : '$count entrenos';
  String get info => isEnglish ? 'Information' : 'Informacion';
  String get friends => isEnglish ? 'Friends' : 'Amigos';
  String get noFriendsYet =>
      isEnglish ? 'You have no friends yet.' : 'Aun no tienes amigos.';
  String get changeProfilePhoto =>
      isEnglish ? 'Change profile photo' : 'Cambiar foto de perfil';
  String get removeProfilePhoto =>
      isEnglish ? 'Remove profile photo' : 'Quitar foto de perfil';
  String get profileSettings =>
      isEnglish ? 'Profile settings' : 'Configuracion de perfil';
  String get account => isEnglish ? 'Account' : 'Cuenta';
  String get notConnected => isEnglish ? 'Not connected' : 'Sin conexion';
  String connectedWith(String provider) =>
      isEnglish ? 'Connected with $provider' : 'Conectado con $provider';
  String get connectGoogle =>
      isEnglish ? 'Sign in with Google' : 'Iniciar con Google';
  String get connectApple =>
      isEnglish ? 'Sign in with Apple' : 'Iniciar con Apple';
  String get disconnectAccount => isEnglish ? 'Sign out' : 'Cerrar sesion';
  String get authCancelled =>
      isEnglish ? 'Login cancelled.' : 'Inicio de sesion cancelado.';
  String get authUnsupported => isEnglish
      ? 'Provider not available on this device.'
      : 'Proveedor no disponible en este dispositivo.';
  String get authSuccess =>
      isEnglish ? 'Account connected.' : 'Cuenta conectada.';
  String authError(String message) =>
      isEnglish ? 'Login error: $message' : 'Error de inicio: $message';
  String get dataTransfer =>
      isEnglish ? 'Workout CSV' : 'CSV de entrenamientos';
  String get exportCsv => isEnglish ? 'Export CSV' : 'Exportar CSV';
  String get importCsv => isEnglish ? 'Import CSV' : 'Importar CSV';
  String get replaceExistingWorkouts =>
      isEnglish ? 'Replace existing history' : 'Reemplazar historial actual';
  String get heartRateCoachSettings =>
      isEnglish ? 'Heart-rate coach' : 'Coach de frecuencia cardiaca';
  String get baseHeartRateBpm =>
      isEnglish ? 'Base heart rate (bpm)' : 'Frecuencia base (lpm)';
  String get returnCueBpm =>
      isEnglish ? 'Back-to-work cue (bpm)' : 'Aviso de vuelta (lpm)';
  String get heartRateCoachSettingsHint => '';
  String get baseHeartRateRangeHint => isEnglish
      ? 'Recommended range: 40-120 bpm'
      : 'Rango recomendado: 40-120 lpm';
  String get returnCueRangeHint => isEnglish
      ? 'Recommended range: 60-170 bpm'
      : 'Rango recomendado: 60-170 lpm';
  String heartRateRangeError(int min, int max) => isEnglish
      ? 'Use a value between $min and $max.'
      : 'Usa un valor entre $min y $max.';
  String csvExported(String path) =>
      isEnglish ? 'CSV exported to $path' : 'CSV exportado en $path';
  String get csvExportCancelled =>
      isEnglish ? 'Export cancelled.' : 'Exportacion cancelada.';
  String get csvImportCancelled =>
      isEnglish ? 'Import cancelled.' : 'Importacion cancelada.';
  String get csvImportEmpty => isEnglish
      ? 'No workouts found in CSV.'
      : 'No se encontraron entrenos en el CSV.';
  String csvImported(int sessions, int sets) => isEnglish
      ? 'Imported $sessions workouts and $sets sets.'
      : 'Importados $sessions entrenos y $sets series.';
  String csvImportError(String message) => isEnglish
      ? 'CSV import error: $message'
      : 'Error importando CSV: $message';
  String get city => isEnglish ? 'City' : 'Ciudad';
  String get gym => isEnglish ? 'Gym' : 'Gimnasio';
  String get presentation => isEnglish ? 'Presentation' : 'Presentacion';
  String totalFriendsCount(int count) =>
      isEnglish ? '$count friends' : '$count amigos';
  String get settings => isEnglish ? 'Settings' : 'Configuracion';
  String get appearance => isEnglish ? 'Appearance' : 'Apariencia';
  String get appearanceStyle => isEnglish ? 'Visual style' : 'Estilo visual';
  String get theme => isEnglish ? 'Theme' : 'Tema';
  String get language => isEnglish ? 'Language' : 'Idioma';
  String get menuAnimations =>
      isEnglish ? 'Menu animations' : 'Animaciones de menu';
  String get followSystem => isEnglish ? 'System' : 'Sistema';
  String get light => isEnglish ? 'Light' : 'Claro';
  String get dark => isEnglish ? 'Dark' : 'Oscuro';
  String get classic => isEnglish ? 'Classic' : 'Clasico';
  String get liquidGlass => isEnglish ? 'Liquid Glass' : 'Liquid Glass';
  String get spanish => isEnglish ? 'Spanish' : 'Espanol';
  String get english => isEnglish ? 'English' : 'Ingles';
  String get close => isEnglish ? 'Close' : 'Cerrar';
  String get time => isEnglish ? 'Time' : 'Tiempo';
  String get sets => isEnglish ? 'Sets' : 'Series';
  String get heartRateShort => isEnglish ? 'HR' : 'FC';
  String get auraPoints => isEnglish ? 'Aura Points' : 'Aura Points';
  String get auraPointsShort => isEnglish ? 'AP' : 'AP';
  String get annualLeague => isEnglish ? 'Annual league' : 'Liga anual';
  String get heartRateUnit => isEnglish ? 'bpm' : 'lpm';
  String get rename => isEnglish ? 'Rename' : 'Renombrar';
  String get deleteWorkout =>
      isEnglish ? 'Delete workout' : 'Eliminar entrenamiento';
  String get renameWorkout =>
      isEnglish ? 'Rename workout' : 'Renombrar entrenamiento';
  String get title => isEnglish ? 'Title' : 'Titulo';
  String get cancel => isEnglish ? 'Cancel' : 'Cancelar';
  String get save => isEnglish ? 'Save' : 'Guardar';
  String deleteWorkoutMessage(String title) => isEnglish
      ? '"$title" will be removed from history. This action cannot be undone.'
      : 'Se eliminara "$title" del historial. Esta accion no se puede deshacer.';
  String get saveChanges => isEnglish ? 'Save changes' : 'Guardar cambios';
  String get workoutSessionEmptyTitle =>
      isEnglish ? 'There is no active session' : 'No hay una sesion activa';
  String get workoutSessionEmptyCopy => isEnglish
      ? 'Go back home and create a new workout.'
      : 'Vuelve a inicio y crea un entreno nuevo.';
  String get startWithExercise =>
      isEnglish ? 'Start with one exercise' : 'Empieza por un ejercicio';
  String get startWithExerciseCopy => isEnglish
      ? 'Add exercises from the catalog and log your sets with weight and reps.'
      : 'Anade ejercicios desde el catalogo y registra tus series con peso y repeticiones.';
  String get addExercise => isEnglish ? 'Add exercise' : 'Anadir ejercicio';
  String get heartRate => isEnglish ? 'Heart rate' : 'Frecuencia cardiaca';
  String get syncAppleHealth =>
      isEnglish ? 'Sync Apple Health' : 'Sincronizar Apple Health';
  String get syncHeartHealth =>
      isEnglish ? 'Sync Health data' : 'Sincronizar datos de salud';
  String get appleHealthHeartRateCopy => isEnglish
      ? 'Imports heart-rate samples written in Apple Health by Apple Watch or compatible Apple devices.'
      : 'Importa muestras de frecuencia cardiaca guardadas en Apple Health por Apple Watch o dispositivos Apple compatibles.';
  String get heartHealthCopy => isEnglish
      ? 'Imports heart-rate samples from Apple Health (iPhone) or Health Connect/Google Fit (Android devices).'
      : 'Importa muestras de frecuencia cardiaca desde Apple Health (iPhone) o Health Connect/Google Fit (dispositivos Android).';
  String get appleHealthSyncing =>
      isEnglish ? 'Reading Apple Health...' : 'Leyendo Apple Health...';
  String get heartHealthSyncing =>
      isEnglish ? 'Reading health data...' : 'Leyendo datos de salud...';
  String get appleHealthUnsupported => isEnglish
      ? 'Apple Health sync is available on iPhone.'
      : 'La sincronizacion con Apple Health esta disponible en iPhone.';
  String get heartHealthUnsupported => isEnglish
      ? 'Health sync is available on iPhone and Android.'
      : 'La sincronizacion de salud esta disponible en iPhone y Android.';
  String get appleHealthDenied => isEnglish
      ? 'Heart-rate permission was not granted in Apple Health.'
      : 'No se concedio permiso de frecuencia cardiaca en Apple Health.';
  String get heartHealthDenied => isEnglish
      ? 'Heart-rate permission was not granted in your health app.'
      : 'No se concedio permiso de frecuencia cardiaca en tu app de salud.';
  String appleHealthImported(int count) => isEnglish
      ? '$count heart-rate samples imported.'
      : '$count muestras de frecuencia cardiaca importadas.';
  String heartHealthImported(int count) => isEnglish
      ? '$count heart-rate samples imported.'
      : '$count muestras de frecuencia cardiaca importadas.';
  String get appleHealthNoSamples => isEnglish
      ? 'No Apple Health heart-rate samples found for this workout.'
      : 'No se encontraron muestras de frecuencia cardiaca en Apple Health para este entreno.';
  String get heartHealthNoSamples => isEnglish
      ? 'No heart-rate samples found for this workout in your health app.'
      : 'No se encontraron muestras de frecuencia cardiaca para este entreno en tu app de salud.';
  String get appleHealthSyncFailed => isEnglish
      ? 'Apple Health sync failed.'
      : 'No se pudo sincronizar Apple Health.';
  String get heartHealthSyncFailed => isEnglish
      ? 'Health sync failed.'
      : 'No se pudo sincronizar la app de salud.';
  String get startWearableStream => isEnglish
      ? 'Start wearable live stream'
      : 'Iniciar stream en vivo del wearable';
  String get stopWearableStream => isEnglish
      ? 'Stop wearable live stream'
      : 'Detener stream en vivo del wearable';
  String get wearableStreamStarted => isEnglish
      ? 'Wearable heart-rate live stream started.'
      : 'Stream en vivo de frecuencia cardiaca iniciado.';
  String get wearableStreamStopped => isEnglish
      ? 'Wearable heart-rate live stream stopped.'
      : 'Stream en vivo de frecuencia cardiaca detenido.';
  String get wearableStreamUnsupported => isEnglish
      ? 'Wearable live stream is not supported on this device.'
      : 'El stream en vivo no esta soportado en este dispositivo.';
  String get wearableStreamDenied => isEnglish
      ? 'Health permission is required to start wearable live stream.'
      : 'Se requiere permiso de salud para iniciar el stream en vivo.';
  String get wearableStreamFailed => isEnglish
      ? 'Could not start wearable live stream.'
      : 'No se pudo iniciar el stream en vivo del wearable.';
  String get noHeartRateSamplesYet =>
      isEnglish ? 'No samples yet' : 'Sin muestras todavia';
  String selectedExerciseForHeartRate(String exerciseName) => isEnglish
      ? 'Current exercise: $exerciseName'
      : 'Ejercicio actual: $exerciseName';
  String heartRateBaseline(int baseline, int threshold) => isEnglish
      ? 'Baseline $baseline bpm · back-to-work cue at $threshold bpm'
      : 'Base $baseline lpm · aviso de vuelta $threshold lpm';
  String get recentSamples =>
      isEnglish ? 'Recent samples' : 'Muestras recientes';
  String get editName => isEnglish ? 'Edit name' : 'Editar nombre';
  String get finish => isEnglish ? 'Finish' : 'Finalizar';
  String get finishWorkoutTitle =>
      isEnglish ? 'Finish workout?' : '¿Finalizar entrenamiento?';
  String get finishWorkoutMessage => isEnglish
      ? 'This will close the active session and save it to your history.'
      : 'Esto cerrara la sesion activa y la guardara en tu historial.';
  String workoutStartTime(String time) =>
      isEnglish ? 'Start $time' : 'Inicio $time';
  String get workoutName =>
      isEnglish ? 'Workout name' : 'Nombre del entrenamiento';
  String get selectedExerciseForHeartRateBadge =>
      isEnglish ? 'Current exercise' : 'Ejercicio actual';
  String get deleteExercise =>
      isEnglish ? 'Delete exercise' : 'Eliminar ejercicio';
  String get set => isEnglish ? 'Set' : 'Serie';
  String get noSetsYet =>
      isEnglish ? 'No sets logged yet.' : 'Sin series registradas todavia.';
  String get noHistoryForExercise => isEnglish ? 'No history' : 'Sin historial';
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
  String get searchExercise =>
      isEnglish ? 'Search exercise' : 'Buscar ejercicio';
  String get noExerciseMatches => isEnglish
      ? 'No exercises match that name.'
      : 'No hay ejercicios con ese nombre.';
  String get customExercise =>
      isEnglish ? 'Custom exercise' : 'Ejercicio personalizado';
  String get exerciseName =>
      isEnglish ? 'Exercise name' : 'Nombre del ejercicio';
  String get muscleGroup => isEnglish ? 'Muscle group' : 'Grupo muscular';
  String get allMuscleGroups =>
      isEnglish ? 'All muscle groups' : 'Todos los grupos';
  String get equipment => isEnglish ? 'Equipment' : 'Equipamiento';
  String get allEquipment => isEnglish ? 'All equipment' : 'Todo';
  String get createExercise =>
      isEnglish ? 'Create exercise' : 'Crear ejercicio';
  String get measurementsTitle => isEnglish ? 'Measurements' : 'Medidas';
  String get exerciseProgress =>
      isEnglish ? 'Exercise progress' : 'Progreso por ejercicio';
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
  String get volumeEvolution =>
      isEnglish ? 'Volume evolution' : 'Evolucion de volumen';
  String get latestSessions =>
      isEnglish ? 'Latest sessions' : 'Ultimas sesiones';
  String get noDataForExercise => isEnglish
      ? 'No data for this exercise.'
      : 'Sin datos para este ejercicio.';
  String get improvementCardTitle =>
      isEnglish ? 'Improvement radar' : 'Radar de mejora';
  String get improvementCardSubtitle => isEnglish
      ? 'Recommendations based on your recent training load and potential overuse patterns.'
      : 'Recomendaciones basadas en tu carga reciente y posibles patrones de sobreuso.';
  String get improvementCardEmpty => isEnglish
      ? 'Complete more workouts to unlock actionable recommendations.'
      : 'Completa mas entrenos para desbloquear recomendaciones accionables.';
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
  String get deleteExerciseTitle =>
      isEnglish ? 'Delete exercise' : 'Eliminar ejercicio';
  String deleteExerciseMessage(String name) => isEnglish
      ? '"$name" and all its logged sets in this session will be removed.'
      : 'Se borrara "$name" y todas sus series registradas en esta sesion.';
  String get deleteSetTitle => isEnglish ? 'Delete set' : 'Eliminar serie';
  String deleteSetMessage(String name) => isEnglish
      ? 'This set from "$name" will be removed.'
      : 'Se borrara esta serie del ejercicio "$name".';
  String get profileComparison =>
      isEnglish ? 'Profile comparison' : 'Comparativa de perfiles';
  String get trainingTime =>
      isEnglish ? 'Training time' : 'Tiempo de entrenamiento';
  String get totalWeightLifted =>
      isEnglish ? 'Total weight lifted' : 'Peso total levantado';
  String get bestLift => isEnglish ? 'Best lift' : 'Mejor marca';
  String get sharedExerciseRecords => isEnglish
      ? 'Shared exercise records'
      : 'Marcas en ejercicios compartidos';
  String get noSharedExercises => isEnglish
      ? 'No shared exercises yet.'
      : 'Aun no hay ejercicios compartidos.';
  String get youLabel => isEnglish ? 'You' : 'Tu';
  String get heSheLabel => isEnglish ? 'They' : 'El/Ella';

  String get minimumWorkoutsForRecommendations => isEnglish
      ? 'Log at least three workouts to unlock personalized recommendations.'
      : 'Registra al menos tres entrenos para desbloquear recomendaciones personalizadas.';

  String muscleLoadConcentrationWarning(String muscleGroup, int percentage) => isEnglish
      ? 'You are concentrating too much load on $muscleGroup ($percentage% of recent sets). Add 1-2 sessions for antagonist muscles to reduce overuse risk.'
      : 'Estas concentrando demasiada carga en $muscleGroup ($percentage% de tus series recientes). Añade 1-2 sesiones de grupos antagonistas para reducir riesgo de sobreuso.';

  String highJointStressWarning(String localizedJointName) => isEnglish
      ? 'High repeated stress detected on $localizedJointName. Consider reducing heavy volume 20-30% this week and prioritize mobility and technique work.'
      : 'Se detecta estres repetido alto en $localizedJointName. Considera bajar 20-30% el volumen pesado esta semana y priorizar movilidad y tecnica.';

  String get consecutiveDaysTrainingWarning => isEnglish
      ? 'You are training on many consecutive days. Plan at least one full recovery day to improve adaptation and lower injury probability.'
      : 'Estas entrenando muchos dias consecutivos. Programa al menos un dia completo de recuperacion para mejorar adaptacion y bajar probabilidad de lesion.';

  String get balancedLoadMessage => isEnglish
      ? 'Your recent load looks balanced. Keep progressive overload moderate and include mobility before heavy compounds.'
      : 'Tu carga reciente se ve equilibrada. Manten una sobrecarga progresiva moderada e incluye movilidad antes de compuestos pesados.';

  String get tipSquat => isEnglish
      ? 'Keep your chest proud, brace your core, and track knees in line with your toes.'
      : 'Pecho arriba, abdomen firme y rodillas siguiendo la linea de los pies.';
  String get tipDeadlift => isEnglish
      ? 'Start by bracing your core, keep the bar close, and drive with hips and legs together.'
      : 'Activa el core, barra pegada al cuerpo y empuja con cadera y piernas a la vez.';
  String get tipBenchPress => isEnglish
      ? 'Retract your shoulder blades, keep feet planted, and lower the bar with control to mid chest.'
      : 'Escapulas atras, pies firmes y baja la barra con control al centro del pecho.';
  String get tipPulldown => isEnglish
      ? 'Initiate with scapular depression, pull elbows down, and avoid swinging your torso.'
      : 'Inicia bajando escapulas, lleva codos hacia abajo y evita balancear el torso.';
  String get tipRow => isEnglish
      ? 'Keep a neutral spine, pull with elbows, and pause briefly with shoulder blades squeezed.'
      : 'Manten columna neutra, tira con codos y aprieta escapulas un instante al final.';
  String get tipCurl => isEnglish
      ? 'Keep elbows fixed near the torso, avoid momentum, and control the negative phase.'
      : 'Codos pegados al torso, sin impulso y controla bien la fase de bajada.';
  String get tipTriceps => isEnglish
      ? 'Lock your upper arm position, extend fully without snapping, and return under control.'
      : 'Fija el brazo, extiende completo sin bloquear brusco y vuelve con control.';
  String get tipShoulders => isEnglish
      ? 'Ribs down, glutes tight, and raise with control without shrugging your shoulders.'
      : 'Costillas abajo, gluteo firme y eleva con control sin encoger los hombros.';
  String get tipCore => isEnglish
      ? 'Keep your pelvis neutral, breathe steadily, and prioritize tension over speed.'
      : 'Manten pelvis neutra, respiracion estable y prioriza tension antes que velocidad.';
  String get tipCardio => isEnglish
      ? 'Stay tall, keep breathing rhythmically, and maintain a pace you can sustain with technique.'
      : 'Postura alta, respiracion ritmica y un ritmo sostenible sin perder tecnica.';
  String get tipFallbackChest => isEnglish
      ? 'Control the eccentric phase and keep your shoulders packed to protect the joint.'
      : 'Controla la bajada y manten hombros estables para proteger la articulacion.';
  String get tipFallbackBack => isEnglish
      ? 'Lead with elbows and keep your chest open to engage your back properly.'
      : 'Guia con codos y manten el pecho abierto para activar bien la espalda.';
  String get tipFallbackLegs => isEnglish
      ? 'Use full range of motion and keep pressure balanced across your feet.'
      : 'Usa rango completo y reparte la presion de forma equilibrada en los pies.';
  String get tipFallbackShoulders => isEnglish
      ? 'Stabilize the trunk first, then move with smooth, controlled repetitions.'
      : 'Primero estabiliza el tronco y luego mueve con repeticiones fluidas y controladas.';
  String get tipFallbackArms => isEnglish
      ? 'Keep strict form and avoid compensating with your hips or lower back.'
      : 'Tecnica estricta y evita compensar con cadera o zona lumbar.';
  String get tipFallbackCore => isEnglish
      ? 'Brace your midline and maintain diaphragmatic breathing through the set.'
      : 'Activa la zona media y respira con control diafragmatico durante toda la serie.';
  String get tipFallbackGeneric => isEnglish
      ? 'Move with control, keep your posture aligned, and prioritize clean technique.'
      : 'Mueve con control, postura alineada y prioriza una tecnica limpia.';

  String jointName(String key) {
    switch (key) {
      case 'rodilla':
        return isEnglish ? 'knee joint' : 'la rodilla';
      case 'hombro':
        return isEnglish ? 'shoulder joint' : 'el hombro';
      case 'codo':
        return isEnglish ? 'elbow joint' : 'el codo';
      case 'lumbar':
        return isEnglish ? 'lumbar zone' : 'la zona lumbar';
      default:
        return isEnglish ? 'a joint' : 'una articulacion';
    }
  }
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

extension AppAppearanceLabel on AppAppearance {
  String localizedLabel(AppStrings strings) {
    switch (this) {
      case AppAppearance.classic:
        return strings.classic;
      case AppAppearance.liquidGlass:
        return strings.liquidGlass;
    }
  }
}
