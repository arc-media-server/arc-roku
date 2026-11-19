sub testMissingEpisodes()
    eq(seasonsPath("a/b", false), "/series/a%2Fb/seasons", "missing episodes opt-in")
    eq(seasonsPath("a/b", true), "/series/a%2Fb/seasons?missing=1", "missing episodes encoded API path")
    eq(missingEpisodesEntry(false).act, "showMissing", "show missing menu entry")
    eq(missingEpisodesEntry(true).act, "hideMissing", "hide missing menu entry")
    missing = { available: false, episode_number: 1, runtime_min: 20 }
    eq(seasonCardLine(missing, false), "E1 · 20m · Not on disk", "missing episode clearly labelled")
    eq(seasonOnDisk([missing]).Count(), 0, "missing-only season has no disk actions")
    eq(shuffledIds([missing]).Count(), 0, "missing episode never shuffled")
    row = seasonRows({ seasons: [{ season_number: 2, episodes: [missing] }] })
    eq(row.Count(), 1, "missing-only season retained")
end sub
