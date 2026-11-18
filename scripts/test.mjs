// Runs tests/unit.brs against the app's shared code (transpiled by bsc) in brs-cli, the
// BrightScript Simulation Engine. It checks logic only; screens and playback need a real Roku.
import { execFileSync } from 'node:child_process';
// Optional feature tests: discover additive files so independent feature PRs share this runner.
import { readdirSync } from 'node:fs';

execFileSync('npx', ['bsc', '--create-package', 'false'], { stdio: 'inherit' });
const shared = readdirSync('out/staging/source/shared')
  .filter((name) => name.endsWith('.brs') && name !== 'api.brs' && name !== 'settings.brs')
  .sort().map((name) => `out/staging/source/shared/${name}`);
const featureTests = readdirSync('tests').filter((name) => /^feature-.*\.brs$/.test(name))
  .sort().map((name) => `tests/${name}`);
let out = '';
try {
  out = execFileSync('npx', ['brs-cli', '--no-sg', ...shared, ...featureTests, 'tests/unit.brs'], { encoding: 'utf8' });
} catch (e) {
  out = (e.stdout || '') + (e.stderr || '');
}
process.stdout.write(out);
if (!out.includes('ALL PASSED')) {
  console.error('Unit tests failed.');
  process.exit(1);
}
for (const file of readdirSync('scripts').filter((name) => /^test-feature-.*\.mjs$/.test(name)).sort()) {
  await import(`./${file}`);
}
