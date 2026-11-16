# Roku: episodes outside the episode order (15 November 2026)

## What changed

A show's page used to show only the seasons of its episode order. Episodes the profile has but that
order doesn't include (Arc's `unplaced`, in `GET /series/{id}/seasons`) didn't appear anywhere, so
they couldn't be played from the Roku. That broke Arc's rule that nothing silently disappears.

- **Title page:** after the seasons there is now a **Not in This Order** row, with the web's name.
  Its cards show the episode's length but no "E4", because the order gives them no number. Select
  plays one, as in any season row.
- **Player:** an episode from that row now has an **Episodes** tab, listing the other episodes
  outside the order. Their tiles have no "S1 · E8" code.
- **Play, Resume and Up Next** still follow the order's seasons only, as on the web.
- **Code:** the rows are built in `shared/seasons.bs` (`seasonRows`, `seasonOf`,
  `seasonCardLine`), which the title page and the player share. `testSeasons` in
  `tests/unit.brs` covers it.

## Decisions

- **No explanation line.** The web shows a sentence under its "Not in This Order" tab. On the Roku
  the row's name stands alone, as the season rows' names do. A title page row has no room for a
  paragraph.

## Logging

Nothing new. A failed seasons load is logged by `ApiTask`, as before.

## Checked, and what still needs a Roku

- `npm run check`: no diagnostics, and the catalog is up to date (228 strings).
- `npm test`: ALL PASSED, including 16 new `testSeasons` checks.
- **Community simulator (brs-cli) against a scratch Arc** built from arc-media-server main, with
  the generated test library. The scratch show is given a custom episode order without two of its
  three episodes:
  - **The show's page:** Season 1 (Episode 1, "E1"), then Not in This Order (Episodes 2 and 3,
    no number). Play stays "Play S1 E1".
  - **Same show on main:** only Season 1 appears, so Episodes 2 and 3 can't be reached.
  - **Selecting Episode 3** opens the player. Its tabs are Info and Episodes, and the Episodes card
    lists Episodes 2 and 3.
  - **Before this change** there was no Episodes tab for such an episode.
- **Not checked on a real Roku:** how it looks on a TV and video playing. The simulator can't
  decode video.
