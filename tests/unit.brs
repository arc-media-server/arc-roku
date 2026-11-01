' Unit tests for the app's shared logic, run with brs-cli (BrightScript Simulation Engine) by
' scripts/test.mjs. Each check prints "ok" or "FAIL <what>"; the script fails on any FAIL.

sub Main()
    m.failures = 0
    testHttp()
    testFormat()
    testCaps()
    testHome()
    testBif()
    if m.failures = 0 then print "ALL PASSED" else print "FAILURES: "; m.failures
end sub

sub check(ok as boolean, what as string)
    if ok
        print "ok   "; what
    else
        print "FAIL "; what
        m.failures = m.failures + 1
    end if
end sub

sub eq(got as dynamic, want as dynamic, what as string)
    check(got = want, what + " (got " + FormatJson(got) + ", want " + FormatJson(want) + ")")
end sub

sub testHttp()
    eq(apiPath("/items/1"), "/api/v1/items/1", "apiPath adds /api/v1")
    eq(apiPath("/api/items/1/images/primary?v=2"), "/api/v1/items/1/images/primary?v=2", "apiPath moves Arc links under v1")
    eq(apiPath("/api/v1/items/1"), "/api/v1/items/1", "apiPath leaves v1 alone")
    eq(absoluteUrl("http://arc:8099/", "/api/items/1"), "http://arc:8099/api/v1/items/1", "absoluteUrl")
    eq(absoluteUrl("http://arc:8099", "https://image.tmdb.org/x.jpg"), "https://image.tmdb.org/x.jpg", "absoluteUrl keeps full URLs")
    eq(normaliseServer("192.168.1.20"), "http://192.168.1.20:8099", "normaliseServer adds scheme and port")
    eq(normaliseServer(" arc.local:9000/ "), "http://arc.local:9000", "normaliseServer keeps a port")
    eq(normaliseServer("https://arc.example.com"), "https://arc.example.com", "normaliseServer leaves https alone")
    eq(queryString({ sort: "added", library_id: 3, limit: 24, unwatched: true, genre: "" }), "?library_id=3&limit=24&sort=added&unwatched=1", "queryString sorts and drops empties")
end sub

sub testFormat()
    eq(formatRuntime(95), "1h 35m", "formatRuntime hours and minutes")
    eq(formatRuntime(42), "42m", "formatRuntime minutes")
    eq(formatRuntime(120), "2h", "formatRuntime whole hours")
    eq(formatClock(3725000), "1:02:05", "formatClock with hours")
    eq(formatClock(65000), "1:05", "formatClock minutes")
    ep = { kind: "episode", season_number: 1, episode_number: 4, title: "Shindig", user_data: { position_ms: 600000, played: false } }
    eq(episodeCode(ep), "S1 E4", "episodeCode")
    eq(playLabel(ep), "Resume S1 E4", "playLabel resumes an episode")
    movie = { kind: "movie", year: 1999, runtime_min: 136, content_rating: "15", genres: ["Action", "Science Fiction", "Thriller"], user_data: { played: false } }
    eq(playLabel(movie), "Play", "playLabel plays a movie")
    movie.user_data.position_ms = 754000
    eq(playLabel(movie), "Resume from 12:34", "playLabel resumes a movie")
    eq(metaLine(movie), "1999 · 15 · 2h 16m · Action · Science Fiction", "metaLine")
    movie.user_data.played = true
    eq(resumeMs(movie), 0, "a watched title doesn't resume")
end sub

sub testCaps()
    video = { h264: true, hevc: true, hevc10: true, vp9: false }
    audio = { aac: true, mp3: true, ac3: true, eac3: true, flac: true }
    pass = { ac3: true, eac3: true, dts: true }
    display = { Hdr10: true, HLG: false, DolbyVision: true }
    c = buildCaps(video, audio, pass, display, 2160, 6)
    eq(c.video.Join(","), "h264,hevc", "caps video")
    eq(c.audio.Join(","), "aac,mp3,ac3,eac3,flac", "caps audio")
    eq(c.audio_passthrough.Join(","), "ac3,eac3,dts", "caps passthrough")
    eq(c.hdr_formats.Join(","), "hdr10,dolby_vision", "caps HDR")
    eq(c.max_bit_depth, 10, "caps 10-bit with HEVC Main 10")
    eq(c.max_height, 2160, "caps height")
    check(c.dolby_vision_profiles <> invalid, "caps Dolby Vision profiles")
    sdr = buildCaps({ h264: true }, {}, {}, {}, 1080, 2)
    eq(sdr.audio.Join(","), "aac", "caps always include AAC")
    eq(sdr.hdr_formats.Count(), 0, "caps SDR only")
    eq(sdr.max_bit_depth, 8, "caps 8-bit without HEVC")
    eq(modeHeight("2160p60b10"), 2160, "modeHeight 4K")
    eq(modeHeight("720p"), 720, "modeHeight 720p")
    eq(outputChannels("5.1 surround"), 6, "outputChannels surround")
    eq(outputChannels("Stereo"), 2, "outputChannels stereo")
