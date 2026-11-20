# Layout fixes and the new Arc logo

The first of three PRs that bring the Roku app in line with arc-tv (LG/Samsung) and arc-apple,
from the owner's first look at a sideloaded build. Next: season tabs, then the polish pass.

## What changed

- **Room beside the rail.** Pages started 120 px from the left edge, against the nav rail. They
  now start at 192 px, as arc-tv's pages do (Home, Details, Person, the library grid and its
  pills, Settings, About). Rows are 1728 px wide to match; the poster grid's gap is 28 px so
  seven posters still fit.
- **Logos keep their shape.** The title logos on Home and the title page no longer set a fixed
  load size. The simulator squashed every picture to its load size, which stretched the logos.
  A real Roku keeps the shape either way.
- **No hint on Home.** "Left for libraries and search · * for options" in the top right is gone;
  no other Arc app shows it. The library grid's "* for options, sort and filter" stays.
- **Title page order.** Seasons, then Cast, the collections, More Like This, and Trailers &
  Extras, as arc-tv. It was Extras, More Like This, Cast, collections.
- **Focus in the library grid.** Cards also show their white edge when their grid reports focus
  as `itemHasFocus` alone. The simulator's grid only reports focus that way, so nothing showed.
- **Focus edge not clipped.** The white edge was drawn 5 px outside the card, and rows clip
  what's left of their start, so the first card's left edge was missing (owner's screenshot).
  It's now drawn 5 px inside the picture, on top of it.
- **The new logo** (arc-media-server `docs/brand`, chosen 13 November). The brand SVGs are
  copied unchanged into `brand/`, and `scripts/make-logos.mjs` (as arc-tv's) draws them with
  Chromium into:
  - the channel tile (`icon_fhd.png` 540x405, `icon_hd.png` 290x218): the main logo, white
    on the splash colour;
  - the splash screens (`splash_fhd.png`, `splash_hd.png`): the stacked logo;
  - `logo-stacked.png`, which replaces the old teal tile on the server picker and About.

## Decisions

- The poster cards keep their load size. Real Rokus need it to save memory, and posters are
  almost always the card's 2:3 shape. An odd-shaped poster (one that isn't 2:3) can still look
  squashed in the simulator, but not on a Roku.
- The sign-in and profile screens don't show the logo yet, and the rail doesn't show the mark
  (arc-tv does both). Each needs a layout change, so they're in the polish pass.

## Checks

- `npm run check`: 250 strings, catalog up to date.
- `npm test`: passed.
- `npm run build`: packaged.
- Simulator: not run. The owner now tests the sideloaded builds directly.
- Real Roku: not checked.

## Logging

None. These are layout and artwork changes with no new failure paths.
