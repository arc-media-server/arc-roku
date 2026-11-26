# Roku layout follow-up

- Centre the Settings avatar and its initial over the profile name and server.
- Keep the sidebar’s Arc mark anchored when the rail expands and reveal the lettering beside it.
- Lower the series overview so the season bar peeks in at the bottom. Down reveals
  the episode row. Up returns to the overview.
- Draw the cast focus ring inside the portrait to keep the full circle inside the card slot.
- Preserve the source aspect ratio in the 4:3 Backdrops style, with a centred crop.
- Keep the Recommended hero on the first row. Scrolling down gives the shelves
  the space below the library tabs, and returning to the first row restores the hero.

## Decisions

The season-bar peek follows Android TV and Apple TV. Android TV’s Recommended tab
uses shelves only. Roku retains its opening hero and matches [Kodi’s first-row
behaviour](https://github.com/arc-media-server/arc-kodi/pull/53). The existing tabs
and remote navigation remain the way to browse the library.

## Checks

- `npm run check`, `npm test`, `npm run build`, and `git diff --check` passed.
- Walked the screens in brs-engine against a local fixture with generated artwork.
- Physical Roku hardware and playback remain unchecked.

## Logging

Layout changes only. No new logs.
