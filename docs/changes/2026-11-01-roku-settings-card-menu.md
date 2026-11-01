# Roku: Settings and the card menu

## What changed

- **Settings** (Left on Home, at the bottom of the list of places). It shows the profile's playback and
  subtitle preferences: auto-play the next episode, skip intros automatically, preferred audio
  language, when to show subtitles, the subtitle language, and the subtitle size, colour, background
  and position. Each choice opens a radio list and is saved with `PATCH /me/prefs`, so it follows the
  profile to the web and the other apps. Below those are Switch Profile, Server and Sign Out of This
  Roku, which used to be the Home * dialog. An about line gives the version and the TMDB/TheTVDB
  attribution.
- **The * card menu** on Home, library and other grids, and search results. It matches the other
  apps' title menu:
  - Play, or Resume and Play from the beginning.
  - Mark as watched or unwatched.
  - Add to or remove from the Watchlist.
  - Go to show (for episodes) or Go to details.

  In a library, the card's actions come first, followed by the existing view, sort and filters. A
  watched or Watchlist change reloads the screen, and focus stays where it was.
  - The menu code is shared: `src/source/shared/cardmenu.bs`.
  - The screens reuse `OptionsPanel`.

## Decisions

- The account actions moved from a Home dialog into Settings, as on Plex for Roku, where * belongs
  to the focused title.

## Checks

- Unit tests pass.
- The strings catalog is up to date, and `npm run check` is clean.
- Walked through in the brs-engine simulator against a scratch Arc:
  - The Home card menu, on an episode and on a Watchlist title.
  - The Settings list and the subtitles radio list.
  - The Movies grid's combined menu. Mark as unwatched saved, and the tick went away with focus kept.
- Not yet checked on a real Roku.

## Logging

- Failed saves are logged by `ApiTask`'s existing one-line failure log (the method and path only).
- Nothing new is logged.
