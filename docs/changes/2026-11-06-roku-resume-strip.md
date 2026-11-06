# Roku cards: the resume strip (6 November 2026)

The second part of `docs/plans/apple-tv-look.md`: Home's cards as on the Apple TV.

## What changed

- **Wide cards part-way through** (Continue Watching, episodes) show a resume strip along the
  bottom of the picture: a soft shade, a play mark, a short white bar of how far through, and the
  minutes left ("18m"). Posters keep their thin bar across the bottom.
- **Names are centred** under the art, as on the Apple TV.
- `minutesLeft` (rounded up, at least a minute) and `cardStripText` are in `shared/format.bs`, with
  unit tests; cards carry `leftMin`.

## Logging

None: it's drawing only.

## Checked, and what still needs a Roku

`npm run check` and `npm test` pass. In the community simulator against a test Arc with Heat and
a Firefly episode part-watched: Continue Watching shows both strips (104m and 18m left), and the
posters on the rows below are unchanged. The look on a TV (text size, the shade on bright
pictures) still needs a real Roku.
