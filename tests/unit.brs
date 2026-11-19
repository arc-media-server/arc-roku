' Unit tests for the app's shared logic, run with brs-cli (BrightScript Simulation Engine) by
' scripts/test.mjs. Each check prints "ok" or "FAIL <what>"; the script fails on any FAIL.

sub Main()
    m.failures = 0
    testHttp()
    testFormat()
    testCaps()
    testHome()
    testBif()
    testLiveHints()
    testTracks()
    testBrowse()
    testPlaces()
    testRecommended()
    testQuality()
    testPreroll()
    testTitlePage()
    testPlayerOsd()
    testPerson()
    testSeasons()
    testSpoilers()
    testCardMenu()
    testStarRating()
    testSeasonActions()
    testThemeMusic()
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


sub testStarRating()
    eq(ratingStars(9), "★★★★½", "rating halves")
    eq(ratingStars(1), "½", "rating minimum")
    eq(ratingStars(0), "", "rating cleared")
    choices = ratingChoices(9)
    eq(choices.Count(), 11, "clear only when rated")
    eq(choices[0].rating, 10, "best first")
    eq(choices[9].rating, 1, "half star last")
    eq(choices[10].rating, 0, "clear uses zero")
    eq(ratingChoices(0).Count(), 10, "no clear without rating")
    req = ratingRequest("a/b", 9)
    eq(req.method, "PUT", "rating PUT")
    eq(req.path, "/items/a%2Fb/rating", "rating escaped path")
    eq(req.body.rating, 9, "rating half-star body")
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
    check(split[0].continueRow = true and split[1].continueRow = true, "Continue Watching and Up Next can be removed from")
    check(rows[0].continueRow = true and rows[1].continueRow <> true and rows[2].continueRow <> true, "only the Continue Watching row can be removed from")
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
    eq(browsePath(lib, q, 0, 60), "/items?kind=series&letters=1&library_id=2&limit=60&sort=title", "browsePath library first page asks where letters start")
    eq(browsePath(lib, q, 60, 60), "/items?kind=series&library_id=2&limit=60&offset=60&sort=title", "browsePath later pages don't")
    q.letter = "s"
    eq(browsePath(lib, q, 0, 60), "/items?jump=S&kind=series&letters=1&library_id=2&limit=60&sort=title", "browsePath jumps to a letter")
    eq(browsePath(lib, q, 412, 60), "/items?kind=series&library_id=2&limit=60&offset=412&sort=title", "browsePath carries on after a jump without it")
    eq(querySummary(q), "Title · A to Z · From S", "querySummary names the letter")
    q.reverse = true
    eq(browsePath(lib, q, 0, 60), "/items?jump=S&kind=series&letters=1&library_id=2&limit=60&reverse=1&sort=title", "browsePath jumps in Z to A too")
    q = libraryQueryDefaults()
    eq(q.letter, "", "a library starts at the beginning")
    jumped = browseCards(lib, { total: 900, offset: 412, items: [{ id: "s1", kind: "series" }], letters: [{ letter: "#", count: 3 }, { letter: "a", count: 40 }, { letter: "b", count: 0 }, { letter: "s", count: 52 }] })
    eq(jumped.offset, 412, "browseCards keeps where a jumped page starts")
    eq(letterChoices(jumped.letters).Join(","), "a,s", "letterChoices: A to Z with titles only")
    eq(letterChoices(invalid).Count(), 0, "letterChoices: none asked for")
    eq(browseCards(lib, { total: 5, items: [] }).offset, 0, "browseCards: an ordinary page starts at 0")
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
    check(rows[0].continueRow = true and rows[1].continueRow = false, "recommended: only Continue Watching can be removed from")
end sub

