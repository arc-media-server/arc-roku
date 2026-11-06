# Roku sidebar in the Apple TV style (6 November 2026)

The first part of `docs/plans/apple-tv-look.md`: the Apple TV app is the design reference for
Arc's TV apps, and this brings its sidebar to Roku.

## What changed

- **A rail down the left of every screen** (`widgets/NavRail`): the profile's initial on its colour,
  then Search, Home, Watchlist, each library (an icon for its kind), Playlists and Settings. A grey
  disc sits behind the place that's showing.
- **Left opens it**, and so does Back on a place's first screen. It opens over a dimmed page, with
  the names fading in and a white pill (black icon and name) behind the highlighted row. Select
  opens that place as the first screen, Right or Back closes it, and Select on the profile goes
  to the profile picker. Back in the open rail leaves the app, as Back on Home did.
- Home's own list of places (Left on Home) is gone; the rail replaces it everywhere.
- The list of places is built by `shared/places.bs` (`navPlaces`, `libraryIcon`, `placeIndex`),
  with unit tests.

## Decisions

- No blur on Roku: the open rail is a dark panel (92% opaque) over the page dimmed by 60%, the same
  fallback the LG app uses on older TVs.
- The icons are white PNGs drawn once (48 px); the highlighted one is tinted black with
  `blendColor`, so there's one image per icon.

## Logging

Nothing new: opening a place goes through the same screen stack as before, and failed calls are
logged by the API task.

## Checked, and what still needs a Roku

`npm run check` and `npm test` pass. In the community simulator against a test Arc: Home with the
rail shut and open, Movies picked from the rail (the disc moves to Movies), Back on Movies opens the
rail again, and Right then Select in the grid opens a title. The simulator doesn't show a library
grid's focus ring (it doesn't report the item's focus change); the focus itself moves. Speed of the
animation and the look on a TV still need a real Roku.
