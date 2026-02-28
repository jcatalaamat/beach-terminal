#!/bin/bash
cd "$HOME/projects/astral-system"

clear
echo ""
echo "  ASTRAL SYSTEM"
echo "  ────────────────"

# Monorepo apps (sorted by last modified, newest first)
echo ""
echo "  Monorepo apps:"
found=0
for dir in $(ls -dt "$HOME/projects/astral-system/apps"/*/ 2>/dev/null); do
  name=$(basename "$dir")
  [[ "$name" == "client-starter" ]] && continue
  mod=$(stat -f "%Sm" -t "%b %d" "$dir" 2>/dev/null)
  echo "    $name  ($mod)"
  found=1
done
[[ $found -eq 0 ]] && echo "    (none yet)"

# Standalone projects (sorted by last modified)
echo ""
echo "  Standalone (~/astral-workspace):"
found=0
for dir in $(ls -dt "$HOME/astral-workspace"/*/ 2>/dev/null); do
  name=$(basename "$dir")
  [[ "$name" == "node_modules" || "$name" == ".claude" ]] && continue
  mod=$(stat -f "%Sm" -t "%b %d" "$dir" 2>/dev/null)
  echo "    $name  ($mod)"
  found=1
done
[[ $found -eq 0 ]] && echo "    (empty)"

# Other projects (sorted by last modified)
echo ""
echo "  Other (~/projects):"
for dir in $(ls -dt "$HOME/projects"/*/ 2>/dev/null); do
  name=$(basename "$dir")
  [[ "$name" == "astral-system" || "$name" == "beach-terminal" || "$name" == "node_modules" ]] && continue
  mod=$(stat -f "%Sm" -t "%b %d" "$dir" 2>/dev/null)
  echo "    $name  ($mod)"
done

echo ""
exec zsh -l
