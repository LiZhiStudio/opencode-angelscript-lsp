# Angelscript LSP — Claude Code Installation Guide

## Read before executing

This document MUST be executed by an agent. Claude Code uses a **marketplace plugin system** for LSP servers — do NOT create `.lsp.json`, `.claude/lsp.json`, or any other manual LSP config files.

The correct installation is **two commands**:

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
