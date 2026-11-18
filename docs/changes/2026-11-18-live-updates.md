# Live updates — 18 November 2026

## What changed

Latest main `bd92ebd350192b42dd4da62f89bec5afba5fdae2` lacked live events. A dedicated `LiveEventsTask` now keeps authenticated `/api/v1/events` open while a profile is in the foreground, using Roku OS 16's native `AsyncGetSSEvents`. Networking stays off the render thread. This follows Android #37, server `docs/EVENTS-API.md`, and web `lib/live-updates.ts`.

Hints batch for 1.5 seconds and flush at most every five seconds during continuous scans. Opening resync is skipped; reconnects catch up. Bearer credentials/replay cursors travel in headers, and the cursor survives a foreground pause for the same profile. Profile switches/sign-out dispose of the old Task; app-focus loss/scene hiding closes it, and return reconnects. Revoked authentication returns to sign-in. Retry-After is bounded/honored; failed connections back off from five seconds to a minute.

Matching hints refresh Home/Recommended, details, and profile preferences. Open title/Settings menus defer reload until closing. Grids/search/player never reload mid-use; normal navigation refresh remains. Notifying `global.liveTopics` lets independent preference consumers (theme music) follow profile/resync hints.

## Decisions

Native SSE requires Roku OS 16+. Older firmware keeps existing navigation refresh and logs the capability limitation; the app minimum does not change. Native frames avoid buffering a whole long-lived response or inventing a poll. Arc/Android's existing hint semantics are the requested behavior; no Plex UI or new screen is added. Unknown topics are ignored and never imply admin API permissions. Merge live updates before theme music; this PR is independent.

## Recovery and checks

The original unpushed local commit and dependency/log directory were lost when the managed environment reset its `/tmp` volume on 18 November. This implementation/tests were faithfully reconstructed from retained work records onto latest main, in a durable workspace. Historical results from 17 November were: `npm run check` passed, `npm test` passed including two native streaming stand-in runs (four authenticated connections), `git diff --check` passed. Those outcomes do not substitute for fresh checks of reconstructed source.

Fresh validation is pending dependency restoration. `node_modules` and the optional native simulator dependency `canvas-linux-x64-gnu` did not survive the reset. The test script again runs actual repository `brs-cli --no-sg` streaming against an isolated stand-in twice: fragmented frames delivered before EOF, cancellation and cursor reconnect; auth and versioned paths are asserted. Shared cases cover opening/later resync, topic targeting, malformed/unknown hints, scan batching and bounded retry.

Historical full MainScene/Task simulator walkthrough was blocked by `Error parsing XML: Malformed comment` (line 2, column 47, character w); even a disposable generated-XML comment workaround did not fix it. Source/staged XML parsed with Python ElementTree. No full-scene lifecycle/device claim is made.

No new visible UI/layout/control/text: no screenshot is needed for this transport change, and no fabricated simulator screenshot is included. Not tried on a TV. Hardware SSE, lifecycle/focus refresh, playback/audio/HDR, proxies and sustained device use remain unverified. Only scratch fixtures are used, never owner data/server/keys.

## Logging

One static warning per connection outage, reset after reconnect; one static capability fallback line on older firmware. No per-event/heartbeat/progress logs; no tokens, codes, names, identifiers or URLs. Existing `ApiTask` diagnostics cover failed refresh API calls.
