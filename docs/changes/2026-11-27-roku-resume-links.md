# Resume from Roku movie and episode links

Roku movie and episode links now open playback at the active Arc profile's server bookmark. Arc validates the item under the signed-in profile. A profile hint only matches an authenticated profile, and Arc still uses its ordinary sign-in and profile picker when required. Invalid or unavailable titles leave the current screen in place. Old content-only links still open details.

This implements the movie and episode launch behavior Roku expects for Continue Watching. Listing titles in Roku's system row is a separate partner integration that requires Roku Search, eligibility approval and test tokens. The channel sends no library or viewing data to Roku.

Checks include BrightScript validation, the test suite, and a scratch-server simulator launch. Roku's production Continue Watching row and hardware playback require separate verification.
