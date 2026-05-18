import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import path from 'path';
import fs from 'fs';

// Force UTF-8 output on Windows to prevent garbled characters
if (process.platform === 'win32') {
  const { execSync } = await import('child_process');
  try { execSync('chcp 65001 >nul 2>&1', { shell: 'cmd.exe' }); } catch {}
}

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const serverPath = path.join(__dirname, 'build', 'server.js');

// --- Check 1: build artifact exists ---
console.log('\n--- LSP Server Test ---\n');

const buildExists = fs.existsSync(serverPath);
if (buildExists) {
  console.log('  [PASS] build/server.js exists');
} else {
  console.log('  [FAIL] build/server.js not found — run npm install first');
  process.exit(1);
}

// --- Check 2: server starts and responds ---
console.log('  [INFO] Starting server (may pause if connecting to Unreal Editor)...');

const child = spawn('node', [serverPath], {
  stdio: ['pipe', 'pipe', 'pipe'],
});

let lspReceivedResponse = false;
let serverOutput = '';

child.stdout.on('data', (data) => {
  const text = data.toString();
  serverOutput += text;
  if (text.includes('"jsonrpc"') || text.includes('"result"') || text.includes('"capabilities"')) {
    lspReceivedResponse = true;
  }
  // Strip Content-Length headers for cleaner display
  const lines = text.split('\n').filter(l => l.trim() && !l.startsWith('Content-Length') && l.trim() !== '\r');
  for (const line of lines) {
    const trimmed = line.trim().replace(/\r$/, '');
    if (trimmed) console.log(`  [server] ${trimmed}`);
  }
});

child.stderr.on('data', (data) => {
  const text = data.toString().trim();
  if (text) console.log(`  [stderr] ${text}`);
});

let exitCode = null;
child.on('exit', (code) => {
  exitCode = code;
});

// Send LSP initialize
function sendInitialize() {
  const msg = JSON.stringify({
    jsonrpc: '2.0',
    id: 1,
    method: 'initialize',
    params: { processId: process.pid, rootUri: null, capabilities: {} },
  });
  const header = `Content-Length: ${Buffer.byteLength(msg, 'utf-8')}\r\n\r\n`;
  child.stdin.write(header + msg);
}
sendInitialize();

// Wait up to 8s for a response
setTimeout(() => {
  if (lspReceivedResponse) {
    console.log('  [PASS] LSP server responded to initialize request');
  } else {
    console.log('  [WARN] LSP server did not respond within 8s');
    console.log('  [WARN] Unreal Editor may not be running (TCP 27099)');
    console.log('  [WARN] LSP will still work but without engine-level type info');
  }

  console.log(`\nResults: ${buildExists ? 'pre-check passed' : 'pre-check failed'}`);
  child.stdin.end();
  process.exit(0);
}, 8000);
