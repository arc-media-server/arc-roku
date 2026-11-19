// Actual API task and rendering callbacks with field stand-ins; real screen checked separately.
import {createServer} from 'node:http';
import {spawn,execFileSync} from 'node:child_process';
import {readFile,writeFile,mkdtemp,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import path from 'node:path';
import assert from 'node:assert/strict';
const dir=await mkdtemp(path.join(tmpdir(),'arc-spoilers-')),requests=[];
const server=createServer(async(req,res)=>{let body='';for await(const c of req)body+=c;requests.push([req.method,req.url,req.headers.authorization,body?JSON.parse(body):null]);res.writeHead(requests.length===3?503:200,{'Content-Type':'application/json'});res.end(JSON.stringify({hide_spoilers:requests.length===2}));});
try{
 await new Promise(r=>server.listen(0,'127.0.0.1',r));
 const api=path.join(dir,'api.brs');await writeFile(api,(await readFile('tests/spoiler-api.brs','utf8')).replace('__PORT__',String(server.address().port)));
 const output=await new Promise((resolve,reject)=>{const p=spawn(process.execPath,['node_modules/brs-node/bin/brs.cli.js','--no-sg','out/staging/source/shared/http.brs','out/staging/components/tasks/ApiTask.brs',api]);let s='';p.stdout.on('data',d=>s+=d);p.stderr.on('data',d=>s+=d);const timer=setTimeout(()=>{p.kill();reject(Error('API timeout'));},15000);p.on('exit',()=>{clearTimeout(timer);resolve(s);});p.on('error',reject);});
 assert.match(output,/SPOILER API PASSED/);
 assert.deepEqual(requests,[['GET','/api/v1/me/prefs','Bearer fixture',null],['PATCH','/api/v1/me/prefs','Bearer fixture',{hide_spoilers:true}],['PATCH','/api/v1/me/prefs','Bearer fixture',{hide_spoilers:false}]]);
 const shared=['http','spoilers','cards','format'].map(n=>'out/staging/source/shared/'+n+'.brs');
 for(const [name,component,aliases,marker] of [
  ['settings','screens/SettingsScreen',['draw'],'SPOILER SETTINGS PASSED'],
  ['profile','MainScene',[],'SPOILER PROFILE PASSED'],
  ['card','widgets/CardItem',[],'SPOILER CARD PASSED'],
  ['player','screens/PlayerScreen',[],'SPOILER UP NEXT PASSED']]){
  let source=await readFile('out/staging/components/'+component+'.brs','utf8');
  for(const alias of aliases)source=source.replace(new RegExp('sub '+alias+'\\('),'sub rendering_'+alias+'(');
  const file=path.join(dir,name+'.brs');await writeFile(file,source);
  const out=execFileSync(process.execPath,['node_modules/brs-node/bin/brs.cli.js','--no-sg',...shared.filter(p=>name!=='player'||!p.endsWith('/cards.brs')),file,'tests/spoiler-'+name+'.brs'],{encoding:'utf8',timeout:15000});assert.ok(out.includes(marker),out);
 }
 console.log('Spoilers: API/Bearer, Settings save/refusal, stale profile/load, card reveal and Up Next artwork callbacks passed');
}finally{server.closeAllConnections();await new Promise(r=>server.close(r));await rm(dir,{recursive:true,force:true});}
