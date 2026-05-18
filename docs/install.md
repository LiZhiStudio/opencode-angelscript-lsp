# Angelscript LSP — Agent Installation Guide

## ⚠️ Read before executing

This document MUST be executed by an agent. Before running any command, detect the platform:

- **Linux**: `uname -s` → `Linux`
- **macOS**: `uname -s` → `Darwin`
- **Windows**: `$env:OS` → `Windows_NT`

After detection, run ONLY the matching setup script below.

---

## Step 0: Detect platform

```powershell
# Windows PowerShell
Write-Host "[PLATFORM] $($env:OS)"
```

```bash
# Linux / macOS
echo "[PLATFORM] $(uname -s)"
```

---

## Step 1: Run setup script

### Windows

Downloads and runs `setup.ps1` — handles clone, install, build, test, and prints the config:

```powershell
powershell -ExecutionPolicy Bypass -Command "iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/LiZhiStudio/opencode-angelscript-lsp/refs/heads/main/setup.ps1'))"
```

### Linux / macOS

Downloads and runs `setup.sh` — handles clone, install, build, test, and prints the config:

```bash
bash <(curl -s https://raw.githubusercontent.com/LiZhiStudio/opencode-angelscript-lsp/refs/heads/main/setup.sh)
```

---

## Step 2: Configure OpenCode

After the setup script finishes, it prints the exact JSON to add to `opencode.jsonc`.

Open your OpenCode config file:
- **Linux / macOS**: `~/.config/opencode/opencode.jsonc`
- **Windows**: `$env:USERPROFILE\.config\opencode\opencode.jsonc`

And add:

```jsonc
{
  // ... existing config ...

  "lsp": {
    "angelscript": {
      "command": ["node", "<PATH_FROM_SETUP_SCRIPT>"],
      "extensions": [".as"]
    }
  }
}
```

**Example paths by platform:**

| Platform | `command` value |
|----------|----------------|
| Linux | `["node", "/home/alice/opencode-angelscript-lsp/start.js"]` |
| macOS | `["node", "/Users/alice/opencode-angelscript-lsp/start.js"]` |
| Windows | `["node", "C:\\Users\\alice\\opencode-angelscript-lsp\\start.js"]` |

> **Windows note:** Use `\\` as path separator in JSON.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|------|
| `Error: Cannot find module './build/server.js'` | Build skipped | Run `npm install && npm test` in the repo |
| LSP not starting in OpenCode | Wrong path in config | Use the absolute path from the setup script |
| Test prints `[WARN] Unreal Editor may not be running` | UE not connected (TCP 27099) | Normal; LSP works without it |
| Test hangs permanently | Node.js < 14 | `node --version`; upgrade |
| Agent keeps retrying | Misreading output as error | Check exit code, not output text |
