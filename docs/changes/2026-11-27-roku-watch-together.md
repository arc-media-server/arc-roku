# Watch Together on Roku

Start a room from a title's More menu or from a playable movie or episode card. A series uses the episode its Play button would open. The lobby shows who is in the room and lets the host invite people, renew a room code, or end the room. Join through the Watch Together row under Continue Watching, or enter a code from Watch Together in the sidebar. The row goes after the first shelf when Continue Watching is empty or hidden.

Roku uses the existing Arc room API. Everyone streams their own copy with their own playback settings. Play, pause, seek and episode selection follow the shared room. Heartbeats report buffering and readiness using the file position and current generation. Roku OS 16 and later also receive room updates through native SSE. Older Roku OS versions receive updates in their heartbeat responses. The player corrects larger drift with a seek. Back from the player returns to the lobby, where Back or Leave room leaves the room and lets Arc hand off hosting.

Arc uses named invitations and renewable codes. Plex's legacy Watch Together flow starts from a title and invites friends into a lobby. The Roku lobby follows Arc's existing clients so it can join a room they create.

The room controls are gated by the server's per-profile capability. Room requests use the existing signed-in device session. Logs omit room identifiers, invite codes, participants and response bodies. Routine absence and heartbeat failures are handled in the room UI.

## Verification

- `npm run check`, `npm test` and `npm run build`.
- The player test covers code entry normalization, clock precision, shared seeks on converted streams, stale snapshots, readiness and access changes.
- BrightScript Simulator with a scratch Arc API verified Home invitation, joining, the lobby, heartbeat activity and leaving.
- Cross-device timing, playback on physical Roku hardware and streaming over a WAN still need device testing.
