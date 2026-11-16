# Roku: jump to a letter in a library (15 November 2026)

## What changed

A library's grid sorted by **Title** now has **Jump to** in its * menu, after Sort by. It lists
**All titles**, then each letter that has titles, A to Z. Choosing a letter closes the menu onto
the grid starting at that letter, and "From M" is added to the line under the library's name.

This follows Arc's jump-to-letter contract (arc-media-server `docs/LIBRARY-NAVIGATION.md`, chosen
by the owner on 25 October and settled on #80):

- **A starting point, not a filter.** Scrolling carries on through the following letters, 60
  titles at a time as before. All titles goes back to the start.
- **Order:** with Z to A, the grid starts at the end of the letter. Changing the order keeps the
  letter.
- **Changing what's shown** (sort, Watched or a filter) starts the list from the top again, as the
  letters with titles change too.
- **Where it's offered:** only when sorted by Title, and not on Collections or Folders.
- **Numbers and symbols** (the web's "#") aren't a choice. They come first, so All titles covers
  them.
- **Letters come from Arc:** the first page of a title-sorted grid asks Arc for its letter counts
  (`letters=1`). A jump asks Arc to start at the letter (`jump=M`) and keeps Arc's actual `offset`,
  so later pages carry on from there.
- **Article rule:** letters follow Arc's own title order, which ignores a leading "The" or "A".

**Code:**
- `shared/browse.bs`: the letter in the query, `jump` and `letters` on the request, the page's
  offset and letters, `letterChoices` and "From %1" in the summary.
- `GridScreen`: the Jump to section, and paging from the jump's place (`m.base`).

## Decisions

- **A list in the * menu, not a rail beside the grid** (the web's A–Z rail). The Roku remote has
  no pointer, and the menu already holds sort and filters. A rail beside the grid would need its
  own focus column next to the sidebar.

## Logging

Nothing new. A failed page is still logged once by `ApiTask` (method, path without the query,
status).

## Checked, and what still needs a Roku

- `npm run check`: no diagnostics, and the catalog is up to date (230 strings, three new: Jump to,
  All titles, From %1).
- `npm test`: ALL PASSED, including 10 new browse checks and one updated:
  - the first page asking for letters, and later pages not;
  - jumping in both orders;
  - carrying on after a jump;
  - the summary;
  - the letters offered.
- **Community simulator (brs-cli) against a scratch Arc** built from arc-media-server main, with an
  Other videos library of 208 clips, 8 for each letter:
  - **The * menu** shows "Jump to · All titles" after Sort by.
  - **Jump to** lists All titles, then B to Z. There's no A, because Arc sorts "A Clip" under C.
  - **Choosing M:** the grid starts at "M Clip 1", and the summary reads "208 titles · Title · A to
    Z · From M".
  - **Scrolling past the first 60 from M** (the page ends at T Clip 4) loads T Clip 5 onwards.
  - **Z to A** kept "Jump to · All titles" in the menu.
- **Not checked in the simulator:** choosing All titles after a jump. That request is the
  ordinary first page, covered by the unit tests.
- **Not checked on a real Roku:** the menu's speed with a long letter list, and a large real
  library.
