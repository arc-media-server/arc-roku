# Roku device linking and profile PIN entry

Device linking follows Arc for Android TV. It shows the numbered steps and
controls on the left, with four code tiles, approval status, and the server
address on the right.

Locked profiles use Arc's own PIN screen with the profile avatar, four masked
slots, and a D-pad keypad. The fourth digit submits the PIN. Delete removes the
last digit, and Back returns to the picker. A rejected PIN clears the slots and
shows feedback on the same screen so it can be re-entered.

## Checks

- `npm run check`, `npm test`, `npm run build`, and `git diff --check` passed.
  The sideload ZIP contains `manifest` at its root.
- Walked code renewal and approval, profile selection, Back, masked entry,
  Delete, rejection and retry through Home in brs-engine with a scratch server.
  A physical Roku was outside these checks.

[Device linking](../screenshots/sign-in.jpg) ·
[Masked PIN entry](2026-11-26-device-linking-and-profile-pin/pin.jpg) ·
[Wrong PIN feedback](2026-11-26-device-linking-and-profile-pin/pin-wrong.jpg)

## Logging

Linking and PIN checks use the existing request logs. PIN values and poll
identifiers stay out of the app log.
