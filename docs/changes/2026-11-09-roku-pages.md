# Roku actor page, collection page, Settings and About

The sixth part of `docs/plans/apple-tv-look.md`. Following the Apple TV app (arc-apple
`PersonView`, `CollectionView`, `SettingsView`), the Roku app gets an actor page, a collection
page with the collection's overview, a Settings layout with the profile beside the list, and an
About page.

## What changed

**Actor page** (`PersonScreen`, from `GET /people/{id}`):
- **Header:** a round photo (initials when there's none), the name, and a line such as "Acting · 12
  titles in your libraries".
- **Rows:** Movies, then TV Shows, then Crew. Each is newest first, with no duplicates.
- **Moving along a row:** the backdrop changes to the focused title, and a line shows their part, e.g. "Heat (1995) · as Neil McCauley" or "· Director".
- **OK** opens the title.
- **Where it opens from:** a person opens it from the title page's cast row, from search, and from people in a grid. Before this, a person opened a plain grid.
- **Code:** the row building and the lines are in `shared/person.bs`, with unit tests (`testPerson`).

**Collection page:** it is the library grid with the collection's name as the heading. Its overview
is under the heading (two lines at most), and the posters move down to make room.

**Settings:**
- **Left:** the profile's coloured circle with its letter, the name, the server and the existing note.
- **Right:** the list of choices.
- **New row:** a last row, About, shows the app version.

**About** (`AboutScreen`):
- **Left:** the app icon, "Arc for Roku", the version, and the TMDB/TheTVDB credit.
- **Right:**
  - the app version;
  - from `/health`: the server's name, Arc version and API;
  - the address, and whether the connection is local or remote (`/auth/status`);
  - Open Source Licences: Arc for Roku is AGPL-3.0, and BrighterScript, the build tool, is MIT.

## Decisions

- On the actor page, Movies come before TV Shows and Crew comes last, as in the Apple TV app. The
  Apple TV app's biography is left out, because the API doesn't send one.
- The About credit is text, not the providers' logos, until the logo files are in (#64).
- On Roku OS before 11, the circle mask isn't supported, so photos there are square.

## Checks

- `npm run check`: the build is clean and the catalog is up to date, at 227 strings.
- `npm test`: all tests pass, including `testPerson`.
- I went through it in the brs-cli simulator against a scratch Arc with the test library:
  - **Actor page:** opened from The Matrix's cast. It showed the name, "1 title in your libraries", "The Matrix (1999) · as Neo", and the backdrop.
  - **Collection page:** the Blade Runner Collection, with its overview above the grid.
  - **Settings:** the profile's circle with its letter.
  - **About:** all rows filled.
- The simulator doesn't draw the circle mask or MarkupGrid focus rings, so neither has been checked there. Nothing has been checked on a Roku device.

## Logging

Nothing new is logged. API failures go through `callApi`, which already logs them. A page that
fails to load says so on screen.
