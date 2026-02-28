#!/bin/bash
cd "$HOME/projects/astral-system"

clear
echo ""
echo "  ASTRAL SYSTEM"
echo "  ────────────────"
echo ""
echo "  Apps:"

for dir in "$HOME/projects/astral-system/apps"/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  [[ "$name" == "client-starter" ]] && continue
  echo "    $name"
done

count=$(ls -d "$HOME/projects/astral-system/apps"/*/ 2>/dev/null | grep -v client-starter | wc -l | tr -d ' ')
if [[ "$count" == "0" ]]; then
  echo "    (none yet)"
fi

echo ""
exec zsh -l
