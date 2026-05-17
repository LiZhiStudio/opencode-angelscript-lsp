# Angelscript LSP — Agent Installation Guide

Follow these steps to install and configure Angelscript LSP for OpenCode.

## 1. Clone the repo

Clone to a fixed location so the configuration path is predictable:

```bash
git clone https://github.com/LiZhiStudio/opencode-angelscript-lsp ~/opencode-angelscript-lsp
cd ~/opencode-angelscript-lsp
```

## 2. Install dependencies

```bash
npm install
```

## 3. Configure OpenCode

Add the following LSP configuration to your `opencode.jsonc`:

```json
{
  "lsp": {
    "angelscript": {
      "command": ["node", "~/opencode-angelscript-lsp/start.js"],
      "extensions": [".as"]
    }
  }
}
```

Note: `~/opencode-angelscript-lsp/start.js` works on most platforms. If the agent can't resolve `~`, replace it with the absolute path (e.g. `C:\Users\<username>\opencode-angelscript-lsp\start.js` on Windows, `/home/<username>/opencode-angelscript-lsp/start.js` on Linux).

## 4. Verify

```bash
node test-lsp.mjs
```
