#!/usr/bin/env zsh

set -euo pipefail

if [[ "$OSTYPE" != darwin* ]]; then
  echo "[cleanup-load] macOS-only helper; nothing to clean on $OSTYPE."
  exit 0
fi

echo "[cleanup-load] Stopping Graphite background workers..."
pkill -f '/opt/homebrew/Cellar/graphite/.*/bin/gt .*background' 2>/dev/null || true

echo "[cleanup-load] Stopping Conductor-linked WebKit workers..."
for pid in ${(f)"$(pgrep -f 'com.apple.WebKit.WebContent|com.apple.WebKit.GPU' 2>/dev/null || true)"}; do
  if lsof -p "$pid" 2>/dev/null | grep -q 'com.conductor.app/WebKit'; then
    kill "$pid" 2>/dev/null || true
  fi
done

echo "[cleanup-load] Snapshot after cleanup:"
uptime
top -l 1 -n 0 | awk '/Processes:/ || /Load Avg:/ || /CPU usage:/ || /PhysMem/ {print}'
