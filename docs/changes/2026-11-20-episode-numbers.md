# Episode numbers written as "S1 · E4"

The owner's rule for every Arc app (arc-media-server's `docs/AGENT-RULES.md`, "Episode numbers",
added by arc-media-server#493): one way of writing a season and episode number everywhere.

## What changed

- **One formatter.** `episodeCode` in `format.bs` gives `S1 · E4`: no leading zeros, no comma,
  and ` · ` as the only separator. A special (season 0) is `Special 3` (a new string,
  `Special %1`, in the catalogue). `episodeNumber(season, episode)` does the work, for screens
  that have only the two numbers, and `episodeTitled` gives `S1 · E4 · Pilot` where the episode
  itself is the subject.
- **Every place that wrote a number now uses them:**
  - **Cards:** the line under the show's name is just `S1 · E4`. It used to be
    `S1 E4 · Pilot`, and the episode's title no longer shares that line.
  - **The player's title line:** it was `S2, E4 • Day of Atonement` and is now
    `S2 · E4 · Day of Atonement`.
  - **The player's other episode text:**
    - the Info card: `S2 · E4 · 24m · …`;
    - the Episodes tab's tiles: `S1 · E8`, or `Special 3`;
    - Up Next's heading;
    - the subtitle of the episode Up Next starts.
  - **A title's page:**
    - the line under the title, `S1 · E8 · Ariel · 46m`;
    - the buttons, `Play S1 · E2` and `Resume S1 · E2`.
  - **A show's season lists:** each episode's line under its picture was `E4 · 46m` and is now
    `S1 · E4 · 46m`. The title stays on its own line above.
  - **Play queues:** the subtitle passed to the player when playing or shuffling a season.

## Decisions

- **Season lists show the season too.** The line under an episode's picture had only `E4`. The
  rule says to write numbers as `S1 · E4` everywhere, so it now has both. An episode outside the
  order still shows no number.
- **No "Start watching · S1 · E4" button.** The Roku's title page has none: an episode that
  hasn't been started shows `Play S1 · E4`. So there is nothing to change there.

## Checks

- `npm run check`: types fine, 251 strings (one new), the catalogue is up to date.
- `npm test`: all passed. Changed and new tests:
  - `episodeCode`, including a special and a missing number;
  - `episodeTitled`;
  - both `playLabel` forms;
  - `heroFacts`;
  - `osdEpisodeLine`;
  - `seasonCardLine`, including a special and a missing episode.
- `npm run build` gives `out/arc-roku.zip`.
- No simulator walk, as the owner asked; they sideload the build. To check on screen:
  - Continue Watching cards;
  - the player's title line and Info card;
  - an episode's page and its Play/Resume button;
  - a show with Specials.

## Limits

- Screenshots in older change notes (for example `2026-11-18-hide-spoilers/`) show the old
  format. They record those changes as they were, so they're left alone. No current screenshot or
  test expects the old text.

## Logging

Nothing new. This changes text only.
