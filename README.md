# Angelscript LSP

An Angelscript language server built for AI coding agents. Based on the language server from [Hazelight's vscode-unreal-angelscript](https://github.com/Hazelight/vscode-unreal-angelscript) extension, with support for Claude Code, OpenCode, and other agent platforms.

> 中文文档: [README_zh.md](README_zh.md)

## Agent Installation

Send the following instruction to your AI agent — it will install and configure the LSP automatically:

**Claude Code:**

```
Install and configure Angelscript LSP by following the instructions here:
curl -s https://raw.githubusercontent.com/LiZhiStudio/angelscript-lsp/refs/heads/main/docs/install-claude-code.md
```

**OpenCode:**

```
Install and configure Angelscript LSP by following the instructions here:
curl -s https://raw.githubusercontent.com/LiZhiStudio/angelscript-lsp/refs/heads/main/docs/install-opencode.md
```

## Directory Structure

```
angelscript-lsp/
├── .claude-plugin/         # Claude Code plugin marketplace config
│   └── marketplace.json    #   LSP server and file type mapping
├── build/                  # esbuild output
│   ├── server.js           #   LSP server (bundled, ready to run)
│   └── server.js.map       #   Source map (for debugging)
├── docs/                   # Documentation
│   ├── install-claude-code.md  #   Claude Code agent install guide
│   └── install-opencode.md     #   OpenCode agent install guide
├── start.js                # Entry script (require('./build/server.js'))
├── test-lsp.mjs            # LSP connection test script
├── setup.ps1               # Windows one-click setup (clone + install + build + test)
├── setup.sh                # Linux/macOS one-click setup
├── update.ps1              # One-click update (rebuild from source)
├── .gitignore
│
├── src/                    # TypeScript source
├── pegjs/                  # Angelscript grammar parser
├── grammar/                # Grammar node type definitions
├── esbuild.js              # Build configuration
├── package.json            # npm dependencies
├── package-lock.json       # Dependency lock file
└── tsconfig.json           # TypeScript configuration
```

## Quick Start

### 1. Agent Auto-Install (Recommended)

Send one of the Agent Installation instructions above to Claude Code or OpenCode. The agent will handle everything.

### 2. Manual Install & Test

```bash
git clone https://github.com/LiZhiStudio/angelscript-lsp.git
cd angelscript-lsp
npm install
node test-lsp.mjs
```

A successful test will show the LSP capabilities (completion, diagnostics, hover, etc.).

### 3. Manual LSP Configuration

**OpenCode** — add to `opencode.jsonc`:

```json
{
  "lsp": {
    "angelscript": {
      "command": ["node", "path/to/angelscript-lsp/start.js"],
      "extensions": [".as"]
    }
  }
}
```

**Other LSP-compatible editors** — configure the LSP client to connect to `node ./build/server.js --stdio`.

### 4. Unreal Editor Integration

The LSP attempts to connect to Unreal Editor via TCP (default port 27099) on startup. When connected, you get engine-aware type information for completions and diagnostics. **The LSP starts even without the editor running**, but type information will be limited.

Configure `Debug Port` (default 27099) in the Angelscript plugin settings of your UE project, or use the launch flag `-asdebugport=27099`.

## Updating the LSP

### Rebuild from local source

```powershell
.\update.ps1
```

Rebuilds `server.js` from the `src/` directory using esbuild.

### Pull latest from Hazelight upstream then build

```powershell
.\update.ps1 -Remote
```

Clones the latest [Hazelight/vscode-unreal-angelscript](https://github.com/Hazelight/vscode-unreal-angelscript), builds, and syncs into this repo.

### Build from a local extension copy

```powershell
.\update.ps1 -SourcePath "D:\path\to\vscode-unreal-angelscript"
```

## LSP Features

| Feature | Description |
|---|---|
| Diagnostics | `.as` file compilation errors |
| Completion | Type-aware code completion (triggers: `.`, `:`) |
| Hover | Type information and documentation |
| Go to Definition | Jump to symbol definition |
| Find References | Find all reference locations |
| Semantic Highlighting | Type-aware syntax highlighting |
| Rename | Symbol renaming |
| Signature Help | Function parameter hints |
| Type Hierarchy | Class inheritance navigation |

## How It Works

`start.js` → `require('./build/server.js')`. The `server.js` is Hazelight's `language-server/src/server.ts` bundled via esbuild (`bundle: true`, all npm dependencies inlined). At runtime only Node.js built-in modules are needed — no extra installation required.

## License

This repository is built on [Hazelight's vscode-unreal-angelscript](https://github.com/Hazelight/vscode-unreal-angelscript). Please refer to the original project's license terms.
