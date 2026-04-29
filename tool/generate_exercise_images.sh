#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEED_FILE="$ROOT_DIR/assets/seed/exercises_seed.json"
OUT_DIR="$ROOT_DIR/assets/exercises"
TMP_FILE="$ROOT_DIR/tool/.exercise_prompts.tsv"
FORCE_MODE="${1:-}"

mkdir -p "$OUT_DIR"

node -e '
const fs = require("fs");
const path = process.argv[1];
const out = process.argv[2];
const data = JSON.parse(fs.readFileSync(path, "utf8"));
const lines = data.map((item) => {
  const file = item.imageAssetPath || "";
  const prompt = item.imagePrompt || "";
  return `${file}\t${prompt}`;
});
fs.writeFileSync(out, `${lines.join("\n")}\n`, "utf8");
' "$SEED_FILE" "$TMP_FILE"

echo "Generating images into $OUT_DIR"
while IFS=$'\t' read -r rel_path prompt; do
  [[ -z "$rel_path" ]] && continue
  abs_path="$ROOT_DIR/$rel_path"
  mkdir -p "$(dirname "$abs_path")"

  if [[ -f "$abs_path" && "$FORCE_MODE" != "--force" ]]; then
    continue
  fi

  encoded_prompt=$(node -p 'encodeURIComponent(process.argv[1])' "$prompt")
  url="https://image.pollinations.ai/prompt/${encoded_prompt}?width=768&height=1024&nologo=true"

  echo "- $(basename "$abs_path")"
  success=0
  for attempt in 1 2 3; do
    if curl -L --fail --silent --show-error --connect-timeout 15 --max-time 90 "$url" -o "$abs_path"; then
      success=1
      break
    fi
    echo "  retry $attempt failed for $(basename "$abs_path")"
  done

  if [[ "$success" -eq 0 ]]; then
    echo "  failed to generate $(basename "$abs_path"), continuing"
  fi
done < "$TMP_FILE"

rm -f "$TMP_FILE"
echo "Done"
