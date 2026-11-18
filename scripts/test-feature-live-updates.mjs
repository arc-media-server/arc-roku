// Live updates: repeat the actual native simulator SSE transport against an isolated stand-in.
import { createServer } from 'node:http';
import { spawn } from 'node:child_process';
import assert from 'node:assert/strict';
const seen = [];
const server = createServer((req, res) => {
  assert.equal(req.url, '/api/v1/events');
  assert.equal(req.headers.authorization, 'Bearer fixture-token');
  seen.push(req.headers['last-event-id'] || '');
  res.writeHead(200, { 'Content-Type': 'text/event-stream' });
  res.write(': heartbeat\r\nid: fixture-1\r\nevent: resync\r\ndata: {}\r\n\r\n');
  const timer = setTimeout(() => {
    res.write('id: fixture-2\nevent: invalidate\ndata: {"topic":');
    setTimeout(() => res.write('"profile"}\n\n'), 30);
  }, 100);
  req.on('close', () => clearTimeout(timer));
});
await new Promise((resolve) => server.listen(18419, '127.0.0.1', resolve));
try {
  for (let run = 0; run < 2; run++) {
    const output = await new Promise((resolve, reject) => {
      const proc = spawn('node_modules/.bin/brs-cli', ['--no-sg', 'out/staging/source/shared/http.brs', 'out/staging/source/shared/liveupdates.brs', 'tests/live-stream.brs']);
      let result = ''; proc.stdout.on('data', (s) => { result += s; }); proc.stderr.on('data', (s) => { result += s; });
      const timer = setTimeout(() => { proc.kill(); reject(new Error(`stream timeout: ${result}`)); }, 20000);
      proc.on('exit', () => { clearTimeout(timer); resolve(result); }); proc.on('error', reject);
    });
    assert.match(output, /STREAM PASSED/, output); console.log(`native SSE stand-in run ${run + 1}: passed`);
  }
  assert.deepEqual(seen, ['', 'fixture-2', '', 'fixture-2']);
  console.log('Bearer headers, live delivery before EOF, fragmented frames, cursor reconnect and cancellation passed twice');
} finally { server.closeAllConnections(); await new Promise((resolve) => server.close(resolve)); }
