<#
.SYNOPSIS
    One-command setup: clone + install + configure Angelscript LSP for OpenCode on Windows.
.DESCRIPTION
    Run this script from any directory. It will:
    1. Clone the repo to $env:USERPROFILE\opencode-angelscript-lsp (if not already there)
    2. Run npm install (which auto-builds via postinstall)
    3. Print the absolute path for opencode.jsonc configuration
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File setup.ps1
#>

$ErrorActionPreference = "Stop"

# --- Force English + UTF-8 ---
$env:LANG = "en_US.UTF-8"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()
chcp 65001 > $null

$RepoDir = "$env:USERPROFILE\opencode-angelscript-lsp"
$StartJs = "$RepoDir\start.js"

Write-Host "=== Angelscript LSP Setup ==="
Write-Host ""

# --- Step 1: Clone ---
if (Test-Path $RepoDir) {
    Write-Host "[SKIP] Repo already exists at $RepoDir"
} else {
    Write-Host "[CLONE] Cloning to $RepoDir ..."
    git clone https://github.com/LiZhiStudio/opencode-angelscript-lsp $RepoDir
    if (-not $?) {
        Write-Host "[ERROR] git clone failed (exit code: $LASTEXITCODE)"
        exit 1
    }
    Write-Host "[OK] Clone complete"
}

Set-Location -LiteralPath $RepoDir

# --- Step 2: Install + Build ---
Write-Host "[INSTALL] Running npm install ..."
npm install --no-audit --no-fund
if (-not $?) {
    Write-Host "[ERROR] npm install failed (exit code: $LASTEXITCODE)"
    exit 1
}
Write-Host "[OK] npm install + build complete"

# --- Step 3: Test ---
Write-Host ""
Write-Host "=== Verification ==="
node test-lsp.mjs
if (-not $?) {
    Write-Host "[WARN] Test failed - check opencode.jsonc configuration"
} else {
    Write-Host "[OK] LSP is working correctly"
}

# --- Step 4: Print config ---
Write-Host ""
Write-Host "=== Next step: configure opencode.jsonc ==="
Write-Host "Add this to your opencode.jsonc:"
Write-Host ""
Write-Host '  "lsp": {'
Write-Host '    "angelscript": {'
Write-Host "      ""command"": [""node"", ""$StartJs""],"
Write-Host '      "extensions": [".as"]'
Write-Host '    }'
Write-Host '  }'
Write-Host ""
Write-Host "Config file location: $env:USERPROFILE\.config\opencode\opencode.jsonc"
