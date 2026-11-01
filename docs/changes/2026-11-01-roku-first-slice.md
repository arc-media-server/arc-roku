# Roku app: first slice (1 November 2026)

## What changed

The first version of Arc for Roku, built without a Roku to hand so the groundwork is ready when
one arrives:

- **Finding Arc and signing in.** Discovery scans the Roku's /24 for `GET /api/v1/discover` on
  port 8099 (32 at a time, 1.5 s each), with "Enter an address" as the fallback. Sign-in uses Arc's
  device link (`POST /auth/link`, poll every 3 s, approve in Arc's Devices), the same flow as arc-tv
  and arc-android. The token is kept in the Roku registry and sent as `Authorization: Bearer`.
- **Profiles** with the PIN pad, **Home** with the same rows and order as the other apps (a port of
  arc-tv's row resolver: continue watching, next up, seasonal, watchlist, recently added per
  library, custom rows, collections, playlists), a hero backdrop that follows focus, and an options
  (*) menu for switching profile, signing out or choosing another server.
- **Title pages:** logo, details, overview, Play/Resume, play from the beginning, watched and
  watchlist toggles, seasons and episodes landing on the next episode (or the one opened from Home).
- **Player:** custom controls (skip ±10 s, rewind/fast-forward ±30 s, debounced seeking), Arc's
  playback decision from the Roku's real decoder caps (codecs, HEVC profiles, HDR10/HLG/Dolby
  Vision, bit depth, display height, audio channels), falling back direct → remux → conversion
  when the Roku reports an error, progress every 10 s, the conversion kept alive every 30 s and
  ended on exit, and BIF thumbnails while scrubbing (from Arc PR #329).
- **Deep links:** `contentId` opens that item's page.
- Tooling: `npm run check` (BrighterScript, zero diagnostics, strings catalog), `npm test` (unit
  tests of the shared helpers in brs-node), `npm run sideload` (roku-deploy, `.env` never committed).

## Decisions

- BrighterScript over plain BrightScript: it catches mistakes at build time, and it outputs
  plain .brs that a Roku runs unchanged.
- Converted streams use Arc's existing HLS and start at `offset_ms`, as on the other apps; a seek
  past what's converted starts a new session.
- Thumbnails use Roku's BIF format, which Arc now serves next to the web's sprite sheets, rather
  than cutting sheets on the Roku.
- Episodes opened from Home show the series page focused on that episode (as Plex for Roku does)
  rather than a separate episode page.

## Logging

`print "Arc: ..."` lines, readable over `telnet <roku> 8085`: discovery outcome with count and
duration, each playback attempt's method, player errors with Roku's code, and each failed API call
(method, path without query, status and message). Sign-in paths are cut to `/auth/link/…` because
they hold the secret poll id. Never tokens, server addresses, query strings or bodies.

## Checked, and what still needs a Roku

Checked: `npm run check` (no diagnostics), `npm test` (all pass), and a walk-through in the
brs-engine simulator against a scratch Arc with the test library: server screen, profiles with
live data, Home rows with live artwork, and Firefly's page with its episode row and watched ticks.

**Not yet checked on a real Roku** (none of these can be judged in the simulator):
video playback and every fallback, the EVENT-type HLS conversion (start position, seeking),
BIF thumbnails, HDR and audio passthrough caps, fonts and the horizontal button row (the simulator
stacks buttons and falls back on fonts), and performance on a low-end model.
