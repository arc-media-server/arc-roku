# Fix the Roku profile PIN prompt

Selecting a PIN-protected profile crashed before Roku could display the keypad.
Arc opened a `StandardPinPadDialog` but tried to set `pinLength` on the legacy
`pinPad` member. The standard dialog exposes the input through
`textEditBox`. It now limits the field to four digits and masks the entry.
[Roku StandardPinPadDialog reference](https://developer.roku.com/dev/docs/standard-pinpad-dialog)

The device stays linked. Arc still sends the PIN to the existing profile
endpoint for validation.

## Checks

- `npm run check`, `npm test`, and `npm run build` passed.
- Reproduced the original crash with a PIN-protected fixture profile in brs-engine.
  The patched package displayed the keypad, masked the PIN, and handled Back and
  a rejected PIN. The server accepted the correct PIN and the app switched to Home.
- Physical Roku hardware remains unchecked.

## Logging

No new log events. PINs remain excluded from request diagnostics.
