// Star rating: run the actual API Task request against an isolated stand-in server.
import { createServer } from 'node:http';
import { spawn, execFileSync } from 'node:child_process';
import { readFile, writeFile, mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import assert from 'node:assert/strict';
const requests = [];
const server = createServer(async (req, res) => {
  let text = ''; for await (const chunk of req) text += chunk;
  requests.push([req.method, req.url, JSON.parse(text), req.headers.authorization]);
  res.writeHead(requests.length === 3 ? 403 : 204);
  res.end(requests.length === 3 ? '{"error":"denied"}' : '');
});
const dir = await mkdtemp(path.join(tmpdir(), 'arc-rating-api-'));
try {
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const source = (await readFile('tests/rating-api.brs','utf8')).replace('__PORT__', String(server.address().port));
  const main = path.join(dir, 'rating-api.brs'); await writeFile(main, source);
  const args = ['node_modules/brs-node/bin/brs.cli.js', '--no-sg', 'out/staging/source/shared/http.brs', 'out/staging/source/shared/ratings.brs', 'out/staging/components/tasks/ApiTask.brs', main];
  const child = spawn(process.execPath, args, {stdio:['ignore','pipe','pipe']});
  let output = ''; child.stdout.on('data', b => output += b); child.stderr.on('data', b => output += b);
  const timer = setTimeout(() => child.kill(), 30000);
  await new Promise(resolve => child.on('close', resolve)); clearTimeout(timer);
  assert.ok(output.includes('RATING API PASSED'), output);
  assert.deepEqual(requests, [9,0,1].map(rating => ['PUT','/api/v1/items/a%2Fb/rating',{rating},'Bearer scratch']));
  console.log('Star rating stand-in server checks passed');
} finally { server.close(); await rm(dir,{recursive:true,force:true}); }

// Exercise the production title-menu callbacks without pretending to render SceneGraph.
const menu = execFileSync(process.execPath, [
  'node_modules/brs-node/bin/brs.cli.js', '--no-sg',
  'out/staging/source/shared/http.brs', 'out/staging/source/shared/ratings.brs',
  'out/staging/components/screens/DetailsScreen.brs', 'tests/rating-menu.brs'
], { encoding: 'utf8', timeout: 30000 });
assert.ok(menu.includes('RATING MENU PASSED'), menu);
console.log('Star rating title-menu handler checks passed');