' The same files as the Apple TV app's QualityTests.
sub testQuality()
    f = { streams: [{ kind: "video", codec: "hevc", width: 3840, height: 1600, color_transfer: "smpte2084", dolby_vision: true }, { kind: "audio", codec: "eac3", profile: "Dolby Digital Plus + Dolby Atmos", channels: 6, is_default: true }] }
    eq(qualityBadges(f).Join("|"), "4K|DV HDR10|DD+ 5.1|Atmos", "quality: 4K Dolby Vision with Atmos")
    f = { streams: [{ kind: "video", codec: "h264", width: 1920, height: 1080 }, { kind: "audio", codec: "aac", channels: 2 }, { kind: "audio", codec: "dts", profile: "DTS-HD MA + DTS:X", channels: 8, is_default: true }] }
    eq(qualityBadges(f).Join("|"), "HD|DTS-HD MA 7.1|DTS:X", "quality: the default audio track")
    eq(qualityBadges({ streams: [{ kind: "video", codec: "mpeg2video", width: 720, height: 576 }] }).Join("|"), "SD", "quality: SD")
    eq(qualityBadges({ streams: [{ kind: "video", codec: "hevc", width: 3840, height: 2160, color_transfer: "arib-std-b67" }] }).Join("|"), "4K|HLG", "quality: HLG")
    eq(qualityBadges({ streams: [] }).Count(), 0, "quality: no streams")
    eq(qualityBadges(invalid).Count(), 0, "quality: no file")
    item = { files: [{ id: 1, missing: true }, { id: 2 }] }
    eq(qualityFile(item).id, 2, "quality: the first file on disk")
end sub

sub testTitlePage()
    movie = { kind: "movie", year: 2014, runtime_min: 169, genres: ["Adventure", "Drama", "Science Fiction", "Mystery"], credits: [
        { role: "actor", name: "Matthew McConaughey" }, { role: "director", name: "Christopher Nolan" },
        { role: "actor", name: "Anne Hathaway" }, { role: "actor", name: "Michael Caine" }, { role: "actor", name: "Jessica Chastain" }] }
    eq(heroGenres(movie), "Adventure · Drama · Science Fiction", "title page: three genres")
    eq(heroFacts(movie), "2014 · 2h 49m", "title page: year and length")
    eq(heroFacts({ kind: "episode", season_number: 1, episode_number: 8, title: "Ariel", runtime_min: 46 }), "S1 E8 · Ariel · 46m", "title page: an episode's facts")
    eq(joinNames(creditNames(movie, "actor", 3)), "Matthew McConaughey, Anne Hathaway, and Michael Caine", "title page: three actors")
    eq(joinNames(creditNames(movie, "director", 3)), "Christopher Nolan", "title page: one director")
    eq(joinNames(["A", "B"]), "A and B", "title page: two names")
    eq(joinNames([]), "", "title page: no names")
end sub

sub testPlayerOsd()
    pieces = osdSegments([{ start_ms: 0 }, { start_ms: 4000 }, { start_ms: 8000 }], 12000)
    eq(pieces.Count(), 3, "osd: a piece per chapter")
    eq(pieces[1].start, 4000, "osd: the second piece starts at its chapter")
    eq(pieces[2].finish, 12000, "osd: the last piece ends at the end")
    eq(osdSegments(invalid, 60000).Count(), 1, "osd: no chapters, one piece")
    eq(osdSegments([{ start_ms: 70000 }], 60000).Count(), 1, "osd: a chapter past the end is left out")
    widths = osdWidths(pieces, 1216, 8)
    eq(Int(widths[0]), 400, "osd: widths share what's left after the gaps")
    eq(Int(osdMarkerX(pieces, widths, 8, 6000)), 608, "osd: the marker halfway through the second piece")
    eq(Int(osdMarkerX(pieces, widths, 8, 0)), 0, "osd: the marker at the start")
    eq(Int(osdMarkerX(pieces, widths, 8, 12000)), 1216, "osd: the marker at the end")
    eq(osdTabs(true, false, true).Join("|"), "info|chapters|episodes", "osd: tabs by what there is")
    ep = { kind: "episode", season_number: 2, episode_number: 4, title: "Day of Atonement", release_date: "2026-10-24" }
    eq(osdEpisodeLine(ep), "S2, E4 • Day of Atonement", "osd: the episode line")
    eq(osdEpisodeLine({ kind: "movie", title: "Heat" }), "", "osd: a film has no episode line")
    eq(osdMeta(ep, 24 * 60000), "S2 · E4 · 24m · 24 Oct 2026", "osd: the Info card's line")
    eq(osdMeta({ kind: "movie", year: 1995 }, 170 * 60000), "2h 50m · 1995", "osd: a film's line")
    eq(osdDay("nonsense"), "", "osd: not a date")
