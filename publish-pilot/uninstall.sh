#!/bin/bash
# Removes publish-pilot from Claude Code and Claude Desktop, then this folder.
# Run: sudo bash "/Library/Application Support/publish-pilot/uninstall.sh"
set -u
DIR="/Library/Application Support/publish-pilot"
if [ "$(id -u)" -ne 0 ]; then
  echo "Run it with sudo: sudo bash \"$DIR/uninstall.sh\"" >&2
  exit 1
fi
U=${SUDO_USER:-$(stat -f%Su /dev/console)}
. "$DIR/env.sh"

if [ -f "$DIR/claude-code-added" ] && [ -n "$CLAUDE" ]; then
  run_as "$CLAUDE" mcp remove --scope user publish-pilot && echo "removed from Claude Code"
fi
if [ -n "$NODE" ]; then
  run_as "$NODE" "$DIR/configure-desktop.mjs" remove
fi
rm -rf "$DIR"
pkgutil --forget io.github.acus9345.publish-pilot >/dev/null 2>&1
echo "publish-pilot removed"
