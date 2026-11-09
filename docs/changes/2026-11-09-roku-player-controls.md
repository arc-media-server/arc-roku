# Roku player controls in the Apple TV arrangement

The fifth part of `docs/plans/apple-tv-look.md`. The Roku player's controls now follow the Apple
TV app's (arc-apple `PlayerOSD`), as far as SceneGraph allows.

## What changed

**Layout:**
- The show's name is large at the bottom left, with "S2, E4 • the episode's name" above it. A film shows its title alone.
- Three round buttons sit at the right of the title row: Playback, Audio and Subtitles.
- The timeline is 12 px thick and split at the chapters, with a small upright marker.
- The time played sits under the marker, with a play/pause mark. The time left is at the right end.
- While scrubbing, the BIF picture shows above the marker with the chapter's name under it.

**The tab row under the timeline:** Info, then Chapters, Cast and Episodes where the title has them.
- A tab's card replaces the title and timeline, with the tabs above it.
- **Info:** the picture, the name and overview, then "S2 · E4 · 46m · 15 Nov 2002" with the quality badges.
- **Chapters:** a tile for each chapter, with its name and time, and a play mark on the current one. OK jumps there.
- **Cast:** a tile for each actor with a round photo (Roku OS 11 and later; square before), name and role. This is the episode's own cast, else the show's.
- **Episodes:** the season's episodes as pictures with "S1 · E8" and the name. The card opens on the one playing, and OK plays another.

**Remote:**
- On the picture, Left and Right still skip 10 seconds and OK pauses.
- Up goes to the round buttons, starting at Subtitles. Left and Right move along them, and OK opens that menu:
  - **Playback:** Quality, Version, Chapters;
  - **Audio:** the tracks;
  - **Subtitles:** the tracks.

  Back from a button's menu returns to its button. The * menu is unchanged.
- Down goes to the tab row and opens Info. Left and Right change the tab, Down goes into the card's tiles, and Up or Back goes back a step.

**While a card is open:**
- The controls don't hide while the buttons, tabs or a card have the remote, or a menu is open.
- Subtitles move to the top of the screen.
- Skip Intro sits above the title row while the controls show.

**Shared code:** the pure parts are in `shared/playerosd.bs`, with unit tests:
- the timeline's pieces, widths and marker position;
- the tabs;
- the episode line and the Info card's line.

## Decisions

- **The Info card has no Restart or Previous Episode buttons** (the Apple TV's have them). Instant Replay and the Episodes card cover these on Roku, and a card with both tiles and buttons would need a second focus row.
- **No Zoom Mode or Playback Speed.** Roku's Video node has no zoom setting, and changing the speed isn't supported for all streams.
- These are to log on arc-media-server#80 with the series.

## Checks

- `npm run check`: passes, and the strings catalog is up to date.
- `npm test`: ALL PASSED, including 15 new player checks.
- **Community simulator (brs-engine) against a scratch Arc,** playing Firefly S1E8 "Ariel":
  - the controls with the Subtitles button focused;
  - the Info card with the picture, overview, date and the SD and AAC 1.0 badges;
  - the Cast card with photos and roles;
  - the Episodes card scrolled to the focused episode.
- **The simulator doesn't play video,** so the timeline's moving position and scrubbing were not seen. Those, the round photos (`maskUri`), and the look on a TV need a real Roku.

## Logging

Playing another episode from the Episodes card prints "Arc: playing another episode from the player". Failed loads of the cast and seasons are logged by the API task, as before. Nothing else is new.
