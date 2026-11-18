# Show Missing Episodes on Roku

Show/Hide Missing Episodes is available in a show's More (*) menu and in a season episode's
existing * menu. It calls the existing authenticated seasons API with `missing=1`. Provider-only
episodes are dimmed, labelled Not on disk and focusable. OK and stale Play actions cannot start
them; their menu keeps the season's applicable actions and visibility toggle, excluding the
missing episode's own actions. Watched/Shuffle operate only on episodes on disk.

The choice starts off for each open show and survives refresh. A failed request keeps the last
successful view; request sequence tags reject old responses. Row/episode selection is restored
by the existing row identity plus item ID so inserting missing episodes retains an available
selected file. The show-level toggle is reachable even without any episode rows.

## Decisions

Uses existing More/season OptionsPanel controls, not a new screen or persistent preference.
Matches the local-show behavior in Arc Android/Kodi/LG/Samsung. Plex for Roku's equivalent
missing-provider control could not be confirmed in the bounded comparison; no parity claim.
Provider coverage and ordering depend on the server. No provider calls, scans or server changes.

## Checks

- Latest fetched main `8418474`; clean isolated `codex/roku-missing-episodes` worktree.
- `npm run check`: passed (BrighterScript and 249-string generated catalog).
- `npm test`: shared core **260 assertions passed** and existing native SSE checks passed.
  The new callback harness initially omitted the shared valueOr helper, then left its simulated
  title menu open before testing a season menu. Corrected only that harness. Ran the failed
  missing-episode script and remaining pre-roll/rating/theme scripts: all passed. Did not repeat
  the passed core/SSE checks. No unresolved test failures.
- Focused checks use the actual API Task/Bearer header and production callbacks with rendering
  stand-ins: encoded opt-in route, show/hide, empty/missing-only menu, failure/retry, stale reply,
  unavailable OK and stale Play guard. Pure tests cover labels and disk-only shuffle/counts.
- Actual **brs-engine 2.6.2 simulator** with generated local metadata: initial on-disk-only view,
  show from the title menu, multiple missing cards and their season menu without individual
  Play/watched actions, Back/OK on missing, hide through the season menu. Server fixture recorded
  authenticated seasons requests `[false,true,false]` and zero mutation/playback requests.
  Simulator input settles slowly: one immediate assertion was early; a bounded follow-up
  confirmed completion and the final screenshot. No input timing/device claims.
- [Actual simulator screenshots](2026-11-18-missing-episodes/).
- No physical Roku, real remote, media decode, HDR/audio, provider or owner-server acceptance.
  Simulator rendering/fonts differ from a real Roku. No tools/dependencies installed; existing
  matching dependencies reused. Temporary simulator and fixture server stopped.
- Initial development compilation caught an out-of-scope escape helper; changed the shared
  path helper to the existing roUrlTransfer.Escape convention before the passing checks.

## Logging

No additional per-item logs. Existing Task failure logging covers route/outcome and strips the
query string. No credentials, cast links or provider bodies added to logs.
