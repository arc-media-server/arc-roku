// Draws the cards' rounded-corner masks and their focus ring, with Chromium (Playwright's).
// Run after changing the radius or ring width:
//
//   node scripts/make-card-art.mjs
//
//   src/images/mask-poster.png   220x330  a white rounded rectangle on transparent (MaskGroup)
//   src/images/mask-thumb.png    400x225  the same for 16:9 pictures
//   src/images/mask-backdrop.png 400x300  the same for Backdrops (4:3)
//   src/images/focus-ring.9.png  43x43    a nine-patch white ring with rounded corners, drawn
//                                         inside a focused card; the 1 px black guides mark its
//                                         one stretchable row and column
//
// arc-tv's cards have 20 px corners at about 1.4 times this size, hence 16 here.

import { createRequire } from 'node:module';

const RADIUS = 16;
const RING = 6;

const require = createRequire(import.meta.url);
let chromium;
try {
  ({ chromium } = require('playwright'));
} catch {
  console.error('make-card-art: needs Playwright (npm i -D playwright, then npx playwright install chromium)');
  process.exit(1);
}

const page = (w, h, script) =>
  `<!doctype html><html><head><style>html,body{margin:0;padding:0;background:transparent;overflow:hidden}` +
  `canvas{display:block}</style></head><body><canvas id="c" width="${w}" height="${h}"></canvas><script>` +
  `const c=document.getElementById('c').getContext('2d');${script}</script></body></html>`;

const rounded = (x, y, w, h, r) =>
  `c.beginPath();c.moveTo(${x + r},${y});c.arcTo(${x + w},${y},${x + w},${y + h},${r});` +
  `c.arcTo(${x + w},${y + h},${x},${y + h},${r});c.arcTo(${x},${y + h},${x},${y},${r});` +
  `c.arcTo(${x},${y},${x + w},${y},${r});c.closePath();`;

const mask = (w, h) => page(w, h, `c.fillStyle='#fff';${rounded(0, 0, w, h, RADIUS)}c.fill();`);

// The ring: 41 px square inside the 1 px guide border; the middle row and column stretch.
const S = 2 * RADIUS + 9;
const mid = 1 + Math.floor(S / 2);
const ring = page(S + 2, S + 2,
  `c.fillStyle='#fff';${rounded(1, 1, S, S, RADIUS)}` +
  `c.save();c.clip();c.fill();c.globalCompositeOperation='destination-out';` +
  `${rounded(1 + RING, 1 + RING, S - 2 * RING, S - 2 * RING, RADIUS - RING)}c.fill();c.restore();` +
  `c.fillStyle='#000';c.fillRect(${mid},0,1,1);c.fillRect(0,${mid},1,1);`);

const jobs = [
  { out: 'src/images/mask-poster.png', w: 220, h: 330, html: mask(220, 330) },
  { out: 'src/images/mask-thumb.png', w: 400, h: 225, html: mask(400, 225) },
  { out: 'src/images/mask-backdrop.png', w: 400, h: 300, html: mask(400, 300) },
  { out: 'src/images/focus-ring.9.png', w: S + 2, h: S + 2, html: ring },
];

const browser = await chromium.launch();
try {
  for (const job of jobs) {
    const p = await browser.newPage({ viewport: { width: job.w, height: job.h }, deviceScaleFactor: 1 });
    await p.setContent(job.html);
    await p.screenshot({ path: job.out, omitBackground: true });
    await p.close();
    console.log(`make-card-art: ${job.out} (${job.w}x${job.h})`);
  }
} finally {
  await browser.close();
}
