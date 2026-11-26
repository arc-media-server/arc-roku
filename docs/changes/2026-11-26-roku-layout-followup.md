# Roku layout follow-up

- Centre the Settings avatar and its initial over the profile name and server.
- Keep the sidebar’s Arc mark anchored when the rail expands and reveal the lettering beside it.
- Lower the series overview so the season bar is fully visible at the bottom. Down
  frames the season bar and episodes before revealing cast. Returning Up restores
  the same overview position. The episode shelf shows four full cards and a
  sliver of the fifth. Episode numbers, titles and descriptions line up with
  the thumbnail’s left edge, following Android TV.
- Centre-crop cast portraits without stretching them. Keep the focus ring inside
  the portrait and bring names into view when the cast shelf takes focus.
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
