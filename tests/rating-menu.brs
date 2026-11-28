' Execute the real title-menu handlers with lightweight scene field stand-ins.
sub Main()
    m.requests = []
    m.top = { params: { id: "abc" } }
    m.item = { id: "abc", title: "Scratch", user_data: { rating: 9 } }
    m.cardPanel = {}
    m.error = { text: "" }
    m.page = { translation: [0, 0] }
    m.tabs = {}
    m.slide = {}
    m.slideTo = {}
    m.buttons = { setFocus: function(on as boolean)
        m.focused = on
    end function }
    showTitleMenu()
    check(m.cardPanel.visible and m.ratingPanel = "more", "title menu")
    m.cardPanel.picked = 0
    onRatingPicked()
    check(m.cardPanel.selected = 1 and m.cardPanel.title = "Your Rating", "current half-star focus")
    m.cardPanel.picked = 1
    onRatingPicked()
    check(m.requests.Count() = 0 and not m.cardPanel.visible and m.buttons.focused, "same value quiet")
    showTitleMenu()
    closeCardPanel()
    check(m.requests.Count() = 0 and m.ratingPanel = "", "cancel quiet")
    chooseRating(10)
    check(m.requests.Count() = 1 and m.requests[0].body.rating = 0, "clear sends zero")
    onRatingSaved(eventFor({ ok: false, tag: m.requests[0].tag }))
    check(m.item.user_data.rating = 9, "refusal restores rating")
    check(m.error.text = "Couldn't save your rating. Try again." and m.buttons.focused, "refusal message and focus")
    chooseRating(0)
    check(m.error.text = "", "retry clears stale rating error")
    onRatingSaved(eventFor({ ok: true, tag: m.requests[1].tag }))
    check(m.requests[2].method = "GET" and m.requests[2].path = "/items/abc", "success refreshes page")
    count = m.requests.Count()
    onRatingSaved(eventFor({ ok: false, tag: { id: "other", rating: 10, previous: 3 } }))
    check(m.item.user_data.rating = 10 and m.requests.Count() = count, "stale page response ignored")
    m.item = { id: "film", kind: "movie", title: "Film", files: [{ id: 10 }, { id: 11 }], user_data: { position_ms: 72500 } }
    showTitleMenu()
    versionIndex = m.cardPanel.entries.Count() - 1
    check(m.cardPanel.entries[versionIndex].label = "Play Version…", "title offers a pre-play file choice")
    m.cardPanel.picked = versionIndex
    onCardPicked()
    check(m.cardPanel.title = "Play Version" and m.cardPanel.entries.Count() = 2, "opens version choices")
    m.cardPanel.picked = 1
    onCardPicked()
    check(m.top.action.fileId = 11 and m.top.action.startMs = 72500, "plays chosen file from the resume position")
    print "RATING MENU PASSED"
end sub

sub chooseRating(index as integer)
    showTitleMenu()
    m.cardPanel.picked = 0
    onRatingPicked()
    m.cardPanel.picked = index
    onRatingPicked()
end sub

sub callApi(method as string, path as string, body as dynamic, callback as string, tag = invalid as dynamic)
    m.requests.Push({ method: method, path: path, body: body, callback: callback, tag: tag })
end sub

function eventFor(data as object) as object
    return { data: data, getData: function() as object
        return m.data
    end function }
end function

sub check(ok as boolean, message as string)
    if not ok then print "RATING MENU FAILED: "; message: stop
end sub
