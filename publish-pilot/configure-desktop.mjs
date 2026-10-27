// Adds or removes the publish-pilot entry in Claude Desktop's config, on Windows and macOS.
// Usage: node configure-desktop.mjs add|remove
// Keeps every other server and writes a .bak copy before changing an existing file.
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'

const mode = process.argv[2]
if (mode !== 'add' && mode !== 'remove') {
  console.error('usage: node configure-desktop.mjs add|remove')
  process.exit(2)
}

const NAME = 'publish-pilot'
const mac = process.platform === 'darwin'

// Windows: %APPDATA%\Claude, plus the Microsoft Store package folder. macOS: Application Support.
const dirs = []
if (mac) {
  dirs.push(path.join(os.homedir(), 'Library', 'Application Support', 'Claude'))
} else {
  dirs.push(path.join(process.env.APPDATA ?? '', 'Claude'))
  const packages = path.join(process.env.LOCALAPPDATA ?? '', 'Packages')
  try {
    for (const d of fs.readdirSync(packages)) {
      if (d.startsWith('Claude_')) dirs.push(path.join(packages, d, 'LocalCache', 'Roaming', 'Claude'))
    }
  } catch {}
}

function entry() {
  if (!mac) return { command: 'cmd', args: ['/c', 'npx', '-y', 'publish-pilot-mcp'] }
  // Claude Desktop on macOS starts servers with a bare PATH (/usr/bin:/bin...), which misses
  // Homebrew and nvm. Point at the npx next to the node running this script, and give it a PATH
  // that has that node in it.
  const bin = path.dirname(process.execPath)
  const npx = path.join(bin, 'npx')
  if (!fs.existsSync(npx)) return { command: 'npx', args: ['-y', 'publish-pilot-mcp'] }
  return {
    command: npx,
    args: ['-y', 'publish-pilot-mcp'],
    env: { PATH: [bin, '/opt/homebrew/bin', '/usr/local/bin', '/usr/bin', '/bin', '/usr/sbin', '/sbin'].join(':') },
  }
}

let found = 0
for (const dir of dirs) {
  if (!fs.existsSync(dir)) continue
  found++
  const file = path.join(dir, 'claude_desktop_config.json')
  let cfg = {}
  if (fs.existsSync(file)) {
    const raw = fs.readFileSync(file, 'utf8')
    try {
      cfg = raw.trim() ? JSON.parse(raw) : {}
    } catch {
      console.error(`not valid JSON, left unchanged: ${file}`)
      process.exitCode = 1
      continue
    }
  }
  const servers = cfg.mcpServers ?? {}
  if (mode === 'add') {
    if (servers[NAME]) {
      console.log(`already there: ${file}`)
      continue
    }
    servers[NAME] = entry()
  } else {
    if (!servers[NAME]) continue
    delete servers[NAME]
  }
  cfg.mcpServers = servers
  if (fs.existsSync(file)) fs.copyFileSync(file, `${file}.bak`)
  fs.writeFileSync(file, `${JSON.stringify(cfg, null, 2)}\n`)
  console.log(`${mode === 'add' ? 'added to' : 'removed from'}: ${file}`)
}

if (mode === 'add' && found === 0) {
  console.error('Claude Desktop config folder not found')
  process.exitCode = 2
}
