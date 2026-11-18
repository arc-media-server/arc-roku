' Production player callbacks; native decoding remains a device check.
sub Main()
    m.requests = []
    m.top = {params: {id: "abc"}, setFocus: function(on as boolean) as boolean
        m.focused = on
        return true
    end function}
    m.closed = false
    m.prerollWaiting = true
    m.prerollActive = false
    m.prerollIndex = -1
    m.prerollClips = []
    m.prerollDeadline = {control: "start"}
    m.skip = {visible: false}
    m.skipText = {}
    m.controls = {visible: true}
    m.video = {control: "stop", content: invalid}
    onPrerollList(answer({ok: true, data: [{url: "/api/preroll/0"},{url: "/api/preroll/1"}]}))
    check(m.prerollActive and m.prerollIndex = 0 and m.skip.visible and m.top.focused, "first clip and focused Skip")
    check(m.requests.Count() = 1 and m.requests[0].body.url = "/api/preroll/0", "scoped cast requested before film")
    check(onKeyEvent("OK",true), "Skip key consumed")
    check(m.prerollIndex = 1 and m.requests[1].body.url = "/api/preroll/1", "Skip advances one clip")
    onPrerollCast(answer({ok: true, tag: 0, data: {url: "old"}}))
    check(m.video.content = invalid, "late replaced-clip link ignored")
    m.video.state = "finished"
    onVideoState()
    check(not m.prerollActive and not m.skip.visible and m.requests[2].path = "/me/prefs", "last clip hands off to film")
    onPrerollCast(answer({ok: true, tag: 1, data: {url: "late"}}))
    check(m.video.content = invalid, "late link cannot restart clips after film handoff")
    m.prerollActive = true
    m.prerollIndex = 0
    m.video.state = "error"
    onVideoState()
    check(m.prerollIndex = 1 and m.requests[3].path = "/cast", "failed clip advances")
    m.prerollActive = false
    m.prerollWaiting = true
    onPrerollDeadline()
    count = m.requests.Count()
    onPrerollList(answer({ok: true, data: [{url: "late"}]}))
    check(m.requests.Count() = count and not m.prerollActive, "deadline ignores late list")
    m.prerollWaiting = true
    check(onKeyEvent("back",true) and m.top.action.go = "back", "Back exits pending attempt")
    m.closed = true
    onPrerollList(answer({ok: true, data: [{url: "late"}]}))
    onPrerollCast(answer({ok: true, tag: 1, data: {url: "late"}}))
    check(m.requests.Count() = count and m.video.content = invalid, "closed player ignores pending replies")
    print "PREROLL PLAYER PASSED"
end sub
function answer(value as object) as object
    return {value: value, getData: function() as object
        return m.value
    end function}
end function
sub callApi(method as string, path as string, body as dynamic, callback as string, tag = invalid as dynamic)
    m.requests.Push({method: method, path: path, body: body, callback: callback, tag: tag})
end sub
function tr(text as string) as string
    return text
end function
sub check(ok as boolean, message as string)
    if not ok then print "PREROLL PLAYER FAILED: "; message: stop
end sub
