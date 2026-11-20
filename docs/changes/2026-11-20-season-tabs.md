# Season tabs on a show's page

The second of three PRs that bring the Roku app in line with arc-tv and arc-apple (after #26).

## What changed

- **Season tabs.** A show's page listed every season as its own row. It now has a row of tabs
  under the buttons (each season, then Not in This Order when the order leaves episodes out) with
  the chosen season's episodes in one row under them, as arc-tv and arc-apple do. The tabs
  reuse the library's `PillBar`, which gains `followFocus`: as on arc-tv, moving along the tabs
  shows that season straight away.
- **Focus.** Down from the buttons goes to the tabs, Down again to the episodes; Up goes back
  the same way. The tabs fade while a row below the episodes (Cast and so on) has the focus.
  The page still lands on the episode it was opened for, or the one Play would start, with its
  season's tab chosen.
- **The gap beside the rail is about 25% smaller** (owner): pages start 170 px from the left
  instead of 192 px (66 px past the rail's icons instead of 88 px), rows are 1750 px wide.

## Decisions

- **Season actions stay in the \* menu.** Mark Season as Watched and Shuffle Season are still
  under \* on an episode. arc-tv puts them as buttons beside the tabs, but on Roku the \* menu
  is where Plex and this app keep such actions.
- **Tabs for a single season.** A show with one season still gets its single tab, as on arc-tv,
  so the season's name is shown.

## Checks

- `npm run check`: 250 strings, catalog up to date.
- `npm test`: passed.
- `npm run build`: packaged.
- Simulator and real Roku: not run here. The owner tests the sideloaded build.

## Logging

None. The tabs only regroup data the page already loads, so there are no new failure paths.