end sub

sub testPerson()
    heat = { id: "h", kind: "movie", title: "Heat", year: 1995, release_date: "1995-12-15" }
    joker = { id: "j", kind: "movie", title: "Joker", year: 2019, release_date: "2019-10-04" }
    show = { id: "s", kind: "series", title: "Show", year: 2010 }
    film = { id: "f", kind: "movie", title: "Directed", year: 2001 }
    page = { person: { name: "Al", known_for: "Acting" }, credits: [
        { item: heat, character: "Lt. Vincent Hanna", roles: ["actor"] },
        { item: joker, character: "Someone", roles: ["actor"] },
        { item: show, character: "Guest", roles: [] },
        { item: film, roles: ["director"] },
        { item: heat, roles: ["actor"] }] }
    rows = personRows(page)
    eq(rows.Count(), 3, "person: movies, shows, behind the camera")
    eq(rows[0].credits[0].item.title, "Joker", "person: newest first")
    eq(rows[0].credits.Count(), 2, "person: a title once per row")
    eq(rows[2].credits[0].item.title, "Directed", "person: behind the camera")
    eq(personSummary(page), "Acting · 4 titles in your libraries", "person: the summary")
    eq(personSummary({ person: {}, credits: [{ item: heat }] }), "1 title in your libraries", "person: one title")
    eq(personPart(page.credits[0]), "Heat (1995) · as Lt. Vincent Hanna", "person: their part")
    eq(personPart(page.credits[3]), "Directed (2001) · Director", "person: a part behind the camera")
    eq(personRows(invalid).Count(), 0, "person: no page")
end sub

sub testSeasons()
    e1 = { id: "e1", episode_number: 1, runtime_min: 44, available: true }
    e2 = { id: "e2", episode_number: 2, available: false }
    s0 = { id: "s0", episode_number: 1 }
    odd = { id: "x", episode_number: 20, runtime_min: 42 }
    data = { seasons: [{ season_number: 1, name: "", episodes: [e1, e2] }, { season_number: 2, episodes: [] }, { season_number: 0, name: "Specials", episodes: [s0] }], unplaced: [odd] }
    rows = seasonRows(data)
    eq(rows.Count(), 3, "seasons: empty seasons left out, unplaced added")
    eq(rows[0].title, "Season 1", "seasons: a season without a name")
    eq(rows[1].title, "Specials", "seasons: a season's own name")
    eq(rows[2].title, "Not in This Order", "seasons: the unplaced row's name, last")
    check(rows[2].unplaced = true and rows[0].unplaced = false, "seasons: only the last row is unplaced")
    eq(rows[2].episodes[0].id, "x", "seasons: the unplaced episode is kept")
    eq(rows[0].season_number, 1, "seasons: a season row keeps its number, for the season menu")
    eq(rows[1].season_number, 0, "seasons: Specials is season 0")
    eq(seasonRows({ seasons: [{ season_number: 1, episodes: [e1] }], unplaced: invalid }).Count(), 1, "seasons: unplaced null")
    eq(seasonRows({ seasons: [{ season_number: 1, episodes: [e1] }], unplaced: [] }).Count(), 1, "seasons: unplaced empty")
    eq(seasonRows(invalid).Count(), 0, "seasons: no answer")
    eq(seasonRows({ seasons: [], unplaced: [odd] }).Count(), 1, "seasons: only unplaced episodes still show")
    row = seasonOf(data, "e1")
    check(row <> invalid and row.unplaced = false and row.episodes.Count() = 1, "seasons: an episode's season, available only")
    row = seasonOf(data, "x")
    check(row <> invalid and row.unplaced = true and row.episodes[0].id = "x", "seasons: an unplaced episode's row")
    check(seasonOf(data, "nope") = invalid, "seasons: an episode not in any row")
    eq(seasonCardLine(e1, false), "E1 · 44m", "seasons: number and length")
    eq(seasonCardLine(odd, true), "42m", "seasons: unplaced shows only its length")
    eq(seasonCardLine({ episode_number: 3 }, false), "E3", "seasons: no length")
end sub

