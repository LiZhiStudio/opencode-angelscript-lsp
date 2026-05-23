<#
.SYNOPSIS
    Rebuild Angelscript LSP Server from source.
.DESCRIPTION
    Three modes:
    1. Build from local src/ directory (default)
    2. Fetch latest source from Hazelight GitHub repo and build (-Remote)
    3. Build from a user-specified source path (-SourcePath)
.PARAMETER Remote
    Pull source from https://github.com/Hazelight/vscode-unreal-angelscript then build
.PARAMETER SourcePath
    Path to local vscode-unreal-angelscript (supports both repo root and language-server/ subdir)
.EXAMPLE
    .\update.ps1                          # build from local src/
    .\update.ps1 -Remote                  # fetch and build from GitHub
    .\update.ps1 -SourcePath "D:\path\to\vscode-unreal-angelscript"
#>

# Force English + UTF-8 to prevent garbled output
$env:LANG = "en_US.UTF-8"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

param(
    [switch]$Remote,
    [string]$SourcePath = ""
)

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path $RepoRoot "src"
$PegjsDir = Join-Path $RepoRoot "pegjs"
$GrammarDir = Join-Path $RepoRoot "grammar"
$BuildDir = Join-Path $RepoRoot "temp_build"

# ---------- Source acquisition ----------
if ($Remote) {
    $RemoteUrl = "https://github.com/Hazelight/vscode-unreal-angelscript"
    $TempClone = Join-Path $RepoRoot "temp_source"

    Write-Host ">>> Cloning latest source from $RemoteUrl ..." -ForegroundColor Cyan
    if (Test-Path $TempClone) {
        Remove-Item -Path $TempClone -Recurse -Force
    }
    git clone --depth 1 $RemoteUrl $TempClone
    if (-not $? -or -not (Test-Path (Join-Path $TempClone "language-server\src\server.ts"))) {
        Write-Error "Clone failed or source path not found"
        exit 1
    }
    $SourcePath = $TempClone
}
elseif ($SourcePath -eq "") {
    # Use local src/ directory
    $SourcePath = $RepoRoot
}
else {
    # Validate user-specified path
    if (-not (Test-Path (Join-Path $SourcePath "language-server\src\server.ts")) -and
        -not (Test-Path (Join-Path $SourcePath "src\server.ts"))) {
        Write-Error "Source path must contain language-server/src/server.ts or src/server.ts"
        exit 1
    }
}

# ---------- Locate language-server root ----------
if (Test-Path (Join-Path $SourcePath "language-server\src\server.ts")) {
    $LangServerRoot = Join-Path $SourcePath "language-server"
}
elseif (Test-Path (Join-Path $SourcePath "src\server.ts")) {
    $LangServerRoot = $SourcePath
}
else {
    Write-Error "Cannot locate language-server source"
    exit 1
}

Write-Host ">>> Using source: $LangServerRoot" -ForegroundColor Cyan

# ---------- Patch source for stdio transport ----------
Write-Host ">>> Patching server.ts for stdio transport ..." -ForegroundColor Cyan
$ServerTs = Join-Path $LangServerRoot "src\server.ts"
if (Test-Path $ServerTs) {
    $content = Get-Content $ServerTs -Raw
    # Replace hardcoded IPC transport with auto-detect (supports --stdio, --node-ipc, --socket)
    $patched = $content -replace 'createConnection\(new IPCMessageReader\(process\),\s*new IPCMessageWriter\(process\)\)', 'createConnection()'
    if ($content -ne $patched) {
        Set-Content $ServerTs -Value $patched -NoNewline
        Write-Host "  -> server.ts patched for stdio transport" -ForegroundColor Green
    } else {
        Write-Host "  -> server.ts already patched or pattern not found" -ForegroundColor Yellow
    }
} else {
    Write-Warning "src/server.ts not found, skipping patch"
}

# ---------- Install dependencies ----------
Write-Host ">>> Installing npm dependencies ..." -ForegroundColor Cyan
Push-Location $LangServerRoot
npm install
if (-not $?) {
    Pop-Location
    Write-Error "npm install failed"
    exit 1
}
Pop-Location

# ---------- Build ----------
Write-Host ">>> Building with esbuild ..." -ForegroundColor Cyan
Push-Location $LangServerRoot
node esbuild.js
if (-not $?) {
    Pop-Location
    Write-Error "esbuild build failed"
    exit 1
}
Pop-Location

