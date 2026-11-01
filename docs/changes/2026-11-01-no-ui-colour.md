# No UI colour: white and black instead of teal

The owner dropped a UI accent colour across Arc's apps (1 November, arc-media-server#80). The
progress bars, the Up Next heading, the sign-in code, the focused option in Settings and the
player's panel, the spinner and the watched tick (now a white disc with a black tick) are white.
Arc's teal stays in the app icon and splash (the logo).

Checks: `npm run check` (no diagnostics, strings up to date) and `npm test`. Not looked at on a
Roku.

Logging: none (colours only).
