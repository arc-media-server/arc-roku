// Remakes the Roku app's icons, splash screens and in-app logo from Arc's logo files
// (arc-media-server docs/brand, copied unchanged into brand/). Run after the brand files change:
//
//   node scripts/make-logos.mjs
//
// The SVGs are drawn by Chromium (Playwright's, which this needs installed), as they are: nothing
// is redrawn or restyled. The same approach as arc-tv's scripts/make-logos.mjs.
//
//   src/images/icon_fhd.png     540x405   arc-logo-white.svg, 400 px wide, centred on BG
//   src/images/icon_hd.png      290x218   the same, 214 px wide
//   src/images/splash_fhd.png   1920x1080 arc-logo-stacked-white.svg, 320 px tall, centred on BG
//   src/images/splash_hd.png    1280x720  the same, 213 px tall
//   src/images/logo-stacked.png 227x240   arc-logo-stacked-white.svg on transparent (server pick,
//                                         About)
//   src/images/logo-main.png    211x56    arc-logo-white.svg on transparent (profiles, the open rail)
//   src/images/logo-sign-in.png 360x96 arc-logo-white.svg on transparent (device linking)
//   src/images/logo-mark.png    56x56     arc-mark-white.svg on transparent (the closed rail)

import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';

const BRAND = 'brand';
/** The manifest's splash_color, so the splash and the app's first frame match. */
const BG = '#0b0f10';

const require = createRequire(import.meta.url);
let chromium;
try {
  ({ chromium } = require('playwright'));
} catch {
  console.error('make-logos: needs Playwright (npm i -D playwright, then npx playwright install chromium)');
  process.exit(1);
}

const svg = (name, w, h) => readFileSync(`${BRAND}/${name}`, 'utf8').replace('<svg ', `<svg width="${w}" height="${h}" `);
const centred = (w, h, body, bg) =>
  `<!doctype html><html><head><style>html,body{margin:0;padding:0;background:${bg};overflow:hidden}` +
  `svg{display:block}</style></head><body><div style="width:${w}px;height:${h}px;display:flex;` +
  `align-items:center;justify-content:center">${body}</div></body></html>`;

// viewBoxes: the main logo is 136.02 x 36.20, the stacked logo 65.42 x 69.16.
const main = (width) => svg('arc-logo-white.svg', width, (width * 36.2) / 136.02);
const stacked = (height) => svg('arc-logo-stacked-white.svg', (height * 65.42) / 69.16, height);

const jobs = [
  { out: 'src/images/icon_fhd.png', w: 540, h: 405, html: centred(540, 405, main(400), BG) },
  { out: 'src/images/icon_hd.png', w: 290, h: 218, html: centred(290, 218, main(214), BG) },
  { out: 'src/images/splash_fhd.png', w: 1920, h: 1080, html: centred(1920, 1080, stacked(320), BG) },
  { out: 'src/images/splash_hd.png', w: 1280, h: 720, html: centred(1280, 720, stacked(213), BG) },
  { out: 'src/images/logo-stacked.png', w: 227, h: 240, html: centred(227, 240, stacked(240), 'transparent'), transparent: true },
  { out: 'src/images/logo-main.png', w: 211, h: 56, html: centred(211, 56, main(211), 'transparent'), transparent: true },
  { out: 'src/images/logo-sign-in.png', w: 360, h: 96, html: centred(360, 96, main(360), 'transparent'), transparent: true },
  { out: 'src/images/logo-mark.png', w: 56, h: 56, html: centred(56, 56, svg('arc-mark-white.svg', 56, 56), 'transparent'), transparent: true },
];

const browser = await chromium.launch();
try {
  for (const job of jobs) {
    const p = await browser.newPage({ viewport: { width: job.w, height: job.h }, deviceScaleFactor: 1 });
    await p.setContent(job.html);
    await p.screenshot({ path: job.out, omitBackground: !!job.transparent });
    await p.close();
    console.log(`make-logos: ${job.out} (${job.w}x${job.h})`);
  }
} finally {
  await browser.close();
}