# ---------- Copy artifacts ----------
Write-Host ">>> Copying build artifacts ..." -ForegroundColor Cyan
$BuildOutDir = Join-Path $RepoRoot "build"
if (-not (Test-Path $BuildOutDir)) {
    New-Item -ItemType Directory -Path $BuildOutDir -Force | Out-Null
}

$BuiltJs = Join-Path $LangServerRoot "build\server.js"
$BuiltMap = Join-Path $LangServerRoot "build\server.js.map"

if (Test-Path $BuiltJs) {
    Copy-Item -Path $BuiltJs -Destination (Join-Path $BuildOutDir "server.js") -Force
    Write-Host "  -> build/server.js" -ForegroundColor Green
}
else {
    Write-Warning "build/server.js not found, looking for fallback..."
    $FallbackJs = Join-Path $LangServerRoot "server.js"
    if (Test-Path $FallbackJs) {
        Copy-Item -Path $FallbackJs -Destination (Join-Path $BuildOutDir "server.js") -Force
        Write-Host "  -> build/server.js (fallback)" -ForegroundColor Green
    }
}

if (Test-Path $BuiltMap) {
    Copy-Item -Path $BuiltMap -Destination (Join-Path $BuildOutDir "server.js.map") -Force
    Write-Host "  -> build/server.js.map" -ForegroundColor Green
}

# ---------- Ensure start.js exists ----------
$StartJs = Join-Path $RepoRoot "start.js"
if (-not (Test-Path $StartJs)) {
    @"
#!/usr/bin/env node
const path = require('path');
const serverPath = path.join(__dirname, 'build', 'server.js');
process.argv.push('--stdio');
require(serverPath);
"@ | Set-Content -Path $StartJs -Encoding utf8
    Write-Host "  -> start.js (created)" -ForegroundColor Green
}

# ---------- Sync source directory (Remote mode only) ----------
if ($Remote -and $TempClone) {
    Write-Host ">>> Syncing source files ..." -ForegroundColor Cyan

    # Sync src/
    $RemoteSrc = Join-Path $LangServerRoot "src"
    if (Test-Path $RemoteSrc) {
        if (Test-Path $SourceDir) {
            Remove-Item -Path "$SourceDir\*" -Recurse -Force
        }
        Copy-Item -Path "$RemoteSrc\*" -Destination $SourceDir -Recurse -Force
    }

    # Sync pegjs/
    $RemotePegjs = Join-Path $LangServerRoot "pegjs"
    if (Test-Path $RemotePegjs) {
        if (Test-Path $PegjsDir) { Remove-Item -Path "$PegjsDir\*" -Recurse -Force }
        Copy-Item -Path "$RemotePegjs\*" -Destination $PegjsDir -Recurse -Force
    }

    # Sync grammar/
    $RemoteGrammar = Join-Path $LangServerRoot "grammar"
    if (Test-Path $RemoteGrammar) {
        if (Test-Path $GrammarDir) { Remove-Item -Path "$GrammarDir\*" -Recurse -Force }
        Copy-Item -Path "$RemoteGrammar\*" -Destination $GrammarDir -Recurse -Force
    }

    # Sync build configs
    Copy-Item -Path (Join-Path $LangServerRoot "esbuild.js") -Destination (Join-Path $RepoRoot "esbuild.js") -Force
    Copy-Item -Path (Join-Path $LangServerRoot "package.json") -Destination (Join-Path $RepoRoot "package.json") -Force
    Copy-Item -Path (Join-Path $LangServerRoot "package-lock.json") -Destination (Join-Path $RepoRoot "package-lock.json") -Force
    Copy-Item -Path (Join-Path $LangServerRoot "tsconfig.json") -Destination (Join-Path $RepoRoot "tsconfig.json") -Force

    # Clean up temp
    Remove-Item -Path $TempClone -Recurse -Force
    Write-Host "  -> source updated from remote" -ForegroundColor Green
}

# ---------- Clean temp build dir ----------
if (Test-Path $BuildDir) {
    Remove-Item -Path $BuildDir -Recurse -Force
}

Write-Host ""
Write-Host "======= Build complete =======" -ForegroundColor Cyan
Write-Host "  build/server.js      - bundled LSP server" -ForegroundColor Green
Write-Host "  build/server.js.map  - source map" -ForegroundColor Green
Write-Host "  start.js       - entry point" -ForegroundColor Green
Write-Host ""
Write-Host "Run test : node test-lsp.mjs" -ForegroundColor Yellow
Write-Host "OpenCode config: see README.md" -ForegroundColor Yellow
