#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const root = process.cwd();
const seedPath = path.join(root, 'assets/seed/exercises_seed.json');

const extraExercises = [
  { name: 'Press de banca agarre cerrado', muscleGroup: 'Triceps' },
  { name: 'Press inclinado con barra', muscleGroup: 'Pecho' },
  { name: 'Press horizontal en maquina', muscleGroup: 'Pecho' },
  { name: 'Cruce de poleas alto a bajo', muscleGroup: 'Pecho' },
  { name: 'Dominadas supinas', muscleGroup: 'Espalda' },
  { name: 'Remo Pendlay', muscleGroup: 'Espalda' },
  { name: 'Remo unilateral en polea', muscleGroup: 'Espalda' },
  { name: 'Pulldown unilateral', muscleGroup: 'Espalda' },
  { name: 'Press militar en maquina', muscleGroup: 'Hombros' },
  { name: 'Elevacion lateral en polea unilateral', muscleGroup: 'Hombros' },
  { name: 'Elevaciones Y en banco inclinado', muscleGroup: 'Hombros' },
  { name: 'Curl bayesiano en polea', muscleGroup: 'Biceps' },
  { name: 'Curl martillo en cuerda', muscleGroup: 'Biceps' },
  { name: 'Curl predicador en maquina', muscleGroup: 'Biceps' },
  { name: 'Extension de triceps en polea alta unilateral', muscleGroup: 'Triceps' },
  { name: 'Fondos en paralelas asistidos', muscleGroup: 'Triceps' },
  { name: 'Sentadilla hack en maquina', muscleGroup: 'Piernas' },
  { name: 'Sentadilla sumo con kettlebell', muscleGroup: 'Piernas' },
  { name: 'Peso muerto sumo', muscleGroup: 'Piernas' },
  { name: 'Puente de gluteo con banda', muscleGroup: 'Piernas' },
  { name: 'Gemelo en maquina de pie', muscleGroup: 'Gemelos' },
  { name: 'Gemelo en escalon unilateral', muscleGroup: 'Gemelos' },
  { name: 'Crunch en polea', muscleGroup: 'Core' },
  { name: 'Plancha con arrastre de disco', muscleGroup: 'Core' },
  { name: 'Woodchopper en polea', muscleGroup: 'Core' },
  { name: 'Encogimientos en maquina Smith', muscleGroup: 'Trapecio' },
  { name: 'Remo al cuello con cable', muscleGroup: 'Trapecio' },
  { name: 'Sled push', muscleGroup: 'Cardio' },
  { name: 'Ski erg', muscleGroup: 'Cardio' },
  { name: 'Carrera por intervalos en pista', muscleGroup: 'Cardio' },
];

function normalize(value) {
  return value
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .replace(/\s+/g, '');
}

function canonicalMuscleGroup(raw) {
  const key = normalize(raw);
  switch (key) {
    case 'pecho':
      return 'Pecho';
    case 'espalda':
      return 'Espalda';
    case 'hombros':
    case 'hombro':
      return 'Hombros';
    case 'biceps':
    case 'bicep':
      return 'Biceps';
    case 'triceps':
    case 'tricep':
      return 'Triceps';
    case 'piernas':
    case 'pierna':
      return 'Piernas';
    case 'gemelos':
    case 'pantorrillas':
      return 'Gemelos';
    case 'core':
    case 'abdominales':
      return 'Core';
    case 'cardio':
      return 'Cardio';
    case 'trapecio':
      return 'Trapecio';
    default:
      return 'Core';
  }
}

function inferEquipment(name) {
  const key = normalize(name);
  if (key.includes('barra') || key.includes('smith')) return 'Barra';
  if (key.includes('mancuerna') || key.includes('mancuernas')) return 'Mancuernas';
  if (key.includes('polea') || key.includes('cable')) return 'Polea';
  if (key.includes('maquina') || key.includes('prensa') || key.includes('hack')) return 'Maquina';
  if (
    key.includes('cinta') ||
    key.includes('bike') ||
    key.includes('eliptica') ||
    key.includes('ergometro') ||
    key.includes('escaladora') ||
    key.includes('ski')
  ) {
    return 'Cardio machine';
  }
  if (key.includes('kettlebell')) return 'Kettlebell';
  if (key.includes('banda')) return 'Banda';
  if (key.includes('sled')) return 'Otro';
  return 'Peso corporal';
}

