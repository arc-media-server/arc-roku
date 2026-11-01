# Roku title pages: cast, collections, More Like This and extras (1 November 2026)

## What changed

- Under a title's buttons, as on the other apps' title pages: a show's seasons, then **Cast**
  (picture, name and character; a person opens their titles), each **collection** the title is in
  (without it), **More Like This** (`/items/{id}/similar`) and **Extras**. Rows appear as each
  part loads, keeping the focus on the row it was on.
- **Trailers and extras play** in the player without the playback decision, choices, progress or
  Up Next. They go through `POST /cast` like everything else, which needed Arc to accept extras'
  links (arc-media-server#330, which also fixes trailers in the LG/Samsung app).
- **The buttons sit side by side** on every Roku: a one-row list of Arc's own buttons replaces
  Roku's ButtonGroup, whose horizontal layout the simulator ignores (it stacked the buttons over
  the episodes). The page slides up when the rows below have the focus, and the buttons fade.
- Instant Replay in the player goes back 10 seconds, as on Roku's own players.

## Logging

`Arc: playing an extra`; failed calls are logged by the API task as before.

## Checked, and what still needs a Roku

In the simulator against a test Arc (with the server fix): Heat's page with its cast, More Like
This and extras rows; a trailer opened in the player (its stream link was accepted) and Back
returned to the extras row; Firefly's page with the buttons side by side and the season row below.
The simulator can't decode video, so a trailer actually playing still needs a Roku.
