// Builds the app and installs it on a Roku in developer mode.
// Reads ROKU_HOST and ROKU_PASSWORD from the environment or from a local .env file
// (never committed). See README.md for turning on developer mode.
import { execSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { rokuDeploy } from 'roku-deploy';

if (existsSync('.env')) {
  for (const line of readFileSync('.env', 'utf8').split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Z_]+)\s*=\s*(.*?)\s*$/);
    if (m && !process.env[m[1]]) process.env[m[1]] = m[2].replace(/^["']|["']$/g, '');
  }
}
const host = process.env.ROKU_HOST;
const password = process.env.ROKU_PASSWORD;
if (!host || !password) {
  console.error('Set ROKU_HOST and ROKU_PASSWORD (in .env or the environment). See README.md.');
  process.exit(1);
}

execSync('npx bsc', { stdio: 'inherit' });
try {
  await rokuDeploy.publish({ host, password, outDir: 'out', outFile: 'arc-roku.zip' });
  console.log(`Installed on ${host}. Logs: telnet ${host} 8085`);
} catch (err) {
  console.error(`Sideload failed: ${err.message}`);
  process.exit(1);
}
