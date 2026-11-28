' Real callbacks with rendering-only stand-ins; the simulator separately checks the screen.
sub Main()
    m.requests = []
    m.item = { id: "show", kind: "series", title: "Synthetic Series" }
    m.top = { action: invalid }
    m.seasonsRequest = 2
    m.error = {text: ""}
    m.cardPanel = {}
    m.buttons = {focusIndex: 0}
    m.draws = 0
    tag = { id: "show", request: 2 }
    onSeasonPrefs(eventFor({ok:true,tag:{id:"show",request:1},data:{show_missing_episodes:true}}))
    check(m.requests.Count() = 0, "stale preference response ignored")
    onSeasonPrefs(eventFor({ok:true,tag:tag,data:{}}))
    check(m.requests[0].path = "/series/show/seasons", "older prefs hide missing episodes")
    onSeasonPrefs(eventFor({ok:true,tag:tag,data:{show_missing_episodes:true}}))
    check(m.requests[1].path = "/series/show/seasons?missing=1", "saved preference shows missing episodes")
    onSeasons(eventFor({ok:true,tag:tag,data:{seasons:[{season_number:1,episodes:[{available:false,title:"Missing",episode_number:1}]}]}}))
    check(m.error.text = "" and m.draws = 1, "missing episode received")
    showTitleMenu()
    check(m.cardPanel.entries[0].label = "Rate…", "title menu retains rating")
    for each entry in m.cardPanel.entries
        check(entry.label <> "Show Missing Episodes" and entry.label <> "Hide Missing Episodes", "missing-episode toggle lives in Settings")
    end for
    closeCardPanel()
    node = {itemId:"",available:false,title:"Missing",kind:"episode",resumeMs:0}
    row = { rowKind:"season", seasonIndex:0, child:node, getChild:function(i as integer) as object
        return m.child
    end function }
    m.episodes = {rowItemFocused:[0,0],rowItemSelected:[0,0],content:{child:row,getChild:function(i as integer) as object
        return m.child
    end function}}
    showSeasonMenu()
    check(not m.cardPanel.visible, "missing-only season has no actions")
    onEpisode()
    check(m.top.action = invalid, "missing episode OK cannot play")
    ' Defence against a stale Play menu from before an availability update.
    m.menuAt = {node:node}
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
