#!/usr/bin/env node

// Mock OpenCode for testing purposes
const http = require('http');
const url = require('url');

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    
    if (parsedUrl.pathname === '/status') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok', service: 'opencode-mock' }));
    } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Not found');
    }
});

const port = 3284;
server.listen(port, '127.0.0.1', () => {
    console.log(`OpenCode mock server running on http://127.0.0.1:${port}`);
});

// Handle graceful shutdown
process.on('SIGINT', () => {
    console.log('Shutting down OpenCode mock server...');
    server.close(() => {
        process.exit(0);
    });
});

process.on('SIGTERM', () => {
    console.log('Shutting down OpenCode mock server...');
    server.close(() => {
        process.exit(0);
    });
});