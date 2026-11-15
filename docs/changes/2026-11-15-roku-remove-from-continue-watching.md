# Roku: Remove from Continue Watching (15 November 2026)

## What changed

The * menu on a card in **Continue Watching** or **Up Next** now has **Remove from Continue
Watching**, as on the web. It was the only way to clear something you've given up on, and the Roku
didn't offer it.

- **What it does:** calls `DELETE /home/continue/{id}`, then the page loads again, as it does after
  Watched or Watchlist.
- **What Arc keeps:** the title isn't marked watched, and its resume point is kept.
- **For an episode,** Arc takes its whole show out until something of it is played again.
- **Where it appears:** the same rows as the web:
  - Home's Continue Watching;
  - Home's Up Next (when the profile shows it as its own row);
  - a library's Recommended "Continue Watching".
- **Where it doesn't:** other rows, grids and search results.
- **In the menu,** it sits after Mark as watched and the Watchlist, before Go to show or Go to
  details.

**Code:**
- `continueRow` on Home's rows (`shared/home.bs`) and on Recommended's rows
  (`shared/recommended.bs`).
- `inContinue` on the cards (`shared/cards.bs`), set by HomeScreen.
- The menu entry and its call are in `shared/cardmenu.bs`.
- `cardmenu.bs` is now part of the unit-test run (`testCardMenu`).

## Logging

Nothing new. A failed removal is logged by `ApiTask`'s one-line failure log (method and path, which
holds only the item's id; no URL or token).

## Checked, and what still needs a Roku

- `npm run check`: no diagnostics. The catalog is up to date (228 strings, one new).
- `npm test`: ALL PASSED, including 8 new checks:
  - which rows can be removed from;
  - the menu with and without the entry;
  - no menu on a collection.
- **Community simulator (brs-cli) against a scratch Arc** built from arc-media-server main, with
  the generated test library and two episodes part-watched (Firefly "The Train Job" and Mushoku
  Tensei "A Friend"):
  - **Home:** * on the Firefly card in Continue Watching shows Resume, Play from the beginning,
    Mark as watched, Remove from Continue Watching and Go to show.
  - **Choosing it:** Home reloads with only Mushoku Tensei in Continue Watching. Arc no longer
    lists Firefly there, and it keeps its 10-minute resume point, unwatched.
  - **Other rows:** * on a Recently Added card has no remove entry.
  - **Library page:** the TV library's Recommended page offers it on its Continue Watching card.
- **Not checked in the simulator:** the separate Up Next row (only shown when a profile splits Up
  Next out). The unit tests cover it.
- **Not checked on a real Roku.**
