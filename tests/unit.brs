' Unit tests for the app's shared logic, run with brs-cli (BrightScript Simulation Engine) by
' scripts/test.mjs. Each check prints "ok" or "FAIL <what>"; the script fails on any FAIL.

sub Main()
    m.failures = 0
    testHttp()
    testFormat()
    testCaps()
    testHome()
    testBif()
    testTracks()
    testBrowse()
    testPlaces()
    testRecommended()
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
    eq(minutesLeft(754000, 8160000), 124, "minutesLeft rounds up")
    eq(minutesLeft(8150000, 8160000), 1, "minutesLeft is at least a minute")
    eq(minutesLeft(0, 8160000), 0, "minutesLeft for a title not started")
    eq(minutesLeft(9000000, 8160000), 0, "minutesLeft past the end")
    eq(cardStripText(12), "12m", "cardStripText")
    eq(cardStripText(0), "", "cardStripText without a time")
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

sub testTracks()
    eq(langKey("eng"), "en", "langKey maps three letters")
    eq(langKey("pt-BR"), "pt", "langKey drops the region")
    check(sameLanguage("ger", "de"), "sameLanguage across code styles")
    check(not sameLanguage(invalid, "en"), "sameLanguage needs both")
    eq(languageName("fre"), "French", "languageName")
    eq(languageName("und"), "", "languageName undetermined")
    eq(channelsName(6), "5.1", "channelsName 5.1")
    eq(audioDetail({ codec: "eac3", channels: 6, title: "Commentary" }), "Dolby Digital Plus · 5.1 · Commentary", "audioDetail")
    eq(subtitleDetail({ language: "en", title: "SDH", forced: false, hearing_impaired: true }), "SDH", "subtitleDetail drops a title that repeats SDH")

    tracks = [
        { id: "a", language: "en", forced: true },
        { id: "b", language: "en", hearing_impaired: true },
        { id: "c", language: "en" },
        { id: "d", language: "fr" },
        { id: "e", language: "en", image: true }
    ]
    eq(chooseSubtitle(tracks, "en", "fr", "").id, "c", "chooseSubtitle prefers a plain track")
    eq(chooseSubtitle(tracks, "en", "en", "foreign").id, "a", "chooseSubtitle foreign mode falls back to forced in the audio's language")
    check(chooseSubtitle(tracks, "fr", "de", "manual") = invalid, "chooseSubtitle manual picks nothing without forced in that language")
    check(chooseSubtitle([{ id: "x", language: "en", image: true }], "en", "", "") = invalid, "chooseSubtitle skips picture subtitles")
    eq(rememberedSubtitleLanguage({ language: "de" }, ""), "de", "remember a picked language")
    eq(rememberedSubtitleLanguage(invalid, ""), "", "remember off in last-used mode")
    check(rememberedSubtitleLanguage(invalid, "always") = invalid, "off doesn't change an always mode")

    vtt = "WEBVTT" + Chr(13) + Chr(10) + Chr(10) + "1" + Chr(10) + "00:00:01.500 --> 00:00:03.000 align:start" + Chr(10) + "<i>Hello</i> &amp; welcome" + Chr(10) + "second line" + Chr(10) + Chr(10) + "00:02.000 --> 00:04.000" + Chr(10) + "<v Mal>Overlap" + Chr(10)
    cues = parseVtt(vtt)
    eq(cues.Count(), 2, "parseVtt finds the cues")
    eq(cues[0].startMs, 1500, "parseVtt start")
    eq(cues[0].endMs, 3000, "parseVtt end ignores settings")
    eq(cues[1].startMs, 2000, "parseVtt minutes:seconds times")
    eq(cues[0].text, "Hello & welcome" + Chr(10) + "second line", "parseVtt strips tags and keeps lines")
    eq(cueText(cues, 1000), "", "cueText before any cue")
    eq(cueText(cues, 2500), cues[0].text + Chr(10) + "Overlap", "cueText joins overlapping cues")
    eq(cueText(cues, 3500), "Overlap", "cueText after the first ends")

    plan = { markers: [{ kind: "intro", start_ms: 10000, end_ms: 40000 }, { kind: "credits", start_ms: 100000, end_ms: 120000 }] }
    eq(skippable(plan, 12000).kind, "intro", "skippable in the intro")
    check(skippable(plan, 39000) = invalid, "skippable not in the last 1.5 s")
    eq(skipLabel("credits", true), "Play Next", "skipLabel credits with a next episode")

    eq(kbpsName(1500), "1.5 Mbps", "kbpsName")
    eq(qualityName(8000), "8 Mbps 1080p", "qualityName")
    eq(FormatJson(qualityChoices({ source_kbps: 5000, server_limit_kbps: 3500 })), "[-1,0,3000,2000,1500,720]", "qualityChoices below source and limit")
    eq(qualityLabel(0, { server_limit_kbps: 4000 }), "Maximum (4 Mbps 720p)", "qualityLabel capped")
    eq(versionName({ edition: "Director's Cut", height: 2160, hdr: "HDR10", size: 25300000000 }), "Director's Cut · 4K · HDR10 · 25.3 GB", "versionName")
    eq(chapterAt([{ start_ms: 0 }, { start_ms: 5000 }], 7000), 1, "chapterAt")
end sub

