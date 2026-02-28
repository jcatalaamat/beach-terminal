#!/bin/bash
PROJECTS_DIR="$HOME/astral-workspace"
cd "$PROJECTS_DIR"

clear
echo ""
echo "  ASTRAL WORKSPACE"
echo "  ────────────────"
echo ""

for dir in "$PROJECTS_DIR"/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  [[ "$name" == "node_modules" || "$name" == ".claude" ]] && continue
  echo "    $name"
done

count=$(ls -d "$PROJECTS_DIR"/*/ 2>/dev/null | wc -l | tr -d ' ')
if [[ "$count" == "0" ]]; then
  echo "    (empty)"
fi

echo ""
exec zsh -l
