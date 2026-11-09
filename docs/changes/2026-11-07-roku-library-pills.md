# Roku library pages: Recommended, Browse and Collections pills (7 November 2026)

The third part of `docs/plans/apple-tv-look.md`: a library opens as it does on the Apple TV.

## What changed

- **A library opens on Recommended**, with pills at the top: Recommended, Browse and Collections.
  An Other videos library, which has no Recommended, has Browse, Collections and Folders.
  - Up from the page's top row goes to the pills. Left and Right move along them, and Select
    shows that page. The chosen pill is white; while the bar has the focus, the focused pill is
    white and the chosen one light grey.
  - Left from the first pill opens the sidebar, and Back opens it too (it's a place's first
    screen).
- **Recommended** is Home's hero and rows for the library (`GET /libraries/{id}/recommended`):
  HomeScreen with a `library` param, the hero a little lower and without the overview, as on the
  Apple TV. The row titles follow the web's and the Apple TV's (`shared/recommended.bs`, with unit
  tests): "Top Rated Shows" in a shows library, "Top Movies by" a director, "with" an actor, and
  Arc's own title for a kind of row this app doesn't know yet.
- **Browse, Collections and Folders** are the existing grid (GridScreen) inside the page. The
  pills replace its title and the "Show" choice in the * menu; sort and filters stay in the *
  menu.
- New widgets: `PillBar`, and `Capsule` (a rounded fill of any width from two caps and a
  rectangle, as Roku's Rectangle has no rounded corners).
- The sidebar's libraries open this page (`go: "library"`) instead of the grid.

## Decisions

- **Pills change on Select**, as the Apple TV app's do, not on focus: each page loads from Arc,
  so moving along the bar doesn't start loads.
- Sort and Filter stay in the * menu for now, rather than buttons beside the pills; the richer
  filters (arc-media-server#347) will come with buttons when they're added.

## Logging

Nothing new: pages load through the API task, which logs failed calls. A failed Recommended
load says so on the page.

## Checked, and what still needs a Roku

`npm run check` and `npm test` pass (ten new checks for the row titles and rows). In the
community simulator against a test Arc: Movies opens on Recommended (Heat's hero, Continue
Watching and Recently Released); Up to the pills, Right highlights Browse while Recommended
shows light grey; Select shows the grid ("7 titles · Title · A to Z"); Up and Right to
Collections shows the Blade Runner collection. The simulator cuts a one-title row's name short
("Continue …"); a real Roku should show it in full, which still needs checking on a TV.
