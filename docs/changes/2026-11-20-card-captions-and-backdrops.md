# Captions under every card, and the Backdrops look

Two gaps the owner found on the Roku after the polish PRs.

## What changed

- **Captions under posters.** Each card now shows its title and a second line under it, like
  arc-tv's cards and Plex's Home. Before, only 16:9 cards (such as Continue Watching) had them, so
  library grids, Recommended and most Home rows showed bare posters. The second line is the same as
  the other apps': the year for a film or show, `S1 E4` and the episode title for an episode, the
  season and new episodes for a new season, and a count for collections and folders.
  - Poster slots grow from 330 to 410 px tall, and their rows from 400 to 480 px, to make room for
    the two lines.
  - Rows, grids, search and the person page get their sizes from one place, `cardSize` and
    `cardRowHeight` in `cards.bs`, so a card and its row always agree.
- **Backdrops.** The web's Edit Home lets Continue Watching and Up Next be shown as Backdrops (the
  `arc` style): a 4:3 card with the title's background art, a shade along the bottom and the
  title's logo low on it, as the Apple TV app shows them. Before, the Roku read this as an ordinary
  16:9 thumbnail. It now draws Backdrops as arc-tv does:
  - a 400 x 300 picture with rounded corners (`mask-backdrop.png`, from
    `scripts/make-card-art.mjs`);
  - the logo 72% across and clear of the progress bar;
  - the title in place of the logo when a title has none;
  - the caption under it.

  A library's Recommended rows with the `arc` style are drawn the same way.

## Decisions

- **Captions everywhere, as arc-tv** (where captions are on by default, Home included), and as
  Plex for Roku, which labels its posters.
- **Backdrop cards keep the thin progress bar**, not the 16:9 cards' resume strip, because the
  strip would cover the logo. arc-tv does the same.
- **The logo isn't given a load size.** The simulator stretches an image to its load size, which
  is what stretched Home's clear logo before.

## Checks

- `npm run check`: types fine, 250 strings, the catalog is up to date.
- `npm test`: all passed. New tests cover `arc` becoming `backdrop` for Home's rows and for
  Recommended, and the poster and Backdrop slot sizes. The spoiler card test now stubs the two new
  nodes.
- `npm run build` gives `out/arc-roku.zip`.
- The owner said no simulator walk is needed: they sideload the build. These still need checking
  on screen:
  - the captions under posters in a library, in Recommended and on Home;
  - Continue Watching set to Backdrops on the web;
  - a title with no logo shown as a Backdrop.

## Limits

- The **season poster / show poster** choice for carrying-on rows shown as posters isn't followed
  yet: episodes use the show's poster, as before.

## Logging

Nothing new. These are layout changes, with no new requests or failure paths.
