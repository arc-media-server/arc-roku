sub testLaunchProfile()
    alex = { id: "a" }
    jordan = { id: "b" }
    status = { profile: alex, profiles: [alex, jordan] }
    check(launchProfile(status, "", true) = invalid, "cold launch shows picker")
    eq(launchProfile(status, "b", false).id, "a", "resume keeps profile")
    eq(launchProfile(status, "b", true).id, "b", "automatic sign-in can switch profile")
    jordan.has_pin = true
    check(launchProfile(status, "b", true) = invalid, "PIN opens picker")
    check(launchProfile(status, "missing", true) = invalid, "deleted profile opens picker")
    status.profiles = [alex]
    eq(launchProfile(status, "", true).id, "a", "single unlocked profile stays selected")
    link = rokuDeepLink({ ContentId: "film:7", MediaType: "Movie", ProfileId: "a" })
    check(link.play and link.id = "film:7" and link.profileId = "a", "movie launch accepts Roku keys and keeps the profile hint")
    film = { id: "film:7", kind: "movie", user_data: { position_ms: 18000 } }
    check(matchesRokuPlaybackLink(link, film) and resumeMs(film) = 18000, "movie launch uses the server bookmark")
    check(not matchesRokuPlaybackLink(link, { id: "film:7", kind: "episode" }), "mismatched item type cannot play")
    film.available = false
    check(not matchesRokuPlaybackLink(link, film), "unavailable titles cannot play")
    check(rokuDeepLink({ contentId: "ep:1", mediaType: "episode" }).play, "episode opens playback")
    check(not rokuDeepLink({ contentId: "show:1" }).play, "content-only links still open details")
    check(rokuDeepLink({ contentId: "film:7", mediaType: "unknown" }) = invalid, "unsupported media type is ignored")
    check(rokuDeepLink({ contentId: 21, mediaType: "movie" }) = invalid, "invalid identifier is ignored")
end sub
