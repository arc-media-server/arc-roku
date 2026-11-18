// The player's native route/parser against an isolated stand-in Arc.
import { createServer } from 'node:http';
import { spawn, execFileSync } from 'node:child_process';
import assert from 'node:assert/strict';
const seen = [];
const server = createServer((req, res) => {
  seen.push({ path: req.url, auth: req.headers.authorization });
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(req.url.includes('/empty/') ? '[]' : JSON.stringify([{ url: '/api/preroll/0', unknown: true }, { url: '/api/preroll/1' }]));
});
await new Promise(resolve => server.listen(18431, '127.0.0.1', resolve));
try {
  const output = await new Promise((resolve, reject) => {
    const proc = spawn('node_modules/.bin/brs-cli', ['--no-sg', 'out/staging/source/shared/http.brs', 'out/staging/source/shared/preroll.brs', 'tests/preroll-server.brs']);
    let result = '';
    proc.stdout.on('data', s => result += s); proc.stderr.on('data', s => result += s);
    const timer = setTimeout(() => { proc.kill(); reject(new Error('stand-in timeout: ' + result)); }, 20000);
    proc.on('exit', () => { clearTimeout(timer); resolve(result); }); proc.on('error', reject);
  });
  assert.match(output, /PREROLL SERVER PASSED/, output);
  assert.deepEqual(seen, [{ path: '/api/v1/items/film%201/preroll', auth: 'Bearer fixture' }, { path: '/api/v1/items/empty/preroll', auth: 'Bearer fixture' }]);
  console.log('Pre-roll native route, bearer header, order, unknown fields and empty list: passed');
} finally { server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); }

const player = execFileSync(process.execPath, [
  'node_modules/brs-node/bin/brs.cli.js', '--no-sg',
  'out/staging/source/shared/preroll.brs', 'out/staging/components/screens/PlayerScreen.brs',
  'tests/preroll-player.brs'
], {encoding:'utf8', timeout:30000});
assert.match(player, /PREROLL PLAYER PASSED/, player);
console.log('Pre-roll production player callback checks passed');
