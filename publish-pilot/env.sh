# Sourced by postinstall and uninstall.sh. Needs $U (the user to act for); sets H, P, CLAUDE, NODE
# and run_as. Installer scripts run as root with a bare PATH, so look where claude and node
# usually live instead of trusting PATH.
H=$(dscl . -read "/Users/$U" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
[ -n "$H" ] || H="/Users/$U"
P="$H/.local/bin:$H/.claude/local:$H/.npm-global/bin:$H/.volta/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
for d in "$H"/.nvm/versions/node/*/bin "$H"/Library/Application\ Support/fnm/node-versions/*/installation/bin; do
  [ -d "$d" ] && P="$d:$P"
done
CLAUDE=$(PATH="$P" command -v claude || true)
NODE=$(PATH="$P" command -v node || true)

run_as() {
  sudo -u "$U" -H env HOME="$H" PATH="$P" "$@"
}
