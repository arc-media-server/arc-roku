# Arc for Roku: notes for AI agents

The Roku client for Arc Media Server. Arc's own repository holds the product rules (`CLAUDE.md`
there): they apply here too, in particular pull requests only (never push to main, never force
push), a change note per change in `docs/changes/YYYY-MM-DD-<slug>.md`, product decisions logged on
Arc's #80, and never marking real-device, playback or HDR checks done without evidence from a real
Roku.

- Talk to Arc only through `/api/v1` (`docs/api-v1-contract.txt` in Arc). If the app needs something
  the API lacks, add it to Arc in its own PR and link the two.
- Match the other Arc apps (arc-tv, arc-android): Home rows (`src/source/shared/home.bs` is a port of
  arc-tv's), playback fallbacks, the player's controls. Match Plex for Roku's behaviour unless
  there's a reason not to.
- Every string the app shows goes through `tr()`; `npm run check` fails if the catalog is stale.
- Network calls run in Task nodes (`ApiTask`), never on the render thread. Keep pure logic in
  `src/source/shared/` so `npm test` can cover it without a device.
- Logging: `print "Arc: ..."` for outcomes and failures only. Never print tokens, link poll ids,
  server addresses, full URLs or query strings.
- Before a PR run `npm run check` and `npm test`, and walk changed screens in the simulator
  (README); list the real results and what still needs a device.
- Never commit `.env`, developer passwords or signing keys.
