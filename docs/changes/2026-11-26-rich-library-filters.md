# Rich library filters on Roku

Open a library’s **Browse** tab, press **\***, and choose **Filters**. The panel has
Android TV’s Watch Status, Genre, Decade, Quality, HDR, Video Format, Audio Format,
and Audio Channels choices. Unwatched, Watched, and Not Started share one selector.
The technical filters appear when the library has multiple choices, or when a choice
is already active. The server supplies the available values and title counts.

Filters combine and stay applied when jumping to a letter or paging through results.
The options menu shows the active filter count, and Browse lists the selections
above the grid. **Clear Filters** restores all titles in the current sort and direction.
Like the existing Roku Browse filters, selections last while the grid is open.

## Decisions

[Plex’s big-screen apps](https://support.plex.tv/articles/navigating-the-big-screen-apps/)
offer sort and filter controls in the library. Arc keeps those controls in Roku’s
existing star-button menu, with the available criteria matching Arc for Android TV.
The existing versioned facets and items endpoints handle filtering and paging. This
requires no server change.

The README explains which ZIP to load when the BrightScript Simulator reports a
missing manifest. The built ZIP already includes the manifest at its root.

## Checks

- `npm run check`, `npm test`, and `npm run build` passed.
- Unit coverage includes mutually exclusive watch status, facet availability, reset,
  filtered pagination, and readable labels.
- The brs-engine remote walkthrough exercised Browse, the filter menu, combined HDR10+
  and Watched results, the empty state, and clearing filters against a local API
  fixture. [Simulator screenshots](2026-11-26-rich-library-filters/)
- Physical Roku and playback checks remain open.

## Logging

The existing API task logs failed requests once and omits query values. Filter
choices and empty result sets add no log events.
