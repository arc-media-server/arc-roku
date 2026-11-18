// Actual API Task and title callbacks; no production credentials or SG rendering claims.
import {createServer} from 'node:http';
import {spawn,execFileSync} from 'node:child_process';
import {readFile,writeFile,mkdtemp,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import path from 'node:path';
import assert from 'node:assert/strict';
const requests=[];
const server=createServer((req,res)=>{requests.push([req.url,req.headers.authorization]);res.setHeader('Content-Type','application/json');res.end('{"seasons":[{"season_number":1,"episodes":[]}]}');});
const dir=await mkdtemp(path.join(tmpdir(),'arc-missing-'));
const shared=['http','cards','format','seasons','seasonactions','cardmenu','ratings'].map(n=>'out/staging/source/shared/'+n+'.brs');
try{
 await new Promise(r=>server.listen(0,'127.0.0.1',r));
 const api=path.join(dir,'api.brs');await writeFile(api,(await readFile('tests/missing-api.brs','utf8')).replace('__PORT__',String(server.address().port)));
 const result=await new Promise((resolve,reject)=>{const child=spawn(process.execPath,['node_modules/brs-node/bin/brs.cli.js','--no-sg',...shared,'out/staging/components/tasks/ApiTask.brs',api]);let out='';child.stdout.on('data',s=>out+=s);child.stderr.on('data',s=>out+=s);const timeout=setTimeout(()=>{child.kill();reject(Error('API timeout'));},15000);child.on('exit',()=>{clearTimeout(timeout);resolve(out);});child.on('error',reject);});
 assert.match(result,/MISSING API PASSED/);
 assert.deepEqual(requests,[['/api/v1/series/a%2Fb/seasons','Bearer fixture-only'],['/api/v1/series/a%2Fb/seasons?missing=1','Bearer fixture-only']]);
 let source=await readFile('out/staging/components/screens/DetailsScreen.brs','utf8');
 for(const name of ['buildRows','showButtons','focusRows','focusButtons'])source=source.replace(new RegExp('sub '+name+'\\('),'sub rendering_'+name+'(');
 const screen=path.join(dir,'screen.brs');await writeFile(screen,source);
 const out=execFileSync(process.execPath,['node_modules/brs-node/bin/brs.cli.js','--no-sg',...shared,screen,'tests/missing-menu.brs'],{encoding:'utf8',timeout:15000});
 assert.match(out,/MISSING MENU PASSED/);
 console.log('Missing episodes: native API/Bearer and real menu, failure/stale-response, unavailable playback callbacks passed');
}finally{server.closeAllConnections();await new Promise(r=>server.close(r));await rm(dir,{recursive:true,force:true});}
