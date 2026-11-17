# Arc for Roku: notes for AI agents

The Roku client for Arc Media Server (BrightScript/SceneGraph). Read `README.md`.

**Shared rules:** arc-media-server's `docs/AGENT-RULES.md` applies here (workflow, decisions, Arc's
design, API, logging). Read it at the start of a session: `../arc-media-server/docs/AGENT-RULES.md`
when the server is checked out beside this one, otherwise from GitHub. The essentials:

- Pull requests only: never push to main, never force push. Commits end with the Co-Authored-By
  trailer only, no session links. A change note per change in `docs/changes/`.
- Never point tests at the owner's server, data or keys. Never mark real-device, playback or HDR
  checks done without evidence from a real Roku. Never commit `.env`, developer passwords or keys.
- Only `/api/v1`; if it lacks something, an additive server PR, linked.

## This app

- **Checks before a PR:** `npm run check` and `npm test`, and walk changed screens in the simulator
  (README); list the real results and what still needs a device.
- Match the other Arc apps (arc-tv, arc-android) and Plex for Roku: Home rows
  (`src/source/shared/home.bs` is a port of arc-tv's), playback fallbacks, the player's controls.
- Every string goes through `tr()`; `npm run check` fails if the catalog is stale.
- Network calls run in Task nodes (`ApiTask`), never on the render thread. Pure logic goes in
  `src/source/shared/` so `npm test` covers it without a device.
- Logging: `print "Arc: ..."`; never tokens, link poll ids, server addresses, full URLs or query
  strings.
