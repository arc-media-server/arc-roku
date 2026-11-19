# Hide Spoilers on Roku

The existing profile Hide Spoilers preference is now in Settings. For unstarted, unwatched
episodes it conceals episode stills and descriptions, keeping titles and playback actions.
Watched/resumed episodes, movies and series remain unchanged. Series art replaces episode
stills where available, otherwise a plain placeholder; source metadata is never changed.

The guard covers shared cards across browsing, Home's focused summary/background, episode
details, person-page backgrounds, player Info/Episodes cards and Up Next artwork. Global
preference observers redraw presentation without restarting playback or reloading a grid.
The preference loads once per profile (not per card), on live profile hints and foreground
return. Loading/failure is conservative, and profile/revision tags reject stale replies.
Settings waits for save success, prevents duplicate saves and gives failure/retry feedback in
the existing note area. Existing ordinary setting-save behavior is outside this change.

## Decisions

Uses Arc's existing hide_spoilers API and web/Kodi rule: hide until started or watched. Plex's
[official Mobile settings](https://support.plex.tv/articles/205671068-settings-plex-mobile/)
documents hiding episode thumbnails/summaries; this follows Arc's existing boolean profile
rule rather than claiming identical Plex Roku options. Existing layouts/controls retained.
No new server API, dependency or device-specific playback behavior.

## Checks

- Original baseline main `8418474`; `codex/roku-hide-spoilers`. The merge update below
  integrates the subsequently merged Show Missing Episodes PR #22.
- `npm run check`: passed (BrighterScript, 247-string catalog). Repeated after adding the
  relevant foreground preference refresh; the affected profile callback passed again.
- `npm test`: **266 shared assertions passed**, plus existing native SSE, pre-roll and rating
  checks. New API, Settings, profile and card callback cases completed; its final player
  harness initially imported duplicate valueOr helpers. Corrected the harness import list,
  then ran only the failed player case and remaining theme script: passed. The targeted player
  command first needed the same local-network permission used by the main run. No outstanding
  failures; the whole passed suite was not repeated.
- Focused coverage: authenticated GET/PATCH prefs and refusal, no optimistic reveal, duplicate
  save suppression, stale profile/request rejection, loading/failure safety, immutable source,
  missing-art fallback, watched/resumed/off behavior, card artwork changes and real Up Next
  artwork callback. Rendering callbacks use field stand-ins, not a physical Roku.
- Actual **brs-engine 2.6.2 simulator**: Settings Off → On made one authenticated PATCH with
  only hide_spoilers=true; saved [Settings screenshot](2026-11-18-hide-spoilers/settings-on.jpg).
  Usage limit interrupted the following Back action before execution. On resume, preserved
  the completed toggle/tests and ran only the remaining protected episode view: description
  absent, episode identity/actions retained, and fixture recorded only the safe series artwork,
  not the episode still. [Episode screenshot](2026-11-18-hide-spoilers/protected-episode.jpg).
- No physical Roku/remote, real media/decoder, playback transition, provider or owner-server
  acceptance. Simulator rendering differs from a device. Older firmware without live events
  gets the choice on profile load/foreground return; immediate remote-device updates there are
  not claimed. Existing dependencies reused; temporary fixture/simulator stopped.

## Logging

Existing API Task logs the failed preference route once (queries stripped). Save failure uses
the existing note area; no duplicate warning, per-card logs, metadata bodies, secrets or URLs.

## Main merge — 19 November 2026

Merged main `30938d9` (Show Missing Episodes #22) without rewriting branch history. Resolved
shared card fields/rendering by retaining both availability/dimming and spoiler eligibility/safe
artwork. Both feature test entry points remain; regenerated the string catalog (251 strings).
Auto-merged title/season menus were inspected and retained.

Validation of this combined tree: `npm run check` passed; **274 shared assertions passed**;
focused missing-episode and spoiler API/callback scripts passed. Extended the actual CardItem
callback regression to check a missing protected card uses safe art AND 0.45 opacity, and that
available cards restore opacity without losing protection. The shared malformed-JSON fixture
prints its expected parser diagnostic; assertions still pass. No repeated simulator walk or
unrelated native SSE/playback checks; the layout is unchanged and previous screenshots remain
historical evidence.
