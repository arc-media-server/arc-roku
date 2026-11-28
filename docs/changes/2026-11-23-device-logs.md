# Send logs on Roku

Settings sends recent Arc events to the current server on request. Detailed logging captures debug
events for two hours. A bounded journal uses Roku’s cache filesystem and is cleared on sign-out or
server change. Roku has no reliable crash report callback for the app, so uploads are manual.

Checks: npm run check and npm test passed, including the BrightScript privacy projection.
The real Roku Settings screen, OS cache retention and hardware were outside this check.

Server dependency: [Arc Media Server #508](https://github.com/arc-media-server/arc-media-server/pull/508).
