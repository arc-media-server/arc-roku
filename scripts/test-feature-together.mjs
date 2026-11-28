import { execFileSync } from 'node:child_process';
import assert from 'node:assert/strict';

const player = execFileSync(process.execPath, [
  'node_modules/brs-node/bin/brs.cli.js', '--no-sg',
  'out/staging/source/shared/together.brs',
  'out/staging/components/screens/RoomPlayback.brs',
  'out/staging/components/screens/PlayerScreen.brs',
  'tests/together-player.brs',
], { encoding: 'utf8', timeout: 15000 });

assert.match(player, /TOGETHER PLAYER PASSED/, player);
console.log('Watch Together room clock, converted seek, readiness, and access checks passed');
