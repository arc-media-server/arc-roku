import { execFileSync } from 'node:child_process';
import assert from 'node:assert/strict';
const out = execFileSync(process.execPath, [
  'node_modules/brs-node/bin/brs.cli.js', '--no-sg',
  'out/staging/source/shared/http.brs', 'out/staging/source/shared/thememusic.brs',
  'out/staging/components/screens/ThemeMusic.brs', 'tests/theme-music-node.brs'
], { encoding: 'utf8', timeout: 30000 });
assert.ok(out.includes('THEME CALLBACKS PASSED'), out);
console.log('Theme callback lifecycle checks passed');
