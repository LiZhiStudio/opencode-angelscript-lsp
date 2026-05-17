import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import path from 'path';

// Force UTF-8 output on Windows to prevent garbled characters
if (process.platform === 'win32') {
  const { execSync } = await import('child_process');
  try { execSync('chcp 65001 >nul 2>&1', { shell: 'cmd.exe' }); } catch {}
}

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const serverPath = path.join(__dirname, 'build', 'server.js');
const TEST_TIMEOUT = 5000; // 5s max

// --- helpers ---
let passed = 0;
let failed = 0;
function assert(cond, label) {
  if (cond) { console.log(`  [PASS] ${label}`); passed++; }
  else      { console.log(`  [FAIL] ${label}`); failed++; }
}

// --- server start ---
const child = spawn('node', [serverPath], {
  stdio: ['pipe', 'pipe', 'pipe'],
});

let lspReceivedResponse = false;
let fullStdout = '';

child.stdout.on('data', (data) => {
  const text = data.toString();
  fullStdout += text;
  // LSP responses are JSON-RPC — look for "id" field in response
  if (text.includes('"jsonrpc"') || text.includes('"result"') || text.includes('"capabilities"')) {
    lspReceivedResponse = true;
  }
  // strip Content-Length headers for cleaner display
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

// --- test sequence ---
function sendLspMessage(msg) {
  const body = JSON.stringify(msg);
  const header = `Content-Length: ${Buffer.byteLength(body, 'utf-8')}\r\n\r\n`;
  child.stdin.write(header + body);
}

// Step 1: Send initialize
console.log('\n--- Testing LSP connection ---\n');
sendLspMessage({
  jsonrpc: '2.0',
  id: 1,
  method: 'initialize',
  params: { processId: process.pid, rootUri: null, capabilities: {} },
});

// Step 2: After 1s, send shutdown
setTimeout(() => {
  sendLspMessage({
    jsonrpc: '2.0',
    id: 2,
    method: 'shutdown',
    params: null,
  });
}, 1000);

// Step 3: After 2s, check results and exit
setTimeout(() => {
  console.log('');
  assert(lspReceivedResponse, 'LSP server responded to initialize request');
  assert(exitCode === null || exitCode === 0, `LSP server exited cleanly (code=${exitCode})`);
  assert(fullStdout.length > 0, 'LSP server produced output');

  const total = passed + failed;
  console.log(`\nResults: ${passed}/${total} passed\n`);

  child.stdin.end();
  process.exit(failed > 0 ? 1 : 0);
}, 2000);

// Safety timeout
setTimeout(() => {
  if (!lspReceivedResponse) {
    console.log('\n  [TIMEOUT] LSP server did not respond within 5s');
  }
  child.kill();
  process.exit(1);
}, TEST_TIMEOUT);
