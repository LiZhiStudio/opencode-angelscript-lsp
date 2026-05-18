#!/usr/bin/env bash
set -euo pipefail

# One-command setup: clone + install + configure Angelscript LSP for OpenCode on Linux/macOS.

REPO_URL="https://github.com/LiZhiStudio/opencode-angelscript-lsp"
REPO_DIR="$HOME/opencode-angelscript-lsp"
START_JS="$REPO_DIR/start.js"

echo "=== Angelscript LSP Setup ==="
echo ""

# --- Step 1: Clone ---
if [ -d "$REPO_DIR" ]; then
    echo "[SKIP] Repo already exists at $REPO_DIR"
else
    echo "[CLONE] Cloning to $REPO_DIR ..."
    git clone "$REPO_URL" "$REPO_DIR"
    echo "[OK] Clone complete"
fi

cd "$REPO_DIR"

# Verify critical files exist
if [ ! -f "$START_JS" ]; then
    echo "[ERROR] start.js not found after clone — repo may be incomplete"
    exit 1
fi

# --- Step 2: Install + Build ---
echo "[INSTALL] Running npm install ..."
npm install --no-audit --no-fund
echo "[OK] npm install + build complete"

# --- Step 3: Test ---
echo ""
echo "=== Verification ==="
npm test
echo "[OK] LSP is working correctly"

# --- Step 4: Print config ---
echo ""
echo "=== Next step: configure opencode.jsonc ==="
echo "Add this to your opencode.jsonc:"
echo ""
echo '  "lsp": {'
echo '    "angelscript": {'
echo "      \"command\": [\"node\", \"$START_JS\"],"
echo '      "extensions": [".as"]'
echo '    }'
echo '  }'
echo ""
echo "Config file location: $HOME/.config/opencode/opencode.jsonc"
