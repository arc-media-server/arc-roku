# Roku: Mark Season as Watched and Shuffle Season (15 November 2026)

## What changed

On a show's page, the * button on an episode in a season row opens a menu (the same panel as
Home's card menu). It holds the episode's own entries (Play or Resume, Play from the beginning,
Mark as watched), then the season's:

- **Mark Season as Watched** marks every episode of that season. When they're all watched it reads
  **Mark Season as Unwatched** and does the opposite. It uses Arc's
  `PUT /api/v1/items/{show}/played` with `season_number`, the season in the profile's episode
  order, as the rows are. The page then reloads (ticks, Play's next episode) and keeps the focus
  on the same row.
- **Shuffle Season** (two or more episodes on disk) makes one of Arc's play queues
  (`POST /api/v1/play-queues`) from the season's episodes on disk in a random order and plays its
  first entry. When an episode ends, Up Next offers the queue's next entry instead of Arc's next
  episode. Playing it moves the queue there (`PATCH … operation: select`, which also passes over
  entries that are no longer available) and plays it with the updated queue.

Episodes not on disk are left out of both, as on the web and in arc-tv (#15) and arc-android (#24).

**Code:**
- `shared/seasonactions.bs`: the season menu, watched state, shuffled ids, and the queue's current
  and next entries.
- `DetailsScreen`: the * menu on season rows and the two requests.
- `PlayerScreen`: Up Next and playing on through a queue.
- `MainScene`: passes the queue to the player.

## Decisions

- **In the * menu, not beside the seasons.** The web and arc-tv put these as buttons beside season
  tabs. The Roku page shows seasons as rows with no tabs, and * is already the Roku's options key
  (Home and the grids use it), so they're in the menu on that season's episodes. Matches what Plex
  offers per season, so nothing for #80.
- **If Arc refuses to move the queue** (409: it was changed elsewhere, say), the next episode still
  plays, without the queue, rather than stopping. Picking another episode from the player's
  Episodes card also plays on without the queue.
- **No capability check.** The app only talks to Arc, and every supported Arc has play queues. A
  refused queue shows "Couldn't start playing this season." on the page.

## Logging

- One line when a season is shuffled ("Arc: shuffling a season (N episodes)").
- One line if the queue can't move on (with the HTTP status) before playing on without it.
- Failed requests are still logged once by `ApiTask` (method, path without the query, status).
- Arc logs the queue's creation on its side.

## Checked, and what still needs a Roku

- `npm run check`: no diagnostics, and the catalog is up to date (232 strings, five new).
- `npm test`: ALL PASSED, 178 checks, 14 of them new:
  - the episodes on disk, and when a season counts as watched;
  - the menu entries, with no Shuffle for one episode and none for a season not on disk;
  - shuffled ids (each on-disk episode once);
  - the queue's current and next entries, passing over unavailable ones.
- **Community simulator (brs-cli) against a scratch Arc** (arc-media-server main), on Firefly
  (Season 1 with 15 episodes, Specials with one):
  - **The * menu** on Bushwhacked showed Play, Mark as watched, Mark Season as Watched and Shuffle
    Season.
  - **Mark Season as Watched** marked all 15 of Season 1 in Arc and left Specials alone.
    Afterwards it read Unwatched, and choosing it unmarked all 15. The ticks went and the focus
    stayed on Season 1. (The first try put the focus on Specials after the reload; fixed.)
  - **Shuffle Season** made a queue of exactly Season 1's 15 episodes in a random order, and the
    player started on its first entry (Arc logged "Firefly · S1 E13").
- **Checked against Arc directly, not in the simulator:**
  - The `select` request the player sends moved the queue to its second entry (revision 2), and a
    stale revision returned 409, the case that plays on without the queue.
  - The simulator can't play video to the end, so Up Next through a queue wasn't seen on screen.
- **Not checked on a real Roku:** Up Next playing on through a shuffled queue, and the whole flow
  on hardware.
