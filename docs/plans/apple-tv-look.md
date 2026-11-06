# The Roku app in the Apple TV look (plan)

The Apple TV app is the design reference for Arc's TV apps (native tvOS, Apple's design). The
others copy it where their platform allows. This is what the Roku app needs to match it
(arc-apple's `docs/changes/2026-11-01-*.md` describe each piece), and how SceneGraph can do it.

## 1. Icon sidebar
- **Apple TV:** icons always visible down the left, the profile's picture at the top and a disc
  behind the place that's showing. Left (or Back on a place's first page) opens it: a tall panel
  slides in behind the icons, names fade in, and the page dims. Select opens a place and shuts it.
- **Roku now:** an options panel of places, opened with Left from Home only.
- **Roku plan:**
  - A `NavRail` component in `MainScene`: a column of icon Posters (white PNGs at 48 px, drawn
    once into `images/`) with the profile's initial on its colour at the top.
  - Opening it: a dark translucent Rectangle (Roku has no blur) animates from 120 to 400 px wide,
    and Labels fade in with an `Animation` on opacity.
  - Focus stays on the icons. Up/Down moves the highlight (white pill, black icon), and Select
    switches the screen stack's root.
  - Back from a place's first screen opens the rail. Back in the rail asks to leave, as now.

## 2. Home
- **Apple TV:** the hero describes the focused title, with no buttons. Continue Watching cards
  have a resume strip (play mark, a progress capsule, time left) and the show's logo on the art.
- **Roku now:** the hero matches already. Cards show a bar.
- **Roku plan:** `CardItem` gains the resume strip for wide cards: a shade Poster at the bottom,
  a play glyph, a 4 px white progress capsule and "12m left". Posters keep the thin bar. Names
  are centred under the art.

## 3. Library pages
- **Apple TV:** a library opens on Recommended (Arc's rows under the same hero) with pills
  Recommended / Browse / Collections (Folders for videos libraries). Sort and Filter sit beside
  the pills on Browse.
- **Roku now:** the grid, with "Show" in the * panel.
- **Roku plan:**
  - A `PillBar` (a horizontal row of `ActionButton`s in one rounded group; the selected pill white
    with black text) at the top of a new `LibraryScreen`.
  - Recommended reuses Home's hero and RowList with `GET /libraries/{id}/recommended`.
  - Browse and Collections reuse `GridScreen`'s content.
  - The pill bar fades when the focus is below the first row.
  - Up from the first row goes to the pills.
  - The richer filters (arc-media-server#347) go in Browse's Filter panel at the same time.

## 4. Title page
- **Apple TV:**
  - the hero: logo, a rating box, genres, overview, year, length and quality badges (4K, DV
    HDR10, DD+ 5.1, Atmos), with Starring and Director at the bottom right;
  - round icon buttons after Play;
  - below: seasons, Trailers & Extras, Related, Cast (round photos, actors only), Collections;
  - glass cards at the foot: About, Details, Crew, Playback.
- **Roku plan:**
  - The rating box is a Label inside a 2 px outlined rounded Rectangle (nine-patch).
  - Badges are outlined Labels in a LayoutGroup. A shared `quality.bs` ports ArcKit's
    `Quality.badges`, with the same tests.
  - Cast as round photos: a circular mask Poster (`maskUri` on Roku OS 11+; square with rounded
    corners before that).
  - "More Like This" becomes Related, and Crew moves to a card.
  - About / Details / Crew / Playback are focusable dark rounded panels in a RowList row of their
    own.

## 5. Player
- **Apple TV:** the title large at the bottom left (show and episode code above), a thin white
  timeline with a knob, the times beneath. Subtitles and Audio sit in a panel down the right-hand
  side.
- **Roku plan:** a custom transport over the Video node (its built-in trickplay bar hidden):
  Labels, a 4 px Rectangle timeline and a knob, BIF thumbnails above the knob while scrubbing. The
  options panel already sits on the right.

## Platform limits (logged on arc-media-server#80 when built)
- No blur on Roku: the glass becomes a dark translucent panel (black at about 70%). This is the
  same fallback as the LG C9.
- Fonts are Roku's system fonts unless a font file is added: check on a TV whether a bundled font
  (the Apple TV uses SF) is worth its size.
- Animations stay short (200 ms) for older Rokus.

## Order and checks
1. Sidebar, then Home cards, then library pages, then the title page, then the player. Each is its
   own PR with screenshots from the community simulator (brs-engine) against a test Arc.
2. `npm run check` and `npm test` for each, with new unit tests for the pure parts (quality
   badges, pill state, the resume strip's text).
3. The look on a real TV is marked (device) on the to-do list until someone has seen it.
