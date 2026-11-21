# Releases from a one-click build

**What:** the Build workflow gains a release job (arc-media-server#488). Actions → Build → Run
workflow on `main` checks, tests and packages the sideload zip as before, adds `SHA256SUMS.txt`,
and publishes a pre-release `roku-build-<run>` with GitHub's generated notes. A `v*` tag makes a
normal release.

**Versions:** the manifest's major.minor plus the run number as the build (`0.1.57`); a `v*` tag
sets all three. Stamped in the run only. The zip is named with the version.

**Decisions:**
- Only a manual run on `main` or a `v*` tag releases; marked pushes and manual runs on other
  branches keep a run artifact only, so agents can't publish. Nothing runs on pull requests.
- `contents: write` only on the release job; a newer run never cancels one that's publishing.

**Checks:** `npm run check`, `npm test` and `npm run build` passed locally; the version step gave
`0.1.7` for a main build and `0.2.0` for a `v0.2.0` tag; the workflow parses as YAML. `actionlint`
wasn't run. The workflow hasn't run on GitHub: the owner does the first release.

**Logging:** nothing new in the app.
