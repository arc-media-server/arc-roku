' Real callbacks with rendering-only stand-ins; the simulator separately checks the screen.
sub Main()
    m.requests = []
    m.item = { id: "show", kind: "series", title: "Synthetic Series" }
    m.top = { action: invalid }
    m.showMissing = false
    m.seasonsRequest = 0
    m.error = {text: ""}
    m.cardPanel = {}
    m.buttons = {focusIndex: 0}
    m.draws = 0
    showTitleMenu()
    check(m.cardPanel.entries[1].label = "Show Missing Episodes", "title menu reaches toggle without episodes")
    m.cardPanel.picked = 1
    onRatingPicked()
    check(m.requests[0].path = "/series/show/seasons?missing=1", "title toggle fetches missing")
    check(not m.showMissing, "choice committed only on success")
    first = m.requests[0].tag
    onSeasons(eventFor({ok:false,tag:first}))
    check(not m.showMissing and m.error.text <> "", "failed toggle retains previous choice")
    toggleMissingEpisodes()
    newest = m.requests[1].tag
    onSeasons(eventFor({ok:true,tag:first,data:{seasons:[]}}))
    check(m.draws = 0, "stale response ignored")
    onSeasons(eventFor({ok:true,tag:newest,data:{seasons:[{season_number:1,episodes:[{available:false,title:"Missing",episode_number:1}]}]}}))
    check(m.showMissing and m.error.text = "" and m.draws = 1, "successful toggle commits and clears error")
    showTitleMenu()
    check(m.cardPanel.entries[1].label = "Hide Missing Episodes", "title menu follows choice")
    closeCardPanel()
    node = {itemId:"",available:false,title:"Missing",kind:"episode",resumeMs:0}
    row = { rowKind:"season", seasonIndex:0, child:node, getChild:function(i as integer) as object
        return m.child
    end function }
    m.episodes = {rowItemFocused:[0,0],rowItemSelected:[0,0],content:{child:row,getChild:function(i as integer) as object
        return m.child
    end function}}
    showSeasonMenu()
    check(m.menuEntries.Count() = 1 and m.menuEntries[0].act = "hideMissing", "missing-only season offers visibility only")
    onEpisode()
    check(m.top.action = invalid, "missing episode OK cannot play")
    m.cardPanel.picked = 0
    onCardPicked()
    check(m.requests[2].path = "/series/show/seasons", "hide missing from season menu")
    ' Defence against a stale Play menu from before an availability update.
    m.menuEntries = [{act:"play"}]
    m.cardPanel.picked = 0
    onCardPicked()
    check(m.top.action = invalid, "stale missing card Play guarded")
    print "MISSING MENU PASSED"
end sub
sub callApi(method as string, path as string, body as dynamic, callback as string, tag = invalid as dynamic)
    m.requests.Push({method:method,path:path,body:body,callback:callback,tag:tag})
end sub
function eventFor(data as object) as object
    return { data:data,getData:function() as object
        return m.data
    end function }
end function
sub buildRows()
    m.draws++
end sub
sub showButtons()
end sub
sub focusRows()
end sub
sub focusButtons()
end sub
sub check(ok as boolean, message as string)
    if not ok then print "MISSING MENU FAILED: ";message:stop
end sub
