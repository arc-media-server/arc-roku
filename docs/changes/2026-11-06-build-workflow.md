# Builds on GitHub, on request

`.github/workflows/build.yml` builds the sideload zip on GitHub, so a build doesn't need a computer
or an agent session.

- It runs only when asked: from the Actions tab (Run workflow, on any branch) or for a push whose
  commit message contains `[build]`. Other pushes start nothing, to save Actions minutes. Apple's
  workflow (arc-apple) works the same way.
- The steps are the ones a PR needs: `npm ci`, `npm run check`, `npm test`, then `npm run build`.
- The run number becomes the manifest's `build_version`, so the Roku shows which build it is
  (0.1.N).
- The zip is attached to the run as `arc-roku-<run>` for 30 days. It's installed from the Roku's
  developer page (Development Application Installer) as before.

No signing is involved: a sideloaded developer app isn't signed, and packaging for the Roku
Channel Store remains a separate step.
