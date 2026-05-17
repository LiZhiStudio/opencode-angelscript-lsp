import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const serverPath = path.join(__dirname, 'build', 'server.js');

const child = spawn('node', [serverPath], {
  stdio: ['pipe', 'pipe', 'pipe'],
});

let output = '';
let outputDone;
const outputPromise = new Promise(resolve => { outputDone = resolve; });

child.stdout.on('data', (data) => {
  output += data.toString();
  console.log('[stdout]', data.toString().trim());
});

child.stderr.on('data', (data) => {
  console.log('[stderr]', data.toString().trim());
});

child.on('exit', (code) => {
  console.log(`[exit] code=${code}`);
  outputDone();
});

// 发送 LSP initialize 请求
const initializeMsg = JSON.stringify({
  jsonrpc: '2.0',
  id: 1,
  method: 'initialize',
  params: {
    processId: process.pid,
    rootUri: null,
    capabilities: {},
  },
});

const header = `Content-Length: ${Buffer.byteLength(initializeMsg, 'utf-8')}\r\n\r\n`;
child.stdin.write(header + initializeMsg);
console.log('[sent] initialize request');

// 1秒后发送 shutdown
setTimeout(() => {
  const shutdownMsg = JSON.stringify({
    jsonrpc: '2.0',
    id: 2,
    method: 'shutdown',
    params: null,
  });
  const header2 = `Content-Length: ${Buffer.byteLength(shutdownMsg, 'utf-8')}\r\n\r\n`;
  child.stdin.write(header2 + shutdownMsg);
  console.log('[sent] shutdown request');
}, 1000);

// 2秒后退出
setTimeout(() => {
  child.stdin.end();
  process.exit(0);
}, 3000);
