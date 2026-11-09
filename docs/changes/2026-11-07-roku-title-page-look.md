# Roku title pages in the Apple TV look (7 November 2026)

The fourth part of `docs/plans/apple-tv-look.md`: a title's page as on the Apple TV.

## What changed

- **The hero's lines**, as the Apple TV's:
  - the content rating in an outlined box, then up to three genres;
  - the overview (three lines);
  - the year (or an episode's code and name) and length, then the file's quality badges in
    outlined boxes: 4K/HD/SD, DV HDR10/HDR10+/HDR10/HLG, the audio (DD+ 5.1, DTS-HD MA 7.1…)
    and Atmos or DTS:X;
  - "Starring" (three actors) and "Director" at the right, above the buttons.
- **Rows in the Apple TV's order and names:** a show's seasons, **Trailers & Extras**, **Related**
  (was More Like This), **Cast**, then the collections the title is in.
- **The cast is round:** each person's picture in a circle (a `MaskGroup` with a circle mask)
  with a white ring when focused, the name and role under it.
- `shared/quality.bs` ports the Apple TV's `Quality.badges` (with its tests), and
  `shared/titlepage.bs` makes the lines (genres, facts, names joined "A, B, and C"), with tests.
  New widget: `OutlinedBadge`.

- **The buttons** are the Apple TV's: Play (or Resume) as a white capsule with its words, then
  round icon buttons: from the beginning, watched (eye), Watchlist (bookmark) and the show. The
  focused one is white with black; while a round one has the focus, its name shows under the bar
  (Roku has no hover hints, so the name says what an icon does). `widgets/ButtonBar` replaces the
  one-row RowList of text buttons; the icons are white PNGs in `images/buttons`.

## Not yet

- The About / Details / Crew / Playback cards at the foot of the page are the next step.

## Logging

None: it's layout only.

## Checked, and what still needs a Roku

`npm run check` and `npm test` pass (14 new checks). In the community simulator against a test
Arc: Heat's page shows "R Crime · Drama · Action", the overview, "1995 · 2h 50m SD AAC 1.0",
Starring Al Pacino, Robert De Niro, and Val Kilmer and Director Michael Mann; the Resume capsule
and three round buttons, with "Play from the beginning" under the bar when that one is focused; below, Trailers &
Extras, Related and the round cast with the ring on the focused person. `MaskGroup` needs Roku OS
9 or later, which every supported Roku has; the round pictures still need checking on a TV.
