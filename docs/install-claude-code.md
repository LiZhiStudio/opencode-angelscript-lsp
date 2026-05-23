# Angelscript LSP — Claude Code Installation Guide

## Prerequisites

- **Node.js >= 18** — verify with `node --version`

## Step 1: Add the marketplace

```bash
claude plugin marketplace add https://github.com/LiZhiStudio/angelscript-lsp.git
```

## Step 2: Install the plugin

```bash
claude plugin install angelscript-lsp
```

## Step 3: Verify

```bash
claude plugin list
```

Should show `angelscript-lsp` with status `enabled`.

**Important:** After installation, restart Claude Code to activate the LSP server. LSP registrations are loaded at session startup and won't take effect in the current session.

---

## What NOT to do

- Do NOT create `.lsp.json` — Claude Code ignores it
- Do NOT create `.claude/lsp.json` — Claude Code ignores it
- Do NOT manually edit `settings.json` to add LSP config — the plugin handles it
- Do NOT write any file to configure LSP — installation is purely CLI-based

The `.claude-plugin/marketplace.json` in this repository already contains the full `lspServers` definition. Running the two commands above registers the marketplace and installs the plugin — nothing else is needed.

## How it works

1. `claude plugin marketplace add` clones this repo and registers it as a marketplace
2. `claude plugin install` reads `.claude-plugin/marketplace.json`, finds the `lspServers.angelscript` definition, and enables it for all `.as` files
3. Claude Code auto-launches the LSP server (`node ./build/server.js --stdio`) when any `.as` file is opened

## Troubleshooting

### LSP not working after install

Restart Claude Code. LSP server registrations are loaded at session startup.

### "No LSP server available for file type: .as"

The plugin may not be installed or enabled. Run `claude plugin list` and confirm `angelscript-lsp` shows `enabled`. If installed, restart Claude Code.

### Server fails to start

Verify Node.js is installed and the server binary works:

```bash
node ./build/server.js --stdio
```

Then paste an LSP initialize request to verify the handshake:

```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"capabilities":{},"rootUri":"file:///path/to/workspace"}}
```

Note: the message must be prefixed with an LSP `Content-Length` header. Use a test script (see `test-lsp.mjs` in this repo) instead of piping manually.

### Node.js not found

Install Node.js >= 18 from [nodejs.org](https://nodejs.org) or via a version manager (`nvm`, `fnm`, etc.).