end sub

sub testHome()
    libs = [{ id: 1, name: "Movies", kind: "movies" }, { id: 2, name: "TV", kind: "shows" }, { id: 3, name: "Home Videos", kind: "videos" }]
    prefs = { library_order: [2, 1], watchlist_position: 1, home: [
        { id: "recent:1", hidden: true },
        { id: "custom:a", title: "Unwatched 90s", filter: { library_id: 1, decade: "1990", unwatched: true } },
        { id: "collection:abc", title: "Toy Story" }
    ] }
    rows = resolveHomeRows(prefs, libs, invalid)
    ids = []
    for each r in rows
        ids.Push(r.id)
    end for
    eq(ids.Join(","), "continue,recent:2,watchlist,custom:a,recent:3,collection:abc", "home rows in the profile's order")
    eq(rows[0].path, "/home/continue?with_up_next=1", "continue carries Up Next")
    eq(rows[1].shape, "recent", "a TV library's recent row")
    eq(rows[1].title, "Recently Added in TV", "recent row title")
    eq(rows[3].path, "/items?decade=1990&kind=movie&library_id=1&limit=24&unwatched=1", "custom row query")
    eq(rows[4].style, "thumb", "home videos use thumbnails")
    eq(rows[5].path, "/collections/abc", "collection row")
    split = resolveHomeRows({ split_up_next: true }, [], invalid)
    eq(split[0].path + " " + split[1].id, "/home/continue next-up", "split Up Next")
    dt = CreateObject("roDateTime")
    dt.FromISO8601String("2026-10-15T12:00:00Z")
    eq(seasonalPick(dt).title, "Horror for Halloween", "seasonal row in October")
    dt.FromISO8601String("2026-06-15T12:00:00Z")
    check(seasonalPick(dt) = invalid, "no seasonal row in June")
    cards = rowItems("recent", [{ type: "season", item: { id: "s" }, season_number: 2, episodes: 3 }, { type: "series", item: { id: "t" } }])
    eq(cards[0].key + " " + cards[0].season.ToStr() + " " + cards[1].key, "season:s 2 series:t", "recent cards")
end sub

sub testBif()
    ' A two-thumbnail BIF file, built by hand: header, index, then two "JPEGs".
    b = CreateObject("roByteArray")
    for each x in [&h89, &h42, &h49, &h46, &h0d, &h0a, &h1a, &h0a]
        b.Push(x)
    end for
    pushLE(b, 0) ' version
    pushLE(b, 2) ' count
    pushLE(b, 10000) ' interval
    while b.Count() < 64
        b.Push(0)
    end while
    first = 64 + 8 * 3
    pushLE(b, 0)
    pushLE(b, first)
    pushLE(b, 1)
    pushLE(b, first + 3)
    pushLE(b, &hFFFFFFFF)
    pushLE(b, first + 7)
    for each x in [1, 2, 3, 4, 5, 6, 7]
        b.Push(x)
    end for
    b.WriteFile("tmp:/test.bif")
    bif = bifIndex("tmp:/test.bif")
    check(bif <> invalid, "bifIndex reads the header")
    eq(bif.count, 2, "bif count")
    eq(bif.interval, 10000, "bif interval")
    path = bifThumb(bif, 14000)
    eq(path, "tmp:/arc-thumb-1.jpg", "bifThumb picks the nearest")
    t = CreateObject("roByteArray")
    t.ReadFile(path)
    eq(t.Count(), 4, "bifThumb writes that thumbnail's bytes")
    check(bifIndex("tmp:/nothing.bif") = invalid, "bifIndex refuses a missing file")
end sub

sub pushLE(b as object, n as dynamic)
    v = n
    for i = 0 to 3
        b.Push(v mod 256)
        v = Int(v / 256)
    end for
end sub
