
' Pre-roll: exclusions and tolerant ordered lists.
sub testPreroll()
    check(prerollEnabled({}), "pre-roll for a new queue/film")
    check(not prerollEnabled({ startMs: 1 }), "no pre-roll on resume")
    check(not prerollEnabled({ preroll: false }), "no pre-roll on advancement")
    check(not prerollEnabled({ together: true }), "no pre-roll in Watch Together")
    check(not prerollEnabled({ extra: {} }), "no pre-roll for extras")
    eq(prerollClips(invalid).Count(), 0, "absent list is empty")
    clips = prerollClips([{ url: "/api/preroll/0", extra: true }, { title: "missing" }, { url: "/api/preroll/1" }])
    eq(clips.Count(), 2, "ignore malformed clips")
    eq(clips[0].url, "/api/preroll/0", "first clip stays first")
    eq(clips[1].url, "/api/preroll/1", "second clip stays second")
end sub
