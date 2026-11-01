# Roku: libraries, search, collections, folders, watchlist and playlists (1 November 2026)

## What changed

- **Left on Home** (from the first card of a row) opens the list of places, as the other apps' side
  rail: Search, the libraries in the profile's order with the Watchlist where the profile put it,
  and Playlists. It reuses the player's options panel, on the left.
- **One grid screen** shows every list of titles (`source/shared/browse.bs` says what each asks Arc
  for): a library's titles 60 at a time as the focus nears the end, its collections, its folders
  (Other videos libraries), a collection, the Watchlist, Playlists and a playlist, and a person's
  titles. OK opens a title (an episode opens its show on that episode) or the next grid; Play plays
  a film or episode.
- **Sort and filter** (* in a library), with the web's names: show Titles, Collections or Folders;
  sort by title, date added, last watched, release date, year, rating, length or shuffle; the order;
  unwatched only; genre, decade and resolution from the library's facets. The choice is shown
  under the library's name.
- **Search** with Roku's on-screen keyboard, searching half a second after the last letter: titles,
  episodes, collections and people (a person opens their titles).

## Decisions

- The sort and filters last while the grid is open; the web keeps them per library in the
  browser, and the Roku app may do the same later if it's missed.
- Library tabs (Recommended, Collections, Folders) are a "Show" choice in the * panel instead of a
  tab row: Home already has the recommended rows, and the simulator can't draw horizontal button
  groups to check a tab row.

## Logging

Failed calls are logged by the API task (method, path without its query, status); nothing new.

## Checked, and what still needs a Roku

Unit tests for each grid's request and cards, the sort summary and search rows. In the simulator
against a test Arc: the list of places, the Home Videos library sorted by date added, its folders,
search ("bl" found both Blade Runners and the collection) and opening the collection. Not checked
on a Roku: speed of long libraries (paging), and the keyboard on a real remote.
