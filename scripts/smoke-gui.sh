#!/bin/bash
# Starts a GUI binary and checks it is still running after a few seconds (no crash on launch).
# Usage: smoke-gui.sh <binary>
set -u
"$1" >/tmp/smoke.log 2>&1 &
pid=$!
sleep 6
if kill -0 "$pid" 2>/dev/null; then
  echo "still running after 6 s: ok"
  kill "$pid"
  exit 0
fi
wait "$pid"
echo "exited early with $?"
cat /tmp/smoke.log
exit 1
