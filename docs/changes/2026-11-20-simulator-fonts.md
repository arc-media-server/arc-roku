# Large text drawn with resized system fonts

## What changed

Four labels used a font file URI with a custom size: the sign-in code (`font:SystemFontFile`, 140),
a person's initials (`font:BoldSystemFontFile`, 84), the profile picker's letter (96) and the
player's subtitle lines. They now use a system font (`font:LargeSystemFont`,
`font:LargeBoldSystemFont`, `font:MediumSystemFont`) and set its `size` in `init()`, which Roku
documents for system fonts.

## Why

The owner tried the sideload build in the BrightScript simulator and the sign-in screen showed
everything except the code. brs-engine doesn't resolve the `font:…FontFile` URIs, so those labels
drew nothing (the code was being fetched; the "Waiting for the code to be approved" note only
appears once one arrives). The new form draws in the simulator and is standard on a real Roku.

## Checks

- `npm run check`: 251 strings, catalog up to date.
- `npm test`: passed.
- `npm run build`: packaged.
- Simulator: a test scene with the old and new labels side by side; the old one drew nothing,
  the new code (140) and letter (96) drew at size. The full sign-in walk wasn't repeated
  because the simulator wouldn't reuse its saved server.
- Real Roku: not checked. Worth a look that the code, initials, profile letters and subtitles
  look the same size as before.

## Logging

None: a layout change with no new failure paths.
