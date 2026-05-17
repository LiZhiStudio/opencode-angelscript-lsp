# Angelscript LSP — Agent Installation Guide

## ⚠️ Read before executing

This document MUST be executed by an agent. Before running any command, detect the platform:

- **Linux**: `uname -s` → `Linux`
- **macOS**: `uname -s` → `Darwin`
- **Windows**: `$env:OS` → `Windows_NT`

After platform detection, use ONLY the commands from the matching section below.

---

## Step 0: Platform detection (run this first)

```powershell
# Windows PowerShell
$isWindows = $env:OS -eq "Windows_NT"
```

```bash
# Linux / macOS
is_windows=$(uname -s | grep -qi "mingw\|msys\|cygwin" && echo "1" || echo "0")
```

---

## Step 1: Clone the repo

### If Windows (PowerShell):
```powershell
git clone https://github.com/LiZhiStudio/opencode-angelscript-lsp "$env:USERPROFILE\opencode-angelscript-lsp"
Set-Location -LiteralPath "$env:USERPROFILE\opencode-angelscript-lsp"
```

### If Linux / macOS:
```bash
git clone https://github.com/LiZhiStudio/opencode-angelscript-lsp ~/opencode-angelscript-lsp
cd ~/opencode-angelscript-lsp
```

---

## Step 2: Install dependencies

Works the same on all platforms:
```bash
npm install
```

This automatically runs `npm run build` (via postinstall) to compile the TypeScript source.

---

## Step 3: Locate the absolute path to start.js

> ⚠️ Do NOT use `~` in the LSP command — Node.js does NOT expand it when passed as a subprocess argument. Use the absolute path.

### If Windows:
```powershell
Join-Path "$env:USERPROFILE" "opencode-angelscript-lsp\start.js"
```

### If Linux / macOS:
```bash
echo "$HOME/opencode-angelscript-lsp/start.js"
```

Save the output — it's needed in Step 4.

---

## Step 4: Configure OpenCode

Find and edit `opencode.jsonc`:
- **Linux**: `~/.config/opencode/opencode.jsonc`
- **macOS**: `~/.config/opencode/opencode.jsonc` or `~/Library/Application Support/opencode/opencode.jsonc`
- **Windows**: `$env:USERPROFILE\.config\opencode\opencode.jsonc`

Add the LSP configuration:

```jsonc
{
  // ... existing config ...

  "lsp": {
    "angelscript": {
      "command": ["node", "<ABSOLUTE_PATH_TO_START_JS>"],
      "extensions": [".as"]
    }
  }
}
```

Replace `<ABSOLUTE_PATH_TO_START_JS>` with the path from Step 3.

**Platform path examples:**

| Platform | `command` value |
|----------|----------------|
| Linux | `["node", "/home/alice/opencode-angelscript-lsp/start.js"]` |
| macOS | `["node", "/Users/alice/opencode-angelscript-lsp/start.js"]` |
| Windows | `["node", "C:\\Users\\alice\\opencode-angelscript-lsp\\start.js"]` |

> **Windows note:** Use `\\` as path separator — JSON requires escaped backslashes.

---

## Step 5: Verify

From the repo directory:

```bash
node test-lsp.mjs
```

**Expected output:**
```
--- Testing LSP connection ---

  [server] ... (LSP capabilities JSON)

  [PASS] LSP server responded to initialize request
  [PASS] LSP server exited cleanly (code=null)
  [PASS] LSP server produced output

Results: 3/3 passed
```

All 3 tests must pass. Exit code 0 = success, 1 = failure.

> **Encoding note:** If you see garbled text in the output, run `chcp 65001` (Windows) or set `LANG=en_US.UTF-8` (Linux/macOS) before running the test.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `Error: Cannot find module './build/server.js'` | Build skipped | `npm run build` |
| LSP not starting in OpenCode | `~` used in path | Replace with absolute path |
| Test hangs | Node.js < 14 | `node --version`; upgrade |
| PowerShell `&&` error | Bash syntax on Windows | Use `;` or separate lines |
