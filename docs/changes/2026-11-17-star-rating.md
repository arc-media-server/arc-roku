# Star rating

A title's existing button bar now has **More** (⋯); the remote's * button on that bar opens the
same menu. **Rate…** opens the existing OptionsPanel as **Your Rating**, matching Android #34:
five stars down to half a star, current choice ticked and focused, and **Clear Rating** only
when rated. An unrated title starts at five stars. Back returns to the title buttons without
saving. Films, shows and episodes use the same flow; existing season/card menus stay intact.
Choosing the current rating does nothing.

The testable shared ratings helper formats stars and constructs the escaped rating request.
The API Task sends `PUT /api/v1/items/{id}/rating` with 1–10 half-star units; clearing sends zero.
The menu updates immediately and the page refreshes after success; failures restore the prior
rating and display Android's translated failure wording. No network calls run on the render
thread. No new screen, product decisions or settings were needed.

Validation (fresh checks, 18 November):
- `npm run check`, `npm test` and `npm run build` passed; `git diff --check` passed.
- The actual API Task stand-in verifies save/clear/refusal, escaped ids and Bearer auth. The
  actual title-menu callbacks verify current focus, same-value/no-request, cancellation,
  clear-to-zero, refusal rollback/focus/message, retry error clearing, success refresh and stale
  page responses. The stale retry-message regression failed before its one-line fix.
- The catalog generator previously emitted `--write` inside an XML comment, which is invalid
  XML and prevented the simulator loading. Removing those comment hyphens fixes generated output;
  Python's XML parser failed before and passes afterwards. No translation contents changed except
  the feature's new strings.
- Genuine community simulator v2.6.2, actual production DetailsScreen/OptionsPanel and API Task,
  with startup directed to a synthetic title in scratch Arc: saved 4.5 (API rating 9), cleared to
  zero, current rating tick/focus, unrated default five/no Clear and Back cancellation verified.
  Four 960×540 JPEGs are beside this note. Simulator fonts omit star glyphs; the numeric out-of-five
  labels remain visible. Real Roku fonts/rendering still need a device.
- No real TV, playback/audio/HDR, owner server/data/media/keys or hosted build used. The existing
  prepared compiler and dependencies were reused. Temporary scratch server/simulator stopped.

Logging: fixed “rating saved” / “rating not saved” outcome messages, plus the existing API Task
failure boundary. No credentials, names or full URLs are logged. Not tried on a TV; simulator
checks do not certify real Roku playback, audio or HDR. Latest main `bd92ebd` had no rating action.
