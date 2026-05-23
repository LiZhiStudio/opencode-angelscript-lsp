#!/usr/bin/env node
// AngelScript LSP Server for OpenCode
// Auto-generated wrapper

const path = require('path');
const serverPath = path.join(__dirname, 'build', 'server.js');

// Pass --stdio so vscode-languageserver uses stdio transport
process.argv.push('--stdio');

// Start the server
require(serverPath);
