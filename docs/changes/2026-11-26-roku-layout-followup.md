# Roku layout follow-up

- Centre the Settings avatar and its initial over the profile name and server.
- Keep the sidebar’s Arc mark anchored when the rail expands and reveal the lettering beside it.
- Lower the series overview so the season bar peeks in at the bottom. Down reveals
  the episode row. Up returns to the overview.
- Draw the cast focus ring inside the portrait to keep the full circle inside the card slot.
- Preserve the source aspect ratio in the 4:3 Backdrops style, with a centred crop.
- Start Recommended with its first shelf directly below the library tabs, as on Android TV.
- On Home, show the hero while browsing Continue Watching. Other shelves, including a
  separate Up Next, move up to use that space.

## Decisions

The season-bar peek follows Android TV and Apple TV. Both Roku and Kodi follow
Android TV’s rows-only Recommended layout.

## Checks

- `npm run check`, `npm test`, `npm run build`, and `git diff --check` passed.
- Walked the screens in brs-engine against a local fixture with generated artwork.
- Physical Roku hardware and playback remain unchecked.

## Logging

Layout changes only. No new logs.
