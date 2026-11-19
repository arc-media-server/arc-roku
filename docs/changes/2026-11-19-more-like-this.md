# Roku: "Related" row renamed to "More Like This"

A title page's row of similar titles is now called **More Like This**, matching the web, Android
and LG/Samsung apps, per the owner decision on arc-media-server#480 (Plex's name too).

Only the label changed (`tr("More Like This")` in `DetailsScreen.bs`, the regenerated catalog and
two comments). The row's content, order and API call (`/items/{id}/similar`) are unchanged.

## Checks

- `npm run check`: passed (BrighterScript and the generated catalog).
- `npm test`: passed.

## Logging

None: a label change, with no new requests or failure paths.
