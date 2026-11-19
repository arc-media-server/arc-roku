sub testSpoilers()
    ep = {id:"ep",kind:"episode",overview:"SECRET",images:{primary:"/still",backdrop:"/backdrop",series_backdrop:"/show"},user_data:{}}
    check(spoilerEligible(ep), "unstarted episode eligible")
    check(not spoilerEligible({kind:"movie"}), "movie not concealed")
    check(not spoilerEligible({kind:"series"}), "series not concealed")
    check(not spoilerEligible({kind:"episode",user_data:{played:true}}), "watched revealed")
    check(not spoilerEligible({kind:"episode",user_data:{position_ms:1}}), "resumed revealed")
    safe = spoilerSafeItem(ep, true)
    eq(safe.overview, "", "description concealed")
    eq(safe.images.primary, "/show", "safe series art")
    eq(ep.images.primary, "/still", "source images unchanged")
    eq(ep.overview, "SECRET", "source description unchanged")
    eq(spoilerSafeItem(ep, false).overview, "SECRET", "disabled reveals")
    noArt = spoilerSafeItem({kind:"episode",images:{primary:"/still"}}, true)
    check(noArt.images.primary = invalid, "no fallback means placeholder")
    eq(safeEpisodeArt({images:{series_primary:"/poster"}}), "/poster", "series poster fallback")
    m.global = {}
    check(hideSpoilers(), "unknown preference concealed")
    m.global.hideSpoilers = false
    check(not hideSpoilers(), "loaded off preference")
end sub