sub testCardMenu()
    ep = { kind: "episode", itemId: "e", parentId: "s", resumeMs: 60000, played: false, watchlisted: false, inContinue: true }
    eq(menuActs(cardMenu(ep)), "play,restart,watched,uncontinue,show", "card menu: an episode in Continue Watching")
    movie = { kind: "movie", itemId: "m", parentId: "", resumeMs: 0, played: false, watchlisted: false, inContinue: true }
    eq(menuActs(cardMenu(movie)), "play,watched,list,uncontinue,open", "card menu: a film in Up Next or Continue Watching")
    eq(cardMenu(movie)[3].label, "Remove from Continue Watching", "card menu: the remove entry's name")
    movie.inContinue = false
    eq(menuActs(cardMenu(movie)), "play,watched,list,open", "card menu: elsewhere there's no remove entry")
    eq(cardMenu({ kind: "collection" }).Count(), 0, "card menu: not on a collection")
end sub

function menuActs(entries as object) as string
    acts = []
    for each e in entries
        acts.Push(e.act)
    end for
    return acts.Join(",")
end function

sub testSeasonActions()
    seen = { id: "1", user_data: { played: true } }
    unseen = { id: "2", user_data: { played: false } }
    fresh = { id: "3" }
    gone = { id: "4", available: false }
    eq(seasonOnDisk([seen, gone, fresh]).Count(), 2, "season: episodes on disk")
    check(seasonWatched([seen, gone]), "season: watched when every one on disk is")
    check(not seasonWatched([seen, unseen]), "season: not watched with one unwatched")
    check(not seasonWatched([gone]), "season: not watched with nothing on disk")
    card = [{ label: "Play", act: "play" }, { label: "Mark as watched", act: "watched" }, { label: "Go to show", act: "show" }]
    acts = []
    for each e in seasonMenu(card, [seen, unseen, gone])
        acts.Push(e.act)
    end for
    eq(acts.Join(","), "play,watched,seasonWatched,shuffleSeason", "season menu: the card's, then the season's")
    acts = []
    for each e in seasonMenu(card, [seen, gone])
        acts.Push(e.act)
    end for
    eq(acts.Join(","), "play,watched,seasonUnwatched", "season menu: unwatched, no shuffle for one")
    eq(seasonMenu(card, [gone]).Count(), 2, "season menu: nothing for a season not on disk")
    ids = shuffledIds([seen, unseen, fresh, gone])
    eq(ids.Count(), 3, "shuffle: only episodes on disk")
    sorted = [ids[0], ids[1], ids[2]]
    sorted.Sort()
    eq(sorted.Join(","), "1,2,3", "shuffle: each once")
    q = { current_entry_id: "a", entries: [{ id: "a", available: true, item: seen }, { id: "b", available: false }, { id: "c", available: true, item: fresh }] }
    eq(queueCurrent(q).id, "a", "queue: the current entry")
    eq(queueNext(q).id, "c", "queue: next passes over unavailable entries")
    q.current_entry_id = "c"
    check(queueNext(q) = invalid, "queue: nothing after the last")
    q.current_entry_id = "b"
    check(queueCurrent(q) = invalid, "queue: an unavailable current entry")
    check(queueNext(invalid) = invalid, "queue: none")
end sub

' Theme music
sub testThemeMusic()
    item = {kind: "movie", theme_url: "/api/items/abc/theme"}
    eq(themeMusicPath(item, {}), "/api/v1/items/abc/theme", "movie theme defaults on")
    eq(themeMusicPath(item, {theme_music: false}), "", "theme switch off")
    item.theme_url = "/api/items/abc/theme?v=123"
    eq(themeMusicPath(item, {}), "/api/v1/items/abc/theme?v=123", "server theme cache version")
    item.theme_url = "/api/items/abc/theme"
    item.kind = "episode"
    eq(themeMusicPath(item, {}), "", "episodes have no theme")
    item.kind = "series"
    eq(themeMusicPath(item, {}), "/api/v1/items/abc/theme", "show theme")
    item.theme_url = "https://other.invalid/api/items/abc/theme"
    eq(themeMusicPath(item, {}), "", "never send sign-in to an external theme")
    item.theme_url = "/api/items/abc/stream"
    eq(themeMusicPath(item, {}), "", "only theme routes")
end sub
