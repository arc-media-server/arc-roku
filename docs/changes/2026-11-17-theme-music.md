# Theme Music

Film and show pages play their `theme_url` once per visit when the profile's `theme_music` preference is on (the default). The existing Settings list includes **Theme Music**, after Skip Intros Automatically, matching Android #38. The preference is fetched through ApiTask and saved with the existing profile Settings PATCH.

The native Audio node shares the scene's authenticated HTTP agent. Only Arc's item-theme route, including the server's cache-version parameter, is accepted; external URLs and other routes cannot receive the sign-in through this feature. Episodes do not play themes, and errors leave the page silent.

## Decisions

Use the native Audio node at the viewer's existing volume. Roku's Audio node exposes mute but no independent gain, so this client stops immediately rather than reproducing Android's quiet fade. No device volume is changed. This is the platform departure from Android/Plex-style quiet page themes.

The tune stops when the page is hidden or removed, including film/trailer navigation. It never loops or restarts after returning from playback. Reusing a title page for a new id resets the visit and rejects late item/pref answers for the old id. An optional `liveTopics` observer follows profile/resync hints without depending on the live-update PR; local Settings and page loads work independently. Merge live updates first to get external preference hints.

## Checks and limits

Fresh checks on 18 November, each required command run once:
- `npm run check` passed: compiler and 238-string catalog current.
- `npm test` passed: 221 shared assertions plus production theme-callback lifecycle checks.
  Covered eligible kinds, default/off, cache versions, refused external/non-theme routes,
  live disable/no replay, stale responses, new-visit reset, hidden-page stop, unrelated/profile
  hints and native error cleanup. Callback checks use lightweight node stand-ins, not audio.
- Reused compiled staging for the actual community simulator v2.6.2. The Settings switch saved
  off/on through remote keys and scratch Arc; normal deep linking loaded the generated title.
  Two genuine 960x540 JPEGs are beside this note. Startup alone was directed to Settings.
- Included the same small catalog-generator correction as Roku #19: `--write` inside an XML
  comment is invalid XML. Omitting the flag from that comment lets the simulator load. No new
  dependencies, server work, repeated suites or unrelated investigations.
- Not tried on a real Roku/TV. Physical audio, authenticated native media delivery, codec,
  suspend/exit and physical remote acceptance remain unverified. Simulator UI is not proof of
  native audio output. No owner server/data/keys or hosted builds used; fixtures stopped.

## Logging

A failed native theme reports only `Arc: theme music unavailable`. The native error text is deliberately omitted because it can contain a media URL. No names, credentials or URLs are logged.
