// Runs tests/unit.brs against the app's shared code (transpiled by bsc) in brs-cli, the
// BrightScript Simulation Engine. It checks logic only; screens and playback need a real Roku.
import { execFileSync } from 'node:child_process';

execFileSync('npx', ['bsc', '--create-package', 'false'], { stdio: 'inherit' });
const shared = ['liveupdates', 'http', 'format', 'caps', 'home', 'bif', 'tracks', 'cards', 'browse', 'places', 'recommended', 'quality', 'titlepage', 'playerosd', 'person', 'seasons', 'cardmenu', 'seasonactions'].map((n) => `out/staging/source/shared/${n}.brs`);
let out = '';
try {
  out = execFileSync('npx', ['brs-cli', '--no-sg', ...shared, 'tests/live-hints.brs', 'tests/unit.brs'], { encoding: 'utf8' });
} catch (e) {
  out = (e.stdout || '') + (e.stderr || '');
}
process.stdout.write(out);
if (!out.includes('ALL PASSED')) {
  console.error('Unit tests failed.');
  process.exit(1);
}

// Live updates: exercise the real native stream more than once against a stand-in.
await import('./test-live-updates.mjs');
