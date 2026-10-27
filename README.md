# qlinter-mac-builds

Builds the macOS downloads on [qlinter.org](https://qlinter.org) from each tool's public repo, on
GitHub's macOS runners. Nothing in the tool repos is changed; each job checks out a pinned commit
or tag, builds Apple Silicon and Intel binaries, joins them into one universal binary, packages it
and smoke-tests the result.

| Tool | Source | Output |
|---|---|---|
| Project Color Picker | `acus9345/Project-Color-Picker` @ `a657650` (ai-redesigned) | `color-picker-1.0.1.dmg` |
| shipkit | `acus9345/shipkit` @ `v0.3.0` | `shipkit-0.3.0.pkg` (installs `/usr/local/bin/ship`), `.tar.gz` |
| publish-pilot | this repo's `publish-pilot/` scripts | `publish-pilot-0.4.0.pkg` (adds the MCP server to Claude Code / Claude Desktop) |
| PkgStats | `acus9345/pkgstats` @ `v0.1.5` | `pkgstats-0.1.5.dmg` |
| singbox-watch | `acus9345/singbox-proxymanager-forclaude` @ `2af30e0` (mac) | `singbox-watch-mac-1.0.0.tar.gz` |

The apps are ad-hoc signed, not signed with an Apple Developer ID or notarized, so macOS asks you
to confirm the first time: open it once, then **System Settings → Privacy & Security → Open Anyway**.

MIT, like the tools.
