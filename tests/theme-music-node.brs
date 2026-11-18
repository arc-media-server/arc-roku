' Production theme callbacks, without pretending to validate native audio output.
sub Main()
    m.requests = []
    m.top = { params: { id: "abc" }, visible: true }
    m.theme = { control: "play", content: { title: "fixture" }, state: "playing" }
    m.item = {kind: "movie", theme_url: "/api/items/abc/theme"}
    m.themePlayed = true
    m.themeAllowed = true
    onThemePrefs(answer("abc", {}))
    check(m.theme.control = "play", "unrelated hint preserves playing tune")
    onThemePrefs(answer("old", {theme_music: false}))
    check(m.theme.control = "play", "old page preference cannot stop current tune")
    onThemePrefs(answer("abc", {theme_music: false}))
    check(m.theme.control = "stop", "disable stops native audio")
    onThemePrefs(answer("abc", {theme_music: true}))
    check(m.theme.control = "stop", "re-enable does not replay played visit")
    m.themeVisitId = "abc"
    m.top.params.id = "def"
    beginThemeVisit()
    check(not m.themePlayed and m.themeAllowed and m.item = invalid, "new id resets visit and loaded item")
    onThemePrefs(answer("abc", {}))
    check(m.theme.content = invalid, "old response cannot start new visit")
    m.top.visible = false
    onThemeVisible()
    check(not m.themeAllowed and m.theme.control = "stop", "hidden page stops and disallows playback")
    m.top.visible = true
    beginThemeVisit()
    check(not m.themeAllowed, "return to same page does not replay")
    m.global = {liveTopics: {media: true}}
    onThemeLiveTopics()
    check(m.requests.Count() = 0, "unrelated topic does not refetch prefs")
    m.global.liveTopics = {profile: true}
    onThemeLiveTopics()
    check(m.requests.Count() = 1 and m.requests[0].tag = "def", "profile hint refreshes current visit prefs")
    m.theme.state = "error"
    onThemeState()
    check(m.theme.control = "stop" and m.theme.content = invalid, "native error releases tune")
    print "THEME CALLBACKS PASSED"
end sub

function answer(id as string, data as object) as object
    return { result: {ok: true, tag: id, data: data}, getData: function() as object
        return m.result
    end function }
end function

sub callApi(method as string, path as string, body as dynamic, callback as string, tag as dynamic)
    m.requests.Push({method: method, path: path, tag: tag})
end sub

sub check(ok as boolean, message as string)
    if not ok then print "THEME CALLBACK FAILED: "; message: stop
end sub
