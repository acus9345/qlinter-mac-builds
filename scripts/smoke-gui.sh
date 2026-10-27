#!/bin/bash
# Starts a GUI binary and checks it is still running after a few seconds (no crash on launch).
# Usage: smoke-gui.sh <binary> [ci-limitation-pattern]
# If the binary dies with output matching the optional pattern, that is a known limit of the
# CI virtual machine (for example no OpenGL), not of the app: warn and pass.
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
code=$?
cat /tmp/smoke.log
if [ -n "${2:-}" ] && grep -q "$2" /tmp/smoke.log; then
  echo "::warning::GUI smoke test skipped: the CI VM can't run it ($2). Launch-test on a real Mac."
  exit 0
fi
echo "exited early with $code"
exit 1
