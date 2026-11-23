# Public repository readiness

- Added the project copyright and AGPL-3.0-only identifier to LICENSE and preserved the full licence text.
- Explained how to install a release ZIP through Roku's developer page and how to build from a checkout.
- Documented public-repository handling in AGENTS.md, which CLAUDE.md imports.
- Disabled checkout credential persistence in Build. Packaging reads its version from the environment. Build continues to use manual dispatch and push events, with the write token scoped to the release job.
- Passed `npm run check`, `npm test`, and `npm run build`. Inspected the resulting ZIP, README image links, licence text, workflow events, token scope and shell syntax.
- No real Roku or live GitHub release was exercised. The app's runtime and logging are unchanged.
