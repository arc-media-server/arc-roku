# Arc for Roku

The Roku app for [Arc Media Server](https://github.com/arc-media-server/arc-media-server).
BrightScript and SceneGraph, written in [BrighterScript](https://github.com/rokucommunity/brighterscript),
talking to Arc only through `/api/v1`.

**Status:** first slice, not yet run on a real Roku. It compiles cleanly, its unit tests pass, and
its sign-in, profile, Home and title screens have been walked through in a community simulator
against a test Arc. Video playback, trick-play thumbnails and how it looks on a TV still need a
real device (see `docs/changes/`).

## What it does

- Finds Arc on the home network (or takes an address), then signs in with a code you approve in
  Arc (Settings → Devices), so no password is typed on the TV.
- Profile picker with PIN pad, the same Home rows as Arc's other apps, title pages with seasons
  and episodes, watched and watchlist toggles, deep links (`contentId` = an Arc item id).
- A player with Arc's playback decision: it reports what the Roku can decode, plays the file
  directly when it can, falls back to a remux and then a conversion, saves progress every 10
  seconds and shows timeline thumbnails while scrubbing (Arc's BIF files).

## Build and test

Needs Node 20 or newer.

```sh
npm install
npm run check     # compile (no diagnostics allowed) and check the strings catalog
npm test          # unit tests of the shared code in brs-node, no device needed
npm run build     # out/arc-roku.zip, ready to sideload
```

All text the app shows goes through `tr()`; `node scripts/check-strings.mjs --write` regenerates
`src/locale/en_US/translations.ts` after adding strings.

## Simulator

Roku has no official emulator. [brs-engine](https://github.com/lvcabral/brs-engine)'s CLI runs the
built zip in a terminal (and as a desktop app with a picture), which is good enough to walk the
screens against a test Arc, not to judge playback or the final look:

```sh
npm run build
npx brs-cli -y out/arc-roku.zip  # -y keeps the sign-in between runs; arrows, Enter = OK,
                                 # Backspace = Back, * = options, Ctrl+S saves a snapshot (-s file)
```

Known simulator differences: horizontal button groups stack vertically, system fonts fall back,
and posters don't share the scene's sign-in header (the app sets it on each one, which a real
Roku also accepts).

## Install on a Roku

1. On the Roku remote press Home ×3, Up ×2, Right, Left, Right, Left, Right to open developer
   settings, turn developer mode on and choose a password. The Roku restarts.
2. Create `.env` in this folder (it is never committed):
   ```
   ROKU_HOST=192.168.1.50
   ROKU_PASSWORD=the password from step 1
   ```
3. `npm run sideload` builds and installs it; it appears as "dev" Arc on the Home screen.
4. Debug output: `telnet <roku ip> 8085`. Lines the app prints start with `Arc:`.

## Layout

```
src/manifest                 app title, version, icons, FHD resolution
src/source/main.bs           starts the scene, passes deep links on
src/source/shared/           pure helpers: HTTP, settings, formatting, device caps, Home rows, cards, BIF
src/components/MainScene     the screen stack and global sign-in state
src/components/screens/      Server, SignIn, Profiles, Home, Details, Player, Problem
src/components/tasks/        ApiTask, DiscoverTask, DownloadTask (network work off the render thread)
src/components/widgets/      CardItem, ProfileItem
src/locale/en_US/            strings catalog (generated, checked)
tests/unit.brs               unit tests for src/source/shared
```

## Licence

AGPL-3.0-only, copyright The Arc Media Server Authors.