function inferDifficulty(name) {
  const key = normalize(name);
  if (
    key.includes('dominada') ||
    key.includes('peso muerto') ||
    key.includes('bulgara') ||
    key.includes('burpees') ||
    key.includes('sledpush')
  ) {
    return 'Avanzado';
  }
  if (
    key.includes('maquina') ||
    key.includes('curl') ||
    key.includes('press') ||
    key.includes('remo') ||
    key.includes('polea')
  ) {
    return 'Intermedio';
  }
  return 'Principiante';
}

function inferPrimaryMuscles(muscleGroup) {
  switch (canonicalMuscleGroup(muscleGroup)) {
    case 'Pecho':
      return ['Pectoral mayor'];
    case 'Espalda':
      return ['Dorsal ancho', 'Romboides'];
    case 'Hombros':
      return ['Deltoides'];
    case 'Biceps':
      return ['Biceps braquial'];
    case 'Triceps':
      return ['Triceps braquial'];
    case 'Piernas':
      return ['Cuadriceps', 'Isquiotibiales', 'Gluteos'];
    case 'Gemelos':
      return ['Gemelos'];
    case 'Core':
      return ['Recto abdominal', 'Oblicuos'];
    case 'Cardio':
      return ['Sistema cardiovascular'];
    case 'Trapecio':
      return ['Trapecio'];
    default:
      return ['Recto abdominal'];
  }
}

function toSlug(value) {
  return value
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function buildPrompt({ name, equipment, primaryMuscles }) {
  return `White background, 3D light-gray mannequin performing "${name}" in the exact exercise posture, equipment required for the exercise in dark gray and black (${equipment}), only activated muscles highlighted in bright red: ${primaryMuscles.join(', ')}, clean anatomy style, full body visible, no realistic skin, no realistic face, no cartoon, no text, no watermark`;
}

function nextId(index) {
  const serial = String(index).padStart(3, '0');
  return `11111111-1111-1111-1111-111111111${serial}`;
}

const raw = fs.readFileSync(seedPath, 'utf8');
const current = JSON.parse(raw);

const existingNames = new Set(current.map((item) => normalize(item.name)));
const merged = [...current];

for (const exercise of extraExercises) {
  const key = normalize(exercise.name);
  if (!existingNames.has(key)) {
    merged.push({
      id: '',
      name: exercise.name,
      muscleGroup: exercise.muscleGroup,
      isCustom: false,
      createdAt: '2026-01-01T00:00:00Z',
    });
    existingNames.add(key);
  }
}

const normalized = merged.map((exercise, index) => {
  const muscleGroup = canonicalMuscleGroup(exercise.muscleGroup || 'Core');
  const equipment = inferEquipment(exercise.name || '');
  const primaryMuscles = Array.isArray(exercise.primaryMuscles) && exercise.primaryMuscles.length > 0
    ? exercise.primaryMuscles
    : inferPrimaryMuscles(muscleGroup);
  const secondaryMuscles = Array.isArray(exercise.secondaryMuscles)
    ? exercise.secondaryMuscles
    : [];
  const difficulty = exercise.difficulty || inferDifficulty(exercise.name || '');
  const slug = toSlug(exercise.name || `exercise_${index + 1}`);

  return {
    id: nextId(index + 1),
    name: exercise.name,
    muscleGroup,
    equipment,
    primaryMuscles,
    secondaryMuscles,
    difficulty,
    imageAssetPath: `assets/exercises/${slug}.png`,
    imagePrompt: buildPrompt({
      name: exercise.name,
      equipment,
      primaryMuscles,
    }),
    isCustom: Boolean(exercise.isCustom),
    createdAt: exercise.createdAt || '2026-01-01T00:00:00Z',
  };
});

fs.writeFileSync(seedPath, `${JSON.stringify(normalized, null, 2)}\n`, 'utf8');
console.log(`Catalog synced: ${normalized.length} exercises`);
