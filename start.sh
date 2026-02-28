#!/bin/bash
# Beach Terminal - persistent terminals + launcher + web UI
echo "Starting Beach Terminal..."

pkill ttyd 2>/dev/null
pkill -f "server.py" 2>/dev/null
sleep 1

LAUNCHER="$HOME/beach-terminal/launcher.sh"
SESSIONS=("claude" "dev" "git" "misc" "term5" "term6" "term7" "term8")

# Pre-launch 8 tmux sessions + ttyd instances on ports 7682-7689
for i in {0..7}; do
  SESSION="${SESSIONS[$i]}"
  PORT=$((7682 + i))

  env -i HOME="$HOME" USER="$USER" PATH="$PATH" SHELL=/bin/zsh TERM=xterm-256color \
    tmux has-session -t "$SESSION" 2>/dev/null || \
    env -i HOME="$HOME" USER="$USER" PATH="$PATH" SHELL=/bin/zsh TERM=xterm-256color \
    tmux new-session -d -s "$SESSION" -c "$HOME/astral-workspace" "$LAUNCHER"

  nohup env -i HOME="$HOME" USER="$USER" PATH="$PATH" SHELL=/bin/zsh TERM=xterm-256color \
    ttyd -W -t scrollback=10000 -p $PORT tmux attach-session -t "$SESSION" > /tmp/ttyd-$PORT.log 2>&1 &
  echo "  $SESSION -> port $PORT (PID: $!)"
done

# Web UI + API on port 7681
nohup python3 /Users/astralamat/beach-terminal/server.py > /tmp/beach-ui.log 2>&1 &
echo "  Web UI + API -> port 7681 (PID: $!)"

echo ""
echo "Open on your phone:"
echo "  http://100.64.86.7:7681"
echo ""
echo "Tap + to add tabs (up to 8). Long-press a tab to close it."
echo "Sessions persist when you close your phone."