sub testBrowse()
    q = libraryQueryDefaults()
    lib = { kind: "library", id: 2, libraryKind: "shows" }
    eq(browsePath(lib, q, 0, 60), "/items?kind=series&library_id=2&limit=60&sort=title", "browsePath library first page")
    q.sort = "added"
    q.reverse = true
    q.unwatched = true
    q.genre = "Drama"
    eq(browsePath(lib, q, 60, 60), "/items?genre=Drama&kind=series&library_id=2&limit=60&offset=60&reverse=1&sort=added&unwatched=1", "browsePath with filters and offset")
    eq(browsePath({ kind: "folders", id: 3, path: "0/Birthdays" }, invalid, 0, 60), "/libraries/3/folders?path=0%2FBirthdays", "browsePath folder")
    eq(browsePath({ kind: "collection", id: "abc" }, invalid, 0, 60), "/collections/abc", "browsePath collection")
    eq(browsePath({ kind: "person", id: "369" }, invalid, 0, 60), "/people/369", "browsePath person")
    eq(querySummary(q), "Date added · Oldest first · Unwatched · Drama", "querySummary")

    page = browseCards(lib, { total: 130, items: [{ id: "a", kind: "series" }] })
    eq(page.total, 130, "browseCards keeps the library total")
    eq(page.cards[0].item.id, "a", "browseCards library items")
    folders = browseCards({ kind: "folders" }, { folders: [{ name: "Birthdays", path: "0/Birthdays", count: 2, cover: "/c" }], items: [{ id: "v", kind: "movie" }] })
    eq(folders.cards.Count(), 2, "browseCards folders then videos")
    eq(folders.cards[0].item.kind, "folder", "browseCards folder card")
    eq(folders.cards[0].line2, "2 titles", "browseCards folder count")
    person = browseCards({ kind: "person" }, { person: { name: "X" }, credits: [{ item: { id: "m" }, character: "Deckard" }] })
    eq(person.cards[0].line2, "Deckard", "browseCards person character")
    playlists = browseCards({ kind: "playlists" }, [{ id: "p", title: "Movie Night", count: 6, images: ["/a", "/b"] }])
    eq(playlists.cards[0].item.images.primary, "/a", "browseCards playlist cover")
    eq(browseStyle({ kind: "library", libraryKind: "videos" }), "thumb", "browseStyle home videos")

    rows = searchRows({ movies: [{ id: "1" }], shows: [{ id: "2" }], episodes: [], people: [{ id: 9, name: "Ann", known_for: "director" }] })
    eq(rows.Count(), 2, "searchRows leaves out empty kinds")
    eq(rows[0].cards.Count(), 2, "searchRows joins films and shows")
    eq(rows[1].cards[0].item.id, "9", "searchRows person id as text")
    eq(rows[1].cards[0].line2, "Director", "searchRows person role")
end sub

sub testPlaces()
    libs = [{ id: 1, name: "Movies", kind: "movies" }, { id: 2, name: "TV", kind: "shows" }, { id: 3, name: "Home Videos", kind: "videos" }]
    p = navPlaces(libs, { library_order: [2, 1], watchlist_position: 1 })
    ids = []
    for each place in p
        ids.Push(place.id)
    end for
    eq(ids.Join(","), "search,home,library:2,watchlist,library:1,library:3,playlists,settings", "navPlaces: profile's order, the Watchlist after one library")
    eq(p[2].icon, "tv", "navPlaces: a TV library's icon")
    eq(p[5].icon, "videos", "navPlaces: a videos library's icon")
    eq(p[4].go.go + " " + p[4].go.library.kind, "library movies", "navPlaces: a library opens its page")
    p = navPlaces(libs, invalid)
    eq(p[2].id, "watchlist", "navPlaces: the Watchlist first by default")
    p = navPlaces(libs, { watchlist_position: 99 })
    eq(p[p.Count() - 3].id, "watchlist", "navPlaces: the Watchlist last when asked")
    eq(placeIndex(p, "home"), 1, "placeIndex finds Home")
    eq(placeIndex(p, "nowhere"), -1, "placeIndex: unknown places")
end sub

sub testRecommended()
    eq(recommendedTitle({ type: "recently_added" }, "Movies", "movies"), "Recently Added in Movies", "recommended: recently added names the library")
    eq(recommendedTitle({ type: "top_rated" }, "TV", "shows"), "Top Rated Shows", "recommended: shows say Shows")
    eq(recommendedTitle({ type: "top_by_person", name: "Ridley Scott", role: "director" }, "Movies", "movies"), "Top Movies by Ridley Scott", "recommended: directors are by")
    eq(recommendedTitle({ type: "top_by_person", name: "Al Pacino", role: "actor" }, "Movies", "movies"), "Top Movies with Al Pacino", "recommended: actors are with")
    eq(recommendedTitle({ type: "something_new", title: "Arc's Title" }, "Movies", "movies"), "Arc's Title", "recommended: a new type keeps Arc's title")
    data = { rows: [
        { type: "continue", items: [{ id: "e1", kind: "episode" }] },
        { type: "rediscover", items: [] },
        { type: "because_you_watched", name: "Heat", items: [{ id: "m1", kind: "movie" }, { id: "m2", kind: "movie" }] }
    ] }
    rows = recommendedRows(data, "TV", "shows")
    eq(rows.Count(), 2, "recommended: empty rows are left out")
    eq(rows[0].style, "thumb", "recommended: a row of episodes is 16:9")
    eq(rows[1].title, "Because you watched Heat", "recommended: because you watched")
    eq(rows[1].cards.Count(), 2, "recommended: every title is a card")
    eq(recommendedRows(invalid, "TV", "shows").Count(), 0, "recommended: no answer")
end sub
